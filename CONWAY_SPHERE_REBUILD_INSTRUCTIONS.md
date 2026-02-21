# Rebuilding Conway's Game of Life — Sphere Edition

## Iterative Prompting with AI Code Assistant

---

## Goal

Rebuild a fully functional single-file HTML application that runs Conway's Game of Life on a 3D sphere, complete with a meteor system, interactive controls, and a dark futuristic UI — entirely through conversational prompting.

The application features:
- A **400×200 cell grid** mapped onto a Three.js sphere with spherical polar topology
- **Meteor rain** that delivers Game of Life patterns from deep space onto the sphere surface
- A comprehensive **control panel** with simulation, camera, appearance, and color controls
- **WebGL context loss recovery** and crash diagnostics for production robustness

**Important:** Each prompt is designed to be **strictly additive**. Subsequent prompts extend the code from previous prompts without rewriting or replacing existing functionality. This prevents token waste and ensures stable incremental construction.

---

## Tools Required

- **Visual Studio Code** (VS Code) or any code editor
- **AI Code Assistant** (GitHub Copilot, Claude, etc.) in chat/agent mode
- A modern web browser (Chrome/Edge recommended for WebGL2)

---

## Structure

| Phase | Description |
|-------|-------------|
| Prompt 1 | Foundation: HTML/CSS, GoL engine, Three.js sphere, basic UI |
| Prompt 2 | Visual system: texture rendering, colors, glow, shading |
| Prompt 3 | Meteor system: physics, trails, impacts, overlay |
| Prompt 4 | Interactions: context menu, wipe mode, layout intelligence |
| Prompt 5 | Robustness: WebGL recovery, crash logging, performance caps |

---

## The Prompts

### Prompt 1: Foundation — Structure, Engine, 3D Scene, Basic UI

**Goal:** Create the complete HTML/CSS skeleton, the Conway's Game of Life engine with spherical topology, the Three.js 3D scene with sphere and wireframe, and the basic simulation controls.

