# ppt-controller.ps1
# PowerPoint Remote Controller - HTTP Server with COM Automation
# Start this script, then open PowerPoint presentation

$port = 8765
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")

# Temp directory for slide image exports (randomized to prevent symlink attacks)
$tempDir = Join-Path $env:TEMP ("ppt-controller-slides-" + [guid]::NewGuid().ToString('N').Substring(0, 12))
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
}

# Prevent accidental double start/stop commands from key repeat / double-click
$commandCooldownMs = 800
$lastCommandAt = @{}
$pptClientId = "ai-cafe-presenter"
$tokenBytes = New-Object byte[] 32
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$rng.GetBytes($tokenBytes)
$rng.Dispose()
$pptAuthToken = [Convert]::ToBase64String($tokenBytes).TrimEnd('=').Replace('+', '-').Replace('/', '_')
$endpointMethods = @{
    "/auth-token" = "GET"
    "/status" = "GET"
    "/slide-image" = "GET"
    "/start" = "POST"
    "/start-current" = "POST"
    "/stop" = "POST"
    "/next" = "POST"
    "/previous" = "POST"
    "/goto" = "POST"
    "/shutdown" = "POST"
}
$allowedCorsOrigins = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
[void]$allowedCorsOrigins.Add("null")

if (-not [string]::IsNullOrWhiteSpace($env:PPT_ALLOWED_ORIGINS)) {
    $configuredOrigins = $env:PPT_ALLOWED_ORIGINS -split '[,;]' | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    foreach ($configuredOrigin in $configuredOrigins) {
        [void]$allowedCorsOrigins.Add($configuredOrigin.TrimEnd('/'))
    }
}

function Send-JsonResponse {
    param(
        [object]$response,
        [int]$statusCode,
        [hashtable]$payload
    )
    $json = $payload | ConvertTo-Json -Compress
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($json)
    $response.StatusCode = $statusCode
    $response.ContentType = "application/json; charset=utf-8"
    $response.Headers.Add("X-Content-Type-Options", "nosniff")
    $response.ContentLength64 = $buffer.Length
    $response.OutputStream.Write($buffer, 0, $buffer.Length)
    $response.Close()
}

function Normalize-Origin {
    param([string]$origin)

    if ([string]::IsNullOrWhiteSpace($origin)) {
        return $null
    }
    if ($origin -eq "null") {
        return "null"
    }

    try {
        $originUri = [Uri]$origin
    } catch {
        return $null
    }

    if (-not $originUri.IsAbsoluteUri) {
        return $null
    }

    $normalized = "{0}://{1}" -f $originUri.Scheme.ToLowerInvariant(), $originUri.Host.ToLowerInvariant()
    if (-not $originUri.IsDefaultPort) {
        $normalized += ":" + $originUri.Port
    }
    return $normalized.TrimEnd('/')
}

function Get-AllowedCorsOrigin {
    param([object]$request)

    $origin = $request.Headers["Origin"]
    if ([string]::IsNullOrWhiteSpace($origin)) {
        return $null
    }

    $normalizedOrigin = Normalize-Origin $origin
    if ($normalizedOrigin -and $allowedCorsOrigins.Contains($normalizedOrigin)) {
        return $origin
    }

    return $null
}

function Get-TokenRequestFailureReason {
    param([object]$request)

    $origin = $request.Headers["Origin"]
    if ([string]::IsNullOrWhiteSpace($origin)) {
        return "Origin header required for token request"
    }

    $allowedOrigin = Get-AllowedCorsOrigin $request
    if (-not $allowedOrigin) {
        return "Origin not allowed for token request"
    }

    $clientHeader = $request.Headers["X-PPT-Client"]
    if ($clientHeader -ne $pptClientId) {
        return "Missing or invalid X-PPT-Client header"
    }

    return $null
}

