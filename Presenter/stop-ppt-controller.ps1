param(
    [int]$Port = 8765,
    [switch]$Silent
)

function Write-Log {
    param(
        [string]$Message,
        [string]$Color = "Gray"
    )
    if (-not $Silent) {
        Write-Host $Message -ForegroundColor $Color
    }
}

$baseUrl = "http://localhost:$Port"
$selfPid = $PID

try {
    Invoke-RestMethod -Uri "$baseUrl/shutdown" -Method Post -TimeoutSec 2 | Out-Null
    Write-Log "[OK] Shutdown request sent to $baseUrl/shutdown" "Green"
    Start-Sleep -Milliseconds 700
} catch {
    Write-Log "[..] Controller API not reachable on port $Port (or already stopped)" "DarkGray"
}

$controllerProcs = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -eq "powershell.exe" -and
    $_.ProcessId -ne $selfPid -and
    $_.CommandLine -match "ppt-controller\.ps1"
}

foreach ($proc in $controllerProcs) {
    try {
        Stop-Process -Id $proc.ProcessId -Force -ErrorAction Stop
        Write-Log "[OK] Stopped stale controller process PID $($proc.ProcessId)" "Yellow"
    } catch {
        Write-Log "[!!] Could not stop PID $($proc.ProcessId): $($_.Exception.Message)" "Red"
    }
}

$listeners = @()
try {
    $listeners = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction Stop
} catch {
    $listeners = @()
}

foreach ($listener in $listeners) {
    $owner = Get-CimInstance Win32_Process -Filter "ProcessId=$($listener.OwningProcess)" -ErrorAction SilentlyContinue
    if ($owner -and $owner.CommandLine -match "ppt-controller\.ps1") {
        try {
            Stop-Process -Id $listener.OwningProcess -Force -ErrorAction Stop
            Write-Log "[OK] Killed lingering listener PID $($listener.OwningProcess) on port $Port" "Yellow"
        } catch {
            Write-Log "[!!] Could not kill lingering listener PID $($listener.OwningProcess): $($_.Exception.Message)" "Red"
        }
    } else {
        $ownerName = if ($owner) { $owner.Name } else { "unknown" }
        Write-Log "[!!] Port $Port is held by PID $($listener.OwningProcess) ($ownerName). Not killing unrelated process." "Yellow"
    }
}

Start-Sleep -Milliseconds 300

$stillListening = @()
try {
    $stillListening = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction Stop
} catch {
    $stillListening = @()
}

if ($stillListening.Count -eq 0) {
    Write-Log "[OK] Port $Port is free" "Green"
    exit 0
}

Write-Log "[!!] Port $Port is still in use" "Red"
exit 1