```
Create a single HTML file called "conway-sphere.html" — Conway's Game of Life running on a 3D sphere.

TECHNOLOGY:
- Single HTML file, all CSS and JS embedded (no external files except Three.js CDN)
- Three.js r128 from CDN: https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js
- Google Fonts: Orbitron (headings) and Rajdhani (body text)
- No other external dependencies

DESIGN — DARK FUTURISTIC THEME:
- CSS variables: --bg:#0a0a0f, --panel:rgba(12,12,22,0.30), --bdr:rgba(0,255,200,0.22), --cyan:#00ffc8, --mag:#ff00aa, --yel:#e6ff00, --txt:#d8e4f0, --txt2:#92a4b8
- Panels use backdrop-filter:blur(16px) with semi-transparent backgrounds
- Buttons: .btn base class with hover glow, .btn.on (active/cyan), .btn.p (primary/cyan), .btn.d (danger/magenta)
- Sliders: custom styled with cyan thumb (14px round) and thin track
- Toggles: custom 36×20px toggle switches with cyan glow when checked
- Select dropdowns: custom styled with SVG chevron arrow

HTML STRUCTURE:
1. #topbar — fixed top bar (height: 78px):
   - Left: h1 "CONWAY'S LIFE · SPHERE" with gradient text (cyan→magenta)
   - Center: #mStats div (for meteor stats later, leave empty)
   - Right: #stats with Gen/Pop/Alive counters (tabular-nums, cyan values)

2. #panel — fixed left sidebar (width: 272px, top: 88px):
   Contains sections (.sec) separated by border-bottom:

   Section "Simulation":
   - 4-column grid (.sim-actions): Play ▶/⏸, Step ⏗, Clear ✕ (danger), Wipe ◯
   - Below: Export Crash Log ⇙ and Clear Crash Log 🗑 buttons
   - Sliders: Wipe Radius (3-40, default 10), Speed (1-60 gen/s, default 2)
   - Toggle: Meteor Rain (checked by default)
   - Sliders: Meteor Interval (2-15s, default 14 → maps inversely to 3s actual), Meteor Speed (10-150 → /100, default 0.1)

   Section "Initial State":
   - Dropdown #selPat with optgroups: Random Seeds (15%/30%/50%), Still Lifes (Block/Beehive/Loaf/Tub/Boat/Ship/Pond), Oscillators (Blinker/Toad/Beacon/Clock/Pulsar/Pentadecathlon/Figure Eight/Tumbler), Spaceships (Glider/LWSS/MWSS/HWSS/Copperhead), Guns (Gosper Glider Gun), Methuselahs (R-Pentomino/Acorn/Diehard/Thunderbird/π-Heptomino/B-Heptomino), Infinite Growth (I/II), Superclass (Total Aperiodic)
   - Buttons: Apply (primary), Randomize 🎲
   - Slider: Pattern Copies (1-40, default 8)

   Section "Camera":
   - Slider: Zoom Distance (1.5-8.0, slider 15-80, default 4.0)
   - Toggle: Auto-Rotate (checked)
   - Slider: Rotation Speed (0.1-3.0, slider 1-30, default 0.1)

   Section "Appearance":
   - Slider: Emissive Glow (0-1.0, default 1.0)
   - Toggle: Grid Dots (checked)
   - Slider: Dot Size (0.3-2.5, slider 3-25, default 0.8)
   - Slider: Cell Exposure (-100 to +100, default +100)
   - Slider: Cell Saturation (-100 to +100, default +100)
   - Slider: Day/Night Strength (0-200, default 100 → 50%)
   - Toggle: Cell Glow (checked)
   - Sliders: Glow Radius (1-20, default 5), Glow Intensity (0.1-1.0, slider 10-100, default 0.1)
   - Toggle: Wireframe (checked)
   - Slider: Wire Exposure (1-80, default 30)

   Section "Colors":
   - 5 color picker rows (.cpr): Alive (#00ffc8), Born (#ff00aa), Dead/BG (#0a0a14), Grid Dots (#0066ff), Impact (#4488ff)
   - Each row: label + color input + intensity range (10-100 or 0-100) + value display
   - Preset Themes dropdown: Cyan & Magenta, Green & Orange, Blue & Yellow, Purple & Green, Fire, Ocean, Matrix

3. #ctxMenu — fixed, hidden context menu (for later)
4. #impactOverlay — fixed overlay container (for later)
5. #golRules — fixed bottom-right rules card (Conway's 3 rules), initially hidden
6. #foot — fixed bottom center: keyboard hints

GAME OF LIFE ENGINE:
- Grid: W=400, H=200, TOTAL=W*H
- Arrays: grid (Uint8Array), buf (Uint8Array), age (Float32Array)
- Spherical polar topology function ix(x,y): when y<0 → reflect y=-y-1 and x+=W/2; when y>=H → reflect y=2*H-1-y and x+=W/2; x always wraps modulo W
- Neighbor count nb(x,y): standard 8-neighbour Moore neighborhood using ix()
- step(): B3/S23 rules. age: alive→min(age+1,80), newborn→0, just-died→-1, dead→min(age,-1)
- clear(): zero everything, reset gen/pop, stop simulation
- Pattern dictionary PAT: define all patterns as coordinate arrays [x,y]:
  block, beehive, loaf, tub, boat, ship, pond, blinker, toad, beacon, pulsar (computed), penta, glider, lwss, mwss, hwss, gosper (glider gun), rpent, acorn, diehard, thunderbird, piHept, bhept, copperhead, inf1, inf2, figureEight, tumbler, totalAperiodic (182 cells — full coordinate list needed)
- place(key,cx,cy): stamp pattern at position
- rotatePatternOffsets(pat,angle): rotate in 90° steps
- placeRandomOriented(key,cx,cy,angle,spawnAge): place with random rotation
- applyPat(): clear + scatter Pattern Copies of selected pattern (or fill random density)
- randomize(): clear + random 12-40% fill
- Pattern display names dictionary PAT_NAMES

THREE.JS SCENE:
- Scene with background color 0x0a0a0f
- PerspectiveCamera(50, aspect, 0.1, 100) at z=3
- WebGLRenderer: try creating with {antialias:false,powerPreference:'default'}, fallback to {antialias:false,powerPreference:'low-power'}, then {antialias:true,powerPreference:'default'}
- Pixel ratio: cap at 1.25 max, budget by MAX_DRAW_PIXELS=2560*1440
- Main sphere: SphereGeometry(1, 64, 32), MeshStandardMaterial with texture map + emissive map, roughness:0.55, metalness:0.15, transparent, opacity:0.84
- Texture: canvas-based (TW=W*10, TH=H*10), pole distortion correction with poleStretch/poleCellH arrays based on sin(theta)
- Back-face sphere: same geometry, MeshBasicMaterial, BackSide, additive blending, opacity:0.15
- Wireframe: custom LineSegments (48 longitude × 24 latitude), ShaderMaterial with view-angle fade (front-facing bright, edges transparent)
- Stars: 1500 random points in 60-unit cube, PointsMaterial size:0.04, color:#334455
- Lights: AmbientLight(#222233, 0.4), 3 PointLights — cyan(3,2,3), magenta(-3,-1,2), blue(0,3,-2)

ROTATION & ZOOM:
- Quaternion-based rotation (rotQ)
- Left-drag: manual rotate sphere
- Right-drag: adjust rotation axis direction
- Auto-rotate: slowly drift axis direction, lerp toward random targets every 2-8s
- Mouse wheel zoom (1.5-8.0 range)
- Touch pinch zoom support

BASIC TEXTURE (simplified for now):
- Render alive cells as solid color, dead cells as transparent (alpha=0)
- Pole correction: cells near poles get reduced height (poleCellH = round(TEX_SCALE * sin(theta)))
- Born cells (age=0) use Born color, older alive cells use Alive color
- CanvasTexture with RepeatWrapping on S, ClampToEdge on T, LinearFilter, no mipmaps

BASIC UI WIRING:
- Play/Pause toggle, Step, Clear, Apply, Randomize buttons
- All sliders update their value displays and call save()
- save()/load() persist all settings to localStorage key 'cl-gol2'
- Format numbers: <1M → toLocaleString, <1B → "1.23M", etc.
- Stats: update Gen/Pop/Alive% on each step

MAIN LOOP:
- requestAnimationFrame loop
- Clamp dt to 100ms max
- Tick simulation at 1000/speed ms intervals
- Auto-rotate when enabled and not dragging
- Smooth camera zoom lerp
- Render at capped framerate (24 fps idle, 45 fps when meteors active — prepare the constants but meteors come in Prompt 3)

RESPONSIVE:
- Mobile (≤768px): panel moves to bottom, no footer, smaller topbar text
- Use dvh units for height
```