function Get-AuthFailureReason {
    param(
        [object]$request,
        [string]$path
    )

    # Only mutating endpoints (POST) require auth
    if (-not $endpointMethods.ContainsKey($path)) {
        return $null
    }
    if ($endpointMethods[$path] -ne "POST") {
        return $null
    }

    # Compatibility: local non-browser tools (PowerShell/curl without Origin) stay functional
    $origin = $request.Headers["Origin"]
    if ([string]::IsNullOrWhiteSpace($origin)) {
        return $null
    }

    $clientHeader = $request.Headers["X-PPT-Client"]
    if ($clientHeader -ne $pptClientId) {
        return "Missing or invalid X-PPT-Client header"
    }

    $tokenHeader = $request.Headers["X-PPT-Token"]
    if ([string]::IsNullOrWhiteSpace($tokenHeader) -or $tokenHeader -ne $pptAuthToken) {
        return "Missing or invalid X-PPT-Token header"
    }

    return $null
}

function Release-ComObject {
    param([object]$obj)
    if ($null -eq $obj) { return }
    try {
        if ([System.Runtime.InteropServices.Marshal]::IsComObject($obj)) {
            [void][System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($obj)
        }
    } catch {
        # Ignore cleanup errors
    }
}

function Release-PptState {
    param([object]$state)
    if ($null -eq $state) { return }
    Release-ComObject $state.SlideShowView
    Release-ComObject $state.Presentation
    Release-ComObject $state.Ppt
}

function Get-HResultHex {
    param([System.Exception]$Exception)
    try {
        return ('0x{0:X8}' -f ([uint32]$Exception.HResult))
    } catch {
        return ''
    }
}

function Test-TransientComError {
    param([System.Exception]$Exception)
    $msg = $Exception.Message
    $hrHex = Get-HResultHex $Exception
    return (
        $msg -match 'RPC_E_CALL_REJECTED' -or
        $msg -match 'RPC_E_SERVERCALL_RETRYLATER' -or
        $msg -match 'application is busy' -or
        $msg -match 'Call was rejected by callee' -or
        $hrHex -eq '0x80010001' -or
        $hrHex -eq '0x8001010A'
    )
}

function Invoke-ComWithRetry {
    param(
        [scriptblock]$Action,
        [int]$MaxAttempts = 8,
        [int]$DelayMs = 120
    )
    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        try {
            return & $Action
        } catch {
            if ((Test-TransientComError $_.Exception) -and $attempt -lt $MaxAttempts) {
                Start-Sleep -Milliseconds $DelayMs
                continue
            }
            throw
        }
    }
}

function Get-FriendlyErrorMessage {
    param([System.Exception]$Exception)
    $msg = $Exception.Message
    $hrHex = Get-HResultHex $Exception

    if ($msg -match 'GetActiveObject' -or $hrHex -eq '0x800401E3') {
        return 'PowerPoint not open'
    }
    if ($msg -match 'No presentation') {
        return 'No presentation open'
    }
    if (Test-TransientComError $Exception) {
        return 'PowerPoint busy (transient COM error)'
    }

    if ($hrHex) {
        return "Error ${hrHex}: $msg"
    }
    return "Error: $msg"
}

function Is-CommandThrottled {
    param([string]$CommandName)
    $now = Get-Date
    if ($lastCommandAt.ContainsKey($CommandName)) {
        $elapsed = ($now - $lastCommandAt[$CommandName]).TotalMilliseconds
        if ($elapsed -lt $commandCooldownMs) {
            return $true
        }
    }
    $lastCommandAt[$CommandName] = $now
    return $false
}

function Set-EditModeSlide {
    param(
        [object]$ppt,
        [int]$slideNum
    )
    $activeWindow = $null
    try {
        $activeWindow = Invoke-ComWithRetry { $ppt.ActiveWindow }
        if ($activeWindow -and $activeWindow.View) {
            Invoke-ComWithRetry { $activeWindow.View.GotoSlide($slideNum) | Out-Null }
        }
    } catch {
        # Ignore edit-mode navigation errors
    } finally {
        Release-ComObject $activeWindow
    }
}