**Expected Result:**
- A dark-themed single HTML file with Conway's Game of Life on a 3D sphere
- Left control panel with all sections and controls
- Sphere rotates, zooms, displays alive/dead cells
- Play/Pause/Step/Clear simulation controls work
- Pattern selector with 30+ patterns and Apply/Randomize
- Settings persist in localStorage

---

### Prompt 2: Visual Refinements — Texture Rendering, Colors, Shading

**Goal:** Enhance the texture rendering pipeline with cell borders, gloss effects, cell glow bloom, exposure/saturation adjustments, day/night hemisphere shading, and the full color system with presets. This prompt only modifies the `updTex()` function and adds shader uniforms — it does not touch the engine or scene structure.

```
Enhance the visual rendering of the existing conway-sphere.html. Do NOT change the GoL engine, scene structure, or HTML. Only modify/extend the texture rendering and color-related code.

CELL BORDERS (in updTex):
- Alive cells: draw at TEX_SCALE×poleCellH[y] pixels
- Border pixels (top/bottom rows + left/right columns): brightness +35 on each RGB channel
- Interior pixels: base color

CELL GLOSS (per-cell micro-shading):
- Pre-compute gloss masks per cellH value (cache in cellGlossCache[]):
  - "hi" mask: top-right highlight, elliptical falloff center (u=0.74, v=0.30), cubed falloff × CELL_GLOSS_HI_STRENGTH=0.12
  - "sh" mask: bottom-left shadow, center (u=0.28, v=0.76), squared falloff × CELL_GLOSS_SH_STRENGTH=0.05
- Apply per-pixel: color = color*(1-sh) then color = color + (255-color)*hi
- On border pixels: reduce both effects by 0.70-0.72

CELL EXPOSURE:
- Variable cellExposure, slider maps value/6.25
- Compute L = (r+g+b)/3; if L>0.5: Ln = L * pow(2, cellExposure), scale RGB proportionally, clamp to 255

CELL SATURATION:
- Variable cellSaturation, slider maps value/100
- L = 0.299*r + 0.587*g + 0.114*b, then each channel = L + (channel-L) * (1+cellSaturation), clamped 0-255

DAY/NIGHT HEMISPHERE SHADING:
- Implement as a custom shader modification on sphMat (via onBeforeCompile):
  - Add uniforms: uDayNightStrength (float), uDayLightDir (vec3, normalized (0.62, 0.54, 0.57)), uDayGain (0.42), uNightGain (0.34)
  - In fragment shader, after computing outgoingLight:
    _dnH = dot(normalize(normal), normalize(uDayLightDir))
    _dnDay = max(_dnH, 0) * uDayGain * uDayNightStrength
    _dnNight = max(-_dnH, 0) * uNightGain * uDayNightStrength
    finalColor = color*(1-_dnNight) + (1-color)*_dnDay
- Slider "Day/Night Strength" controls uDayNightStrength uniform

CELL GLOW (bloom aura):
- Two extra canvases at base resolution (W×H): glowSrc, glowDst
- In updTex after main rendering: write alive cells as bright, dead as transparent to glowImg
- Apply CSS-style blur (filter: 'blur(Npx)' where N = glowRadius*3.0)
- Boost passes: ceil(blurPx/6)-1 additive self-composites to compensate blur energy loss
- Composite onto main texture with 'lighter' blend mode at alpha = min(1, glowIntensity*2)

GRID DOTS (cross markers):
- Draw at wireframe intersection points (_wSegsW×_wSegsH grid)
- Only on dead cells (skip alive cells)
- Use 'destination-over' compositing (behind everything else)
- Cross pattern: 4 arms with armLen = max(2, dotRadius*TEX_SCALE), tip-fade over last 3px
- Horizontal arms stretched by 1/sin(theta) to compensate pole distortion
- Center: bright white dot (alpha 0.85), radius = armLen*0.15

COLOR PRESETS (PRESETS object):
- cm (Cyan & Magenta): alive:#00ffc8, born:#ff00aa, dead:#0a0a14, dots:#0066ff
- go (Green & Orange): alive:#39ff14, born:#ff6a00, dead:#0a100a, dots:#0044ff
- by (Blue & Yellow): alive:#00aaff, born:#ffd500, dead:#0a0a14, dots:#0055ff
- pg (Purple & Green): alive:#bf00ff, born:#39ff14, dead:#100a14, dots:#0066ff
- fi (Fire): alive:#ff5000, born:#ffdc00, dead:#140804, dots:#0044cc
- oc (Ocean): alive:#00c8ff, born:#00ffb4, dead:#040814, dots:#0055ff
- mx (Matrix): alive:#00ff41, born:#96ff96, dead:#000800, dots:#003388
- applyPreset() sets all 4 color pickers + updates texture + saves

COLOR PICKER WIRING:
- Each of the 5 color rows (Alive/Born/Dead/Dots/Impact): listen on both color input and intensity slider
- Impact color changes also update active meteor colors and impact overlay cards (prepare hooks but meteor system comes in Prompt 3)

DEAD CELL TRANSPARENCY:
- Dead cells: alpha=0 (fully transparent, discarded by sphere material)
- Alive cells: alpha=255 (opaque)
- This makes the sphere show-through effect work with the back-face sphere
```