function Reset-SlideShowSettings {
    param([object]$presentation)
    try {
        $settings = Invoke-ComWithRetry { $presentation.SlideShowSettings }
        $totalSlides = [int](Invoke-ComWithRetry { $presentation.Slides.Count })
        Invoke-ComWithRetry { $settings.RangeType = 1 }
        Invoke-ComWithRetry { $settings.StartingSlide = 1 }
        Invoke-ComWithRetry { $settings.EndingSlide = $totalSlides }
    } catch {
        # Non-fatal
    } finally {
        Release-ComObject $settings
    }
}

function Start-PresentationSlideShow {
    param(
        [object]$ppt,
        [object]$presentation,
        [int]$startSlide
    )

    $settings = $null
    $runWindow = $null
    $originalRangeType = $null
    $originalStart = $null
    $originalEnd = $null

    $totalSlides = [int](Invoke-ComWithRetry { $presentation.Slides.Count })
    $safeStartSlide = [math]::Max(1, [math]::Min($startSlide, $totalSlides))

    try {
        $settings = Invoke-ComWithRetry { $presentation.SlideShowSettings }
        $originalRangeType = [int](Invoke-ComWithRetry { $settings.RangeType })
        $originalStart = [int](Invoke-ComWithRetry { $settings.StartingSlide })
        $originalEnd = [int](Invoke-ComWithRetry { $settings.EndingSlide })

        # Force an explicit valid range for reliable start from requested slide.
        Invoke-ComWithRetry { $settings.RangeType = 2 }
        Invoke-ComWithRetry { $settings.StartingSlide = $safeStartSlide }
        Invoke-ComWithRetry { $settings.EndingSlide = $totalSlides }

        $runWindow = Invoke-ComWithRetry { $settings.Run() }

        $started = $false
        $current = $safeStartSlide
        for ($i = 0; $i -lt 16; $i++) {
            Start-Sleep -Milliseconds 120
            try {
                if ($runWindow -and $runWindow.View) {
                    try {
                        $current = [int](Invoke-ComWithRetry { $runWindow.View.Slide.SlideIndex })
                    } catch {
                        $current = [int](Invoke-ComWithRetry { $runWindow.View.CurrentShowPosition })
                    }
                    $started = $true
                    break
                }
            } catch {
                # Keep probing
            }

            try {
                $windowCount = [int](Invoke-ComWithRetry { $ppt.SlideShowWindows.Count })
                if ($windowCount -gt 0) {
                    try {
                        $current = [int](Invoke-ComWithRetry { $ppt.SlideShowWindows[1].View.Slide.SlideIndex })
                    } catch {
                        $current = [int](Invoke-ComWithRetry { $ppt.SlideShowWindows[1].View.CurrentShowPosition })
                    }
                    $started = $true
                    break
                }
            } catch {
                # Keep probing
            }
        }

        return [pscustomobject]@{
            Started = $started
            CurrentSlide = $current
            TotalSlides = $totalSlides
            StartSlide = $safeStartSlide
        }
    }
    finally {
        # Always restore previous settings, even when Run() fails.
        try {
            if ($settings -and $null -ne $originalRangeType -and $null -ne $originalStart -and $null -ne $originalEnd) {
                Invoke-ComWithRetry { $settings.RangeType = $originalRangeType }
                Invoke-ComWithRetry { $settings.StartingSlide = $originalStart }
                Invoke-ComWithRetry { $settings.EndingSlide = $originalEnd }
            }
        } catch {
            # Non-fatal
        }

        Release-ComObject $runWindow
        Release-ComObject $settings
    }
}