**Expected Result:**
- Alive cells have visible borders and subtle 3D gloss shading
- Cell glow creates a neon bloom aura around living cells
- Exposure/saturation sliders visibly affect cell appearance
- Day/night shading creates hemisphere lighting on the sphere
- Grid dots appear as cross markers on dead cells
- Color presets instantly switch the entire color scheme
- All 5 color pickers with intensity control work live

---

### Prompt 3: Meteor System — Physics, Trails, Impacts, Overlay

**Goal:** Add the complete meteor rain system: spawning, gravity physics, visual trails, surface impact with pattern placement, impact shockwave rings, impact overlay cards, and meteor statistics. This prompt adds new code and hooks into existing texture/scene — it does not rewrite the engine or visuals.

```
Add a complete meteor system to the existing conway-sphere.html. Do NOT rewrite the engine, texture, or scene code — only ADD new meteor-related code and hook into existing functions.

METEOR PATTERN POOL:
- METEOR_PATS array: glider, blinker, toad, beacon, clock, lwss, rpent, acorn, thunderbird, piHept, bhept, boat, ship, block, beehive, pulsar, figureEight, totalAperiodic
- Special variants: Nuke (NUKE_SPAWN_CHANCE=0.01, 1% chance) and Super Nuke (SUPER_NUKE_SPAWN_CHANCE=0.005, 0.5%)
- Nuke: wipes circular area (radius=24 cells), color RGB(255,56,0)
- Super Nuke: wipes 90% of sphere surface (spherical cap), color RGB(255,0,196), travels at 0.5× speed, 2× visual size
- Superclass patterns (totalAperiodic): special color RGB(0,220,255)

BRAILLE PATTERN SYMBOLS:
- patternToBraille(patKey): renders each pattern as Unicode braille art (max 10×4 grid)
- Scale pattern to fit, map filled cells to braille dots (2×4 dot matrix per character, Unicode 0x2800+bits)
- Special symbols: nuke→☠(U+2620), superNuke→☢(U+2622), totalAperiodic→Ⓢ(U+24C8)
- Append braille symbols to dropdown option text on init

METEOR ARRAYS:
- meteorAge (Float32Array, TOTAL): flash intensity per cell (1.0 at impact, decays per generation)
- meteorFlashMark (Uint8Array) + meteorFlashIdx (array): sparse tracking of active flash cells
- METEOR_FLASH_DECAY_PER_GEN = 1/7, decay per step

METEOR VISUALS (Three.js objects):
- Head: SphereGeometry(0.008, 16, 12), MeshBasicMaterial white, opacity 0.92
  - Child sprites: tip glow (0.026 scale), core glow (0.082 scale, additive blending), outer glow (0.32 scale)
  - Glow texture: 64×64 canvas with radial gradient (white core → blue mid → transparent)
- Trail: ribbon mesh (72 segments), custom ShaderMaterial:
  - Vertex: pass UV
  - Fragment: texture lookup, side fade (pow(side, 1.55)), along-length fade (pow(1-v, 1.22)), core brightening (lerp toward white)
  - DoubleSide, additive blending, depthWrite:false
- Trail ribbon geometry: per-segment billboard facing camera, width tapers from head to tail (pow(1-f, 0.58))
- Object pooling: acquireMeteorVisual() / releaseMeteorVisual() with meteorPool array

METEOR PHYSICS:
- Gravitational constant G=2.5
- Spawning: random direction biased toward camera-visible hemisphere and right side of screen
  - Origin distance: 3.5-5.5 units from center
  - Initial velocity: toward center at below-escape-velocity speed, small perpendicular deviation
- Physics tick at fixed 60Hz (METEOR_UPDATE_INTERVAL=1/60):
  - Symplectic Euler: acceleration = -G/r² toward center
  - Update velocity then position
  - Trail densification: insert up to 12 intermediate points to avoid dotted look
- Impact detection: when distance from center ≤ 1.005 or age > 15s
  - Interpolate exact surface crossing point
  - surfaceToGrid(worldPt): inverse of UV mapping — quaternion-inverse, then atan2/acos to get grid coords
  - Normal patterns: place with random orientation, set meteorAge[i]=1.0 for flash effect
  - Nuke: circular wipe (radius 24)
  - Super Nuke: spherical cap wipe (90% kill fraction via cos(theta) threshold)
- Max active meteors: 16 (BASE_MAX_ACTIVE_METEORS)

METEOR INTERVAL (inverted slider):
- Slider range 2-15, but maps inversely: meteorIntervalFromSlider(raw) = MIN + MAX - raw
- So slider left = slow (long interval), slider right = fast (short interval)
- Actual spawn timing: randomized around interval (0.45× to 1.55× of set value)

IMPACT SHOCKWAVE RINGS (in updTex):
- On impact: push ring {cx, cy, t:0, color, bornBeat:1}
- Each frame: ring.t += dt; remove at t > 1.6
- Render on texture at TEX_SCALE resolution:
  - First beat (t<0.12): born-color flash
  - Expanding ring: radius = t*40*S, width = max(1, 4.5-t*2.5)*S, opacity fading
  - Secondary ring at t>0.12: slightly delayed, thinner, dimmer
  - Center flash (t<0.6): bright white core + colored outer disc, fading
  - Wrap horizontally: draw at cx-TW, cx, cx+TW for seamless wrapping

METEOR FLASH IN TEXTURE:
- In updTex, if meteorAge[i]>0 on alive cells: blend toward Born color proportionally
- In step(): call decayMeteorFlashByGenerations(1) — subtract METEOR_FLASH_DECAY_PER_GEN from all tracked cells

IMPACT OVERLAY (DOM-based):
- impactSlots array: each {patKey, timer, num, el} or null
- impactNum: running counter
- Adaptive timer: 7s when space available, 4s when tight, 2s when critical
- makeImpactCard(patKey, num, useBorn):
  - Canvas IMP_CVS_W × IMP_CVS_H (precomputed from largest non-superclass pattern)
  - IMP_CELL=6px per cell, IMP_PAD=2 cells padding
  - Normal patterns: dark glow rect (-1px) + bright inner rect (+1px), centered
  - Special (nuke/superNuke/superclass): large symbol rendering with glow shadow
  - Number label on top, pattern name + braille symbol on bottom
  - Border + box-shadow colored to match
- Per-slot fade: opacity decreases during last 1.0s of timer
- Born beat: first 0.22s uses born-color, then switches to impact-color
- trimOverlay(): remove trailing empty placeholders
- Grid layout: repeat(cols, auto), max 4 columns

METEOR STATS (topbar #mStats):
- meteorStats object: count per pattern key
- updMeteorStats(): show "Impacts: N" + top 6 patterns (nukes pinned first)
- Color-coded by pattern type (nuke colors, impact color for normal)

METEOR UI WIRING:
- Meteor Rain toggle, Interval slider, Speed slider
- Connect to existing save()/load()

VISUAL INTERPOLATION:
- updateMeteorVisuals(interp, frameDt): interpolate position between physics ticks
- Behind-sphere dimming: visFactor based on dot product with camera direction (8-30% when behind)
- Scale head/glow/tip/core by visFactor
```

**Expected Result:**
- Meteors spawn from deep space and fall toward the sphere with visible trails
- Impact creates shockwave rings, places patterns on sphere, shows overlay card
- Nuke meteors wipe areas, Super Nukes wipe 90% of the sphere
- Impact overlay shows pattern icons with fade-out animation
- Meteor stats appear in the topbar
- Braille pattern symbols appear in dropdown and overlay

---

### Prompt 4: Advanced Interactions — Context Menu, Wipe, Layout Intelligence

**Goal:** Add right-click pattern placement, wipe mode with custom cursor, dynamic camera centering that accounts for UI panels, rules overlay with collision detection, and touch support. This prompt adds interaction handlers and layout logic — it does not change the engine or rendering.

```
Add advanced interaction systems to the existing conway-sphere.html. Do NOT rewrite existing code — only ADD new interaction handlers and layout intelligence.

RIGHT-CLICK CONTEXT MENU:
- On right-click on sphere: raycast to find UV coordinates, convert to grid position via uvToGrid(uv)
- Show #ctxMenu at click position (clamped to viewport)
- Menu structure: categories (Still Lifes, Oscillators, Spaceships, Guns, Methuselahs, Infinite Growth, Superclass)
- Each item shows braille symbol + label
- On click: place pattern at raycasted grid position with random orientation, update texture/stats, hide menu
- Hide on: click outside, Escape key, or any pointerdown outside menu
- uvToGrid(uv): x = floor(uv.x * W) % W, y = floor((1-uv.y) * H) % H

WIPE MODE:
- Toggle with Wipe button, tracks wipeMode boolean
- Custom skull cursor: render ☠ emoji onto 40×40 canvas with layered glow effects:
  1. Outer mystical aura: purple (rgba(160,0,255,0.9)), blur 12px, low opacity
  2. Inner skull: hot pink glow (rgba(255,50,200,0.8)), blur 6px, medium opacity
  3. Final crisp pass: near-white, no blur
  - Convert to data URL cursor with hotspot (20,20)
- Wipe interaction:
  - pointerdown in wipe mode: start wiping, doWipe at cursor position
  - pointermove while wiping: continuous doWipe
  - pointerup: commit wipe visuals (update texture/stats)
- doWipe(cx,cy): raycast to sphere UV, convert to grid, erase circular area (radius=wipeRadius)
  - Set grid[i]=0, age[i]=min(age,-1), meteorAge[i]=0, meteorFlashMark[i]=0
  - Throttle visual updates to 30fps (WIPE_VISUAL_INTERVAL=1000/30)

DYNAMIC CAMERA CENTERING:
- updateCameraCenter(): offset the camera projection so the sphere appears centered in the usable viewport area
- Account for: topbar height, left panel width (desktop), bottom panel (mobile), impact overlay width, rules card width
- Only shift when UI intrudes past the viewport center (leftInset/rightInset from half-width)
- Modify camera.projectionMatrix.elements[8] and [9] for NDC offset
- Call on: every render frame, window resize, visualViewport changes

IMPACT OVERLAY POSITIONING:
- computeOverlayCapacity(): calculate how many columns/rows of impact cards fit RIGHT of the sphere
  - Project sphere center + radius to screen coordinates via worldToScreen()
  - Available width = viewport right - sphere right edge - gap(16px) - margin(10px)
  - Determine columns (4→3→2→1→0) based on card width
  - Max rows from available height (topbar bottom to footer top)
- positionImpactOverlay(): place overlay right-aligned, top = below topbar
  - Accelerate fade on excess slots when more active than maxSlots
  - If no space at all: hide overlay and rapidly expire all active slots (timer→0.15)
  - Update CSS gridTemplateColumns

RULES OVERLAY (Conway's rules card):
- #golRules: fixed bottom-right, backdrop-blur, shows the 3 GoL rules
- Collision-aware visibility: hide when overlapping sphere, panel, topbar, footer, ctxMenu, or impactOverlay
- circleRectOverlap(cx, cy, radius, rect, pad=6): sphere-circle vs rect collision
- rectsOverlap(a, b, pad=0): rect vs rect collision
- Anti-flicker: _rulesShowLock (0.25s delay after each state change before showing again)
- Smooth fade: _rulesOpacity animated at RULES_FADE_IN_PER_SEC=2.4, RULES_FADE_OUT_PER_SEC=5.5
- Apply opacity and visibility CSS, call tickRulesLock() per frame

TOUCH SUPPORT:
- touchstart: track 2-finger pinch distance
- touchmove: compute new distance, adjust zoom proportionally (delta * 0.01)
- Update zoom slider value on touch zoom
- Use {passive:true} for touch listeners

LAYOUT OBSERVERS:
- ResizeObserver on topbar, panel, foot, golRules, impactOverlay → refreshLayoutNow()
- visualViewport resize/scroll → refreshLayoutNow()
- Window resize → applyRendererResolution() + refreshLayoutNow()
```