function Get-PptState {
    $ppt = $null
    $presentation = $null
    $slideShowView = $null
    $activeWindow = $null

    try {
        $ppt = Invoke-ComWithRetry { [Runtime.InteropServices.Marshal]::GetActiveObject("PowerPoint.Application") }
        if ($null -eq $ppt) {
            throw "PowerPoint not open"
        }

        $presentationsCount = Invoke-ComWithRetry { $ppt.Presentations.Count }
        if ($presentationsCount -eq 0) {
            throw "No presentation open in PowerPoint"
        }

        $presentation = Invoke-ComWithRetry { $ppt.ActivePresentation }
        $totalSlides = [int](Invoke-ComWithRetry { $presentation.Slides.Count })
        $slideshowRunning = $false
        $currentSlide = 1

        $windowCount = 0
        try {
            $windowCount = [int](Invoke-ComWithRetry { $ppt.SlideShowWindows.Count })
        } catch {
            $windowCount = 0
        }

        # SlideShowWindows.Count can be stale directly after ESC, so probe windows defensively.
        if ($windowCount -gt 0) {
            for ($i = 1; $i -le $windowCount; $i++) {
                $candidateWindow = $null
                $candidateView = $null
                try {
                    $candidateWindow = Invoke-ComWithRetry { $ppt.SlideShowWindows[$i] }
                    $candidateView = Invoke-ComWithRetry { $candidateWindow.View }
                    try {
                        $candidateSlide = [int](Invoke-ComWithRetry { $candidateView.Slide.SlideIndex })
                    } catch {
                        $candidateSlide = [int](Invoke-ComWithRetry { $candidateView.CurrentShowPosition })
                    }
                    $slideShowView = $candidateView
                    $candidateView = $null
                    $currentSlide = $candidateSlide
                    $slideshowRunning = $true
                    break
                } catch {
                    # Try next slideshow window
                } finally {
                    Release-ComObject $candidateView
                    Release-ComObject $candidateWindow
                }
            }
        }

        # Edit mode fallback for current slide.
        if (-not $slideshowRunning) {
            try {
                $activeWindow = Invoke-ComWithRetry { $ppt.ActiveWindow }
                if ($activeWindow -and $activeWindow.View) {
                    $currentSlide = [int](Invoke-ComWithRetry { $activeWindow.View.Slide.SlideIndex })
                }
            } catch {
                $currentSlide = 1
            }
        }

        return [pscustomobject]@{
            Ppt = $ppt
            Presentation = $presentation
            TotalSlides = $totalSlides
            CurrentSlide = $currentSlide
            SlideShowRunning = $slideshowRunning
            SlideShowView = $slideShowView
        }
    } finally {
        Release-ComObject $activeWindow
    }
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "         PowerPoint Controller - AI Cafe Presenter             " -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

try {
    $listener.Start()
    Write-Host "[OK] Server running on http://localhost:$port" -ForegroundColor Green
    Write-Host ""
    Write-Host "Endpoints:" -ForegroundColor Yellow
    Write-Host "  GET  /auth-token   - Get browser session auth token" -ForegroundColor Gray
    Write-Host "  GET  /status       - Get presentation & slide info" -ForegroundColor Gray
    Write-Host "  GET  /slide-image  - Get current slide as PNG image" -ForegroundColor Gray
    Write-Host "  POST /start        - Start SlideShow from slide 1 (F5)" -ForegroundColor Gray
    Write-Host "  POST /start-current- Start from current slide (Shift+F5)" -ForegroundColor Gray
    Write-Host "  POST /stop         - Exit SlideShow (like ESC)" -ForegroundColor Gray
    Write-Host "  POST /next         - Next slide" -ForegroundColor Gray
    Write-Host "  POST /previous     - Previous slide" -ForegroundColor Gray
    Write-Host "  POST /goto?slide=N - Jump to slide N" -ForegroundColor Gray
    Write-Host "  POST /shutdown     - Stop this server" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Security:" -ForegroundColor Yellow
    Write-Host "  - Browser write endpoints require headers X-PPT-Client + X-PPT-Token" -ForegroundColor Gray
    Write-Host "  - Presenter gets token automatically via GET /auth-token" -ForegroundColor Gray
    Write-Host ("  - Allowed CORS origins: " + (($allowedCorsOrigins | Sort-Object) -join ", ")) -ForegroundColor Gray
    Write-Host ""
    Write-Host "Instructions:" -ForegroundColor Yellow
    Write-Host "  1. Keep this window open" -ForegroundColor Gray
    Write-Host "  2. Open PowerPoint presentation" -ForegroundColor Gray
    Write-Host "  3. Use AI Cafe Presenter to control slides" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Press Ctrl+C to stop" -ForegroundColor DarkGray
    Write-Host "----------------------------------------------------------------" -ForegroundColor DarkGray

    $shutdownRequested = $false

    while ($listener.IsListening -and -not $shutdownRequested) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        $requestMethod = if ([string]::IsNullOrWhiteSpace($request.HttpMethod)) { "<none>" } else { $request.HttpMethod }
        $requestPathForLog = if ($request.Url -and -not [string]::IsNullOrWhiteSpace($request.Url.LocalPath)) { $request.Url.LocalPath } else { "<unknown>" }

        # Loopback-only: reject connections from non-local addresses
        $remoteAddr = $request.RemoteEndPoint.Address
        $isLoopback = (
            [System.Net.IPAddress]::IsLoopback($remoteAddr) -or
            $remoteAddr.ToString() -eq "127.0.0.1" -or
            $remoteAddr.ToString() -eq "::1"
        )
        if (-not $isLoopback) {
            $timestamp = [DateTime]::Now.ToString('HH:mm:ss')
            Write-Host "[$timestamp] [!!] $($requestMethod.PadRight(6)) $($requestPathForLog.PadRight(14)) -> Rejected non-loopback: $($remoteAddr)" -ForegroundColor Red
            $response.StatusCode = 403
            $response.Close()
            continue
        }

        # CORS: allow only explicit local/browser origins
        $originHeader = $request.Headers["Origin"]
        $allowedCorsOrigin = Get-AllowedCorsOrigin $request
        if (-not [string]::IsNullOrWhiteSpace($originHeader)) {
            if ($allowedCorsOrigin) {
                $response.Headers.Add("Access-Control-Allow-Origin", $allowedCorsOrigin)
                $response.Headers.Add("Vary", "Origin")
                $response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
                $response.Headers.Add("Access-Control-Allow-Headers", "Content-Type, X-PPT-Client, X-PPT-Token")
            } else {
                Send-JsonResponse -response $response -statusCode 403 -payload @{
                    success = $false
                    message = "Origin not allowed"
                }
                $timestamp = [DateTime]::Now.ToString('HH:mm:ss')
                Write-Host "[$timestamp] [!!] $($requestMethod.PadRight(6)) $($requestPathForLog.PadRight(14)) -> Origin not allowed: $originHeader" -ForegroundColor Yellow
                continue
            }
        }

        # Handle OPTIONS preflight request
        if ($requestMethod -eq "OPTIONS") {
            $response.StatusCode = 200
            $response.Close()
            continue
        }

        $path = if ($request.Url) { $request.Url.LocalPath } else { "" }
        if ([string]::IsNullOrWhiteSpace($path)) {
            Send-JsonResponse -response $response -statusCode 400 -payload @{
                success = $false
                message = "Invalid request path"
            }
            $timestamp = [DateTime]::Now.ToString('HH:mm:ss')
            Write-Host "[$timestamp] [!!] $($requestMethod.PadRight(6)) <empty path>   -> Invalid request path" -ForegroundColor Yellow
            continue
        }

        # Enforce strict HTTP method per endpoint
        $allowedMethod = $endpointMethods[$path]
        if ($allowedMethod -and $requestMethod -ne $allowedMethod) {
            $response.Headers.Add("Allow", $allowedMethod)
            $methodMessage = "Method not allowed for $path. Use $allowedMethod."
            Send-JsonResponse -response $response -statusCode 405 -payload @{
                success = $false
                message = $methodMessage
            }
            $timestamp = [DateTime]::Now.ToString('HH:mm:ss')
            Write-Host "[$timestamp] [!!] $($requestMethod.PadRight(6)) $($path.PadRight(14)) -> $methodMessage" -ForegroundColor Yellow
            continue
        }

        # Header-bound auth for mutating browser requests
        $authFailure = Get-AuthFailureReason -request $request -path $path
        if ($authFailure) {
            Send-JsonResponse -response $response -statusCode 401 -payload @{
                success = $false
                message = $authFailure
            }
            $timestamp = [DateTime]::Now.ToString('HH:mm:ss')
            Write-Host "[$timestamp] [!!] $($requestMethod.PadRight(6)) $($path.PadRight(14)) -> $authFailure" -ForegroundColor Yellow
            continue
        }

        # /auth-token does not need PowerPoint
        if ($path -eq "/auth-token") {
            $tokenFailure = Get-TokenRequestFailureReason -request $request
            if ($tokenFailure) {
                Send-JsonResponse -response $response -statusCode 401 -payload @{
                    success = $false
                    message = $tokenFailure
                }
                $timestamp = [DateTime]::Now.ToString('HH:mm:ss')
                Write-Host "[$timestamp] [!!] $($requestMethod.PadRight(6)) /auth-token    -> $tokenFailure" -ForegroundColor Yellow
                continue
            }

            Send-JsonResponse -response $response -statusCode 200 -payload @{
                success = $true
                message = "Auth token issued"
                authClient = $pptClientId
                authToken = $pptAuthToken
            }
            $timestamp = [DateTime]::Now.ToString('HH:mm:ss')
            Write-Host "[$timestamp] [OK] GET  /auth-token    -> Token issued" -ForegroundColor Green
            continue
        }

        # /shutdown does not need PowerPoint
        if ($path -eq "/shutdown") {
            $timestamp = [DateTime]::Now.ToString('HH:mm:ss')
            Write-Host "[$timestamp] [OK] POST /shutdown   -> Server shutting down" -ForegroundColor Magenta
            Send-JsonResponse -response $response -statusCode 200 -payload @{
                success = $true
                message = "Server shutting down"
            }
            $shutdownRequested = $true
            continue
        }

        $state = $null
        $postState = $null

        try {
            $state = Get-PptState
            $currentSlide = $state.CurrentSlide
            $totalSlides = $state.TotalSlides
            $slideshowRunning = $state.SlideShowRunning

            if ($path -eq "/slide-image") {
                $slideNum = $currentSlide
                $requestedSlide = $request.QueryString["slide"]
                if ($requestedSlide) {
                    $slideNum = [int]$requestedSlide
                }

                if ($slideNum -lt 1 -or $slideNum -gt $totalSlides) {
                    Send-JsonResponse -response $response -statusCode 404 -payload @{
                        error = "Invalid slide number"
                    }
                    continue
                }

                $exportPath = Join-Path $tempDir "slide_$slideNum.png"
                Invoke-ComWithRetry { $state.Presentation.Slides[$slideNum].Export($exportPath, "PNG", 1920, 1080) }

                $imageBytes = [System.IO.File]::ReadAllBytes($exportPath)
                $response.ContentType = "image/png"
                $response.Headers.Add("Cache-Control", "no-cache")
                $response.Headers.Add("X-Content-Type-Options", "nosniff")
                $response.ContentLength64 = $imageBytes.Length
                $response.OutputStream.Write($imageBytes, 0, $imageBytes.Length)
                $response.Close()

                $timestamp = [DateTime]::Now.ToString('HH:mm:ss')
                Write-Host "[$timestamp] [OK] GET  /slide-image   -> Slide $slideNum ($([math]::Round($imageBytes.Length / 1024))KB)" -ForegroundColor Green
                continue
            }

            $result = @{
                success = $false
                message = ""
                currentSlide = $currentSlide
                totalSlides = $totalSlides
                slideshowRunning = $slideshowRunning
            }

            switch ($path) {
                "/status" {
                    $result.success = $true
                    $result.message = "Connected"
                    $result.presentationName = $state.Presentation.Name
                }
                "/start" {
                    if (Is-CommandThrottled $path) {
                        $result.success = $true
                        $result.message = "Duplicate /start suppressed"
                        break
                    }

                    if ($slideshowRunning) {
                        $result.success = $true
                        $result.message = "SlideShow already running"
                    } else {
                        $startResult = Start-PresentationSlideShow -ppt $state.Ppt -presentation $state.Presentation -startSlide 1
                        if ($startResult.Started) {
                            $result.success = $true
                            $result.slideshowRunning = $true
                            $result.currentSlide = $startResult.CurrentSlide
                            $result.totalSlides = $startResult.TotalSlides
                            $result.message = "SlideShow started"
                        } else {
                            # Keep PowerPoint in a known-good state for manual F5 fallback.
                            Reset-SlideShowSettings -presentation $state.Presentation
                            $result.success = $false
                            $result.slideshowRunning = $false
                            $result.currentSlide = 1
                            $result.message = "Start failed (no slideshow window created)"
                        }
                    }
                }
                "/start-current" {
                    if (Is-CommandThrottled $path) {
                        $result.success = $true
                        $result.message = "Duplicate /start-current suppressed"
                        break
                    }

                    if ($slideshowRunning) {
                        $result.success = $true
                        $result.message = "SlideShow already running"
                    } else {
                        $startSlide = $currentSlide
                        $startResult = Start-PresentationSlideShow -ppt $state.Ppt -presentation $state.Presentation -startSlide $startSlide
                        if ($startResult.Started) {
                            $result.success = $true
                            $result.slideshowRunning = $true
                            $result.currentSlide = $startResult.CurrentSlide
                            $result.totalSlides = $startResult.TotalSlides
                            $result.message = "SlideShow started from slide $startSlide"
                        } else {
                            # Keep PowerPoint in a known-good state for manual F5 fallback.
                            Reset-SlideShowSettings -presentation $state.Presentation
                            $result.success = $false
                            $result.slideshowRunning = $false
                            $result.currentSlide = $startSlide
                            $result.message = "Start-current failed (no slideshow window created)"
                        }
                    }
                }
                "/stop" {
                    if (Is-CommandThrottled $path) {
                        $result.success = $true
                        $result.message = "Duplicate /stop suppressed"
                        break
                    }

                    if ($slideshowRunning -and $state.SlideShowView) {
                        Invoke-ComWithRetry { $state.SlideShowView.Exit() | Out-Null }

                        $stopped = $false
                        for ($i = 0; $i -lt 7; $i++) {
                            Start-Sleep -Milliseconds 120
                            if ($postState) {
                                Release-PptState $postState
                                $postState = $null
                            }
                            $postState = Get-PptState
                            if (-not $postState.SlideShowRunning) {
                                $stopped = $true
                                break
                            }
                        }

                        $result.success = $true
                        $result.slideshowRunning = if ($postState) { $postState.SlideShowRunning } else { $false }
                        $result.currentSlide = if ($postState) { $postState.CurrentSlide } else { $currentSlide }
                        $result.totalSlides = if ($postState) { $postState.TotalSlides } else { $totalSlides }
                        $result.message = if ($stopped) { "SlideShow stopped" } else { "Stop requested (still shutting down)" }
                    } else {
                        $result.success = $true
                        $result.message = "No SlideShow running"
                        $result.slideshowRunning = $false
                    }
                }
                "/next" {
                    if ($slideshowRunning -and $state.SlideShowView) {
                        Invoke-ComWithRetry { $state.SlideShowView.Next() | Out-Null }
                        try {
                            $result.currentSlide = [int](Invoke-ComWithRetry { $state.SlideShowView.Slide.SlideIndex })
                        } catch {
                            $result.currentSlide = [int](Invoke-ComWithRetry { $state.SlideShowView.CurrentShowPosition })
                        }
                    } else {
                        $nextSlide = [math]::Min($currentSlide + 1, $totalSlides)
                        Set-EditModeSlide -ppt $state.Ppt -slideNum $nextSlide
                        $result.currentSlide = $nextSlide
                    }
                    $result.success = $true
                    $result.message = "Next slide"
                }
                "/previous" {
                    if ($slideshowRunning -and $state.SlideShowView) {
                        Invoke-ComWithRetry { $state.SlideShowView.Previous() | Out-Null }
                        try {
                            $result.currentSlide = [int](Invoke-ComWithRetry { $state.SlideShowView.Slide.SlideIndex })
                        } catch {
                            $result.currentSlide = [int](Invoke-ComWithRetry { $state.SlideShowView.CurrentShowPosition })
                        }
                    } else {
                        $prevSlide = [math]::Max($currentSlide - 1, 1)
                        Set-EditModeSlide -ppt $state.Ppt -slideNum $prevSlide
                        $result.currentSlide = $prevSlide
                    }
                    $result.success = $true
                    $result.message = "Previous slide"
                }
                "/goto" {
                    $slideNum = [int]$request.QueryString["slide"]
                    if ($slideNum -ge 1 -and $slideNum -le $totalSlides) {
                        if ($slideshowRunning -and $state.SlideShowView) {
                            Invoke-ComWithRetry { $state.SlideShowView.GotoSlide($slideNum) | Out-Null }
                        } else {
                            Set-EditModeSlide -ppt $state.Ppt -slideNum $slideNum
                        }
                        $result.success = $true
                        $result.message = "Jumped to slide $slideNum"
                        $result.currentSlide = $slideNum
                    } else {
                        $result.message = "Invalid slide number (1-$totalSlides)"
                    }
                }
                default {
                    $result.message = "Unknown endpoint: $path"
                }
            }

            $json = $result | ConvertTo-Json -Compress
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($json)
            $response.ContentType = "application/json; charset=utf-8"
            $response.Headers.Add("X-Content-Type-Options", "nosniff")
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.Close()

            $timestamp = [DateTime]::Now.ToString('HH:mm:ss')
            $status = if ($result.success) { "[OK]" } else { "[!!]" }
            $color = if ($result.success) { "Green" } else { "Yellow" }
            Write-Host "[$timestamp] $status $($request.HttpMethod.PadRight(4)) $($path.PadRight(14)) -> $($result.message) (slide $($result.currentSlide)/$($result.totalSlides), running=$($result.slideshowRunning))" -ForegroundColor $color
        }
        catch {
            $friendlyMsg = Get-FriendlyErrorMessage $_.Exception
            # Keep 200 for compatibility with existing clients that parse success=false payloads.
            Send-JsonResponse -response $response -statusCode 200 -payload @{
                success = $false
                message = $friendlyMsg
            }

            $timestamp = [DateTime]::Now.ToString('HH:mm:ss')
            Write-Host "[$timestamp] [!!] $($request.HttpMethod.PadRight(4)) $($path.PadRight(14)) -> $friendlyMsg" -ForegroundColor Yellow
        }
        finally {
            Release-PptState $postState
            Release-PptState $state
        }
    }
}
catch {
    Write-Host "Error starting server: $_" -ForegroundColor Red
    Write-Host "Port $port might be in use. Try closing other instances." -ForegroundColor Yellow
}
finally {
    try {
        if ($listener -and $listener.IsListening) {
            $listener.Stop()
        }
        if ($listener) {
            $listener.Close()
        }
    } catch {
        # Ignore listener cleanup errors
    }
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host ""
    Write-Host "Server stopped" -ForegroundColor Red
}