**Expected Result:**
- Right-click on sphere shows pattern menu, clicking places pattern
- Wipe mode: skull cursor, click-drag erases cells
- Sphere stays visually centered even with panel and overlay visible
- Rules card appears when there's space, fades out when overlapped
- Touch pinch zoom works on mobile
- Layout adapts to all viewport sizes

---

### Prompt 5: Robustness — WebGL Recovery, Crash Logging, Performance

**Goal:** Add production-grade resilience: WebGL context loss handling with progressive degradation, crash diagnostics logging with export, performance throttling, and clean shutdown. This prompt wraps the existing code with safety infrastructure — it does not change any core logic.

```
Add robustness and production resilience to the existing conway-sphere.html. Do NOT change core engine or rendering logic — only ADD safety wrappers, logging, and recovery systems.

WEBGL CONTEXT LOSS HANDLING:
- Listen for 'webglcontextlost' on renderer.domElement:
  - e.preventDefault() to allow potential recovery
  - Track contextLossCount, registerContextLossBurst() within 120s window
  - Set glContextLost=true, hide renderer (opacity:0)
  - Stop simulation, save running state (wasRunningBeforeContextLost)
  - Release all active meteors (resetVolatileVisualStateOnContextLost)
  - Start 1.8s recovery timer — if not restored, show GPU recovery notice
  - Apply context loss safety profile based on burst count

- Listen for 'webglcontextrestored':
  - Clear glContextLost, show renderer (opacity:1)
  - Re-apply renderer resolution
  - Mark all textures and materials as needsUpdate
  - Reset renderer state (renderLists.dispose, resetState)
  - Wait 350ms before rendering (resumeAfterRestoreAt)
  - Restore simulation if it was running
  - Log renderer debug info

PROGRESSIVE DEGRADATION (safety profiles by burst count):
- Level 1 (≥1 context loss in 120s):
  - Cap max active meteors to 12
  - Cap render interval to 1000/40ms
  - Cap texture update interval to 1000/10ms
- Level 2 (≥2):
  - Cap max active meteors to 8
  - Disable cell glow + wireframe
  - Cap simulation speed to 30 gen/s
- Level 3 (≥3):
  - Disable meteor rain entirely

PIXEL RATIO DEGRADATION:
- BASE_MAX_PIXEL_RATIO = 1.25
- On each context loss burst: reduce by 0.25 per extra loss (minimum 1.0)
- getTargetPixelRatio(): min(devicePixelRatio, maxPixelRatio, sqrt(MAX_DRAW_PIXELS/viewportPixels))

GPU RECOVERY NOTICE:
- Modal dialog (fixed center, z-index:400):
  - Title: "GPU CONTEXT LOST" (Orbitron font, red)
  - Message: "WebGL/GPU rendering stopped..."
  - Buttons: "Reload Conway Scene" (primary) + "Dismiss"
  - Hint: "If reload does not help: restart browser (chrome://restart)"
- Show after 1.8s timeout if context not restored
- Hide on context restored

CRASH LOG SYSTEM:
- crashLogEntries array (max 300 entries)
- addCrashLog(kind, level, details): push {ts, tMs, kind, level, snapshot, details}
- crashLogSnapshot(): current gen, pop, running, glContextLost, meteorCount, overlayCount, maxPixelRatio, viewport size
- Persist to localStorage key 'cl-gol-crashlog-v1'
- isLocalStorageSecurityError(): detect cross-origin localStorage blocks gracefully
- Export button: download as JSON file with timestamp filename
- Clear button: with confirm() dialog
- Load on init from localStorage
- Log events: context loss/restore, safety profile changes, pixel ratio degradation, renderer info, window errors, unhandled rejections, visibility changes, dispose, pagehide, beforeunload, app-init-complete

GLOBAL ERROR HANDLERS:
- window 'error': log message, source, line, column
- window 'unhandledrejection': log serialized reason/stack

RENDERER DEBUG INFO:
- logRendererDebugInfo(): get WebGL vendor/renderer via WEBGL_debug_renderer_info extension
- Log as crash log entry on init and after context restore

VISIBILITY CHANGE HANDLING:
- document 'visibilitychange': track pageVisible
- When hidden: skip animation loop (no rendering/physics while tab inactive)
- When visible: reset frame timing, refresh layout

SCENE DISPOSAL:
- disposeScene(): comprehensive cleanup function
  - Stop animation loop (cancelAnimationFrame)
  - Dispose all meteor visuals (active + pooled)
  - Clear all arrays (impactRings, impactSlots, meteorFlashIdx)
  - Remove visualViewport listeners, disconnect ResizeObserver
  - Dispose all geometries, materials, textures
  - Dispose renderer
  - Set disposed=true flag
- Call on: pagehide (non-BFCache only), beforeunload

MATERIAL RECOVERY:
- markObjectMaterialNeedsUpdate(obj): handle single material or material array
- markAllMaterialsNeedsUpdate(): mark sphere, back-sphere, wireframe, stars, all meteor visuals
- Call after context restore

PERFORMANCE CAPS (already partially set up, make sure these are enforced):
- BASE_RENDER_INTERVAL_IDLE = 1000/24 (24fps when no meteors)
- BASE_RENDER_INTERVAL_METEOR = 1000/45 (45fps during meteor flight)
- BASE_TEX_UPDATE_INTERVAL = 1000/12 (12fps for texture rebuilds)
- In main loop: only call renderer.render() when enough time has passed
- Only call updTex() when pendingTexUpdate AND enough time since lastTexUpdate

RENDERER CREATION ERROR:
- Listen for 'webglcontextcreationerror' on domElement, log statusMessage
```

**Expected Result:**
- Application survives GPU context loss and automatically recovers
- Progressive degradation reduces GPU load after repeated crashes
- Crash log captures diagnostic data for debugging
- Export button downloads full crash history as JSON
- Clean shutdown on page navigation (no WebGL warnings)
- Tab switching doesn't cause timing glitches
- Works across different GPU capabilities

---

## Key Learnings

### Why 5 Prompts?

1. **Prompt 1 (~50% of code)** establishes the complete skeleton: HTML structure, CSS styling, engine, scene, and basic UI. Every subsequent prompt extends this without rebuilding it.

2. **Prompt 2 (~15%)** is purely visual — it enriches the texture rendering. The engine, scene, and UI wiring from Prompt 1 remain untouched.

3. **Prompt 3 (~25%)** adds the meteor system as a self-contained feature layer. It hooks into existing functions (updTex, step, scene, save/load) but doesn't replace them.

4. **Prompt 4 (~5%)** adds interaction handlers that sit on top of everything. No existing code needs changing.

5. **Prompt 5 (~5%)** wraps everything in safety infrastructure. It adds event listeners and guards but modifies zero core logic.

### Effective Prompting Strategies

1. **Be exhaustive about constants and formulas** — AI tools cannot infer magic numbers like `CELL_GLOSS_HI_STRENGTH=0.12` or `METEOR_FLASH_DECAY_PER_GEN=1/7`. Specify them exactly.

2. **Name your variables consistently** — using the same names across prompts (e.g., `cellExposure`, `rotQ`, `impactSlots`) ensures the AI assistant extends the right variables.

3. **Specify what NOT to change** — explicitly saying "do NOT rewrite the engine" prevents the AI from replacing working code with a fresh implementation.

4. **Describe data structures before behaviors** — arrays and objects first, then the functions that operate on them.

5. **Separate concerns into layers** — engine → visuals → features → interactions → resilience. Each layer depends only on the ones below it.

---

## Troubleshooting Tips

| Issue | Solution |
|-------|----------|
| Sphere appears black | Check that `lifeTex.needsUpdate=true` is called after `updTex()` |
| Cells distorted at poles | Verify `poleCellH[y] = max(1, round(TEX_SCALE * sin(theta)))` |
| Meteors don't appear | Ensure `meteorMode=true` and `activeMeteors.length < maxActiveMeteors` |
| Context menu doesn't show | Check that `e.preventDefault()` is called on contextmenu event |
| Glow not visible | Ensure `cellGlow=true` and `glowIntensity > 0`, check canvas composite mode |
| Wireframe invisible | Verify `wire.visible=true` and `wOpacity` uniform > 0 |
| Settings not saved | Check localStorage access (cross-origin iframes may block it) |
| Performance issues | Reduce speed, disable cell glow and wireframe, lower pixel ratio |

---

## Expected Output

After completing all five prompts, you should have:

```
your-workspace/
└── conway-sphere.html    # Complete single-file application (~3000+ lines)
```

The file should:
- Work standalone (no server required, Three.js loaded from CDN)
- Open directly in any modern browser with WebGL support
- Save all settings automatically to localStorage
- Survive GPU context loss and recover automatically
- Display a rich, interactive 3D visualization of Conway's Game of Life

---

## Architecture Overview

```
┌──────────────────────────────────────────────────┐
│                    HTML / CSS                     │  Prompt 1
│  topbar · panel · footer · overlays · ctxMenu     │
├──────────────────────────────────────────────────┤
│              GoL Engine (400×200)                 │  Prompt 1
│  grid · step() · patterns · spherical topology    │
├──────────────────────────────────────────────────┤
│           Three.js Scene & Camera                 │  Prompt 1
│  sphere · wireframe · stars · lights · rotation   │
├──────────────────────────────────────────────────┤
│          Texture Rendering Pipeline               │  Prompt 2
│  borders · gloss · glow · exposure · day/night    │
├──────────────────────────────────────────────────┤
│             Color System & Presets                │  Prompt 2
│  5 color channels · 7 themes · live update        │
├──────────────────────────────────────────────────┤
│              Meteor System                        │  Prompt 3
│  physics · trails · impacts · overlay · stats     │
├──────────────────────────────────────────────────┤
│          Interactions & Layout                    │  Prompt 4
│  context menu · wipe · camera center · rules      │
├──────────────────────────────────────────────────┤
│         Robustness & Performance                  │  Prompt 5
│  context loss · crash log · degradation · dispose │
└──────────────────────────────────────────────────┘
```

---

*Prompt-Anleitung erstellt für AI Café — Februar 2026*
