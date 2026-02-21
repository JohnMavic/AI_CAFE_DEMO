# AI Café Presenter — User Guide (No-Chat Edition)

**Author:** Martin Hämmerli (JohnMavic)
**Date:** February 21, 2026
**Version:** 0.1.0-alpha (Prototype)

---

## ⚠️ Important: Multi-Display Requirement

> **The AI Café Presenter is designed exclusively for setups with two or more displays.**
>
> The core concept is: you open the AI Café Presenter on your **main screen** and use **Screen Capture** to mirror content from a **second screen** into it. This way you can control slides, annotate, and navigate — all from the AI Café Presenter — while your additional content (VS Code, PowerPoint, demos) runs on a separate display. If you only have a single monitor, this tool provides no benefit — just open your content directly instead.
>
> The tool works with any 2+ display arrangement. The key point is: the AI Café Presenter and the captured content must be on **different screens**.

### Recommended 3-Screen Setup

```
┌─────────────────────────────┐
│                             │
│     MONITOR 1 (Main)        │
│                             │       ┌───────────────────┐
│  ● AI Café Presenter app    │       │                   │
│  ● This is the screen you   │       │  LAPTOP (Mon. 3)  │
│    share in Teams/Zoom      │       │                   │
│                             │       │ ● Teams/Zoom app  │
│                             │       │ ● PowerPoint      │
├─────────────────────────────┤       │   (editing view)  │
│                             │       │ ● Notes, chat     │
│     MONITOR 2               │       │                   │
│                             │       └───────────────────┘
│  ● VS Code, live demos —    │
│    anything you want to      │
│    present                   │
│  ● PowerPoint opens here    │
│    in fullscreen (F5)       │
│  ● Captured by the AI Café  │
│    Presenter via "Capture"  │
│                             │
└─────────────────────────────┘
```

**How it all connects:**

1. **Monitor 1** runs the AI Café Presenter in your browser. You share this screen in Teams/Zoom — your audience sees exactly what the AI Café Presenter displays.
2. **Monitor 2** is for **additional content** that cannot run inside the AI Café Presenter itself — for example, VS Code for a live coding demo, or a desktop application. The AI Café Presenter's **📺 Capture** feature grabs this screen and mirrors it into its window on Monitor 1.
3. **Laptop** runs Teams/Zoom (which shares Monitor 1) and PowerPoint in editing view. When you press **F5**, PowerPoint is configured to open the slideshow on **Monitor 2** in fullscreen — which is then automatically visible in the AI Café Presenter via Capture.

> **Result:** In Teams/Zoom, you share Monitor 1. On Monitor 1, the AI Café Presenter runs in your browser. The AI Café Presenter captures Monitor 2 and displays its content inside its own window. So whatever you put on Monitor 2 — VS Code, a fullscreen PowerPoint slideshow — appears inside the AI Café Presenter on Monitor 1, which is exactly what your Teams/Zoom audience sees. From there, you can draw annotations on top of it, control PowerPoint slides, or switch to a website tab — all without leaving the AI Café Presenter on Monitor 1.

---

## 📦 Required Files

Copy **all four files** into the **same folder** on the target machine:

| File | Purpose |
|------|---------|
| `ai_cafe_presenter_noChat.html` | The AI Café Presenter application (open this in a browser) |
| `START-PPT-CONTROLLER.bat` | Starts the local PowerPoint control server |
| `STOP-PPT-CONTROLLER.bat` | Stops the PowerPoint control server |
| `ppt-controller.ps1` | The PowerShell script that runs the PPT server (called by the BAT files) |

> **Note:** `stop-ppt-controller.ps1` is also used internally by the start script to clean up stale processes. Include it if present.

All files **must** reside in the same directory. The AI Café Presenter auto-detects the BAT file path relative to itself.

---

## 🚀 Getting Started

1. **Copy all four files** into one folder (e.g., `C:\Presenter\`).
2. **Open** `ai_cafe_presenter_noChat.html` in a Chromium-based browser (Chrome or Edge recommended).
3. You'll see the AI Café Presenter toolbar and a welcome screen prompting you to enter a URL or open a file.

---

## 🌐 Browse Mode (URL / File Loading)

Browse mode lets you load any website or local HTML file into an embedded iframe — useful for live demos, documentation, or interactive content.

### Loading Content

- **Type a URL** into the address bar and press **Enter** or click **Go**.
  - Examples: `https://github.com`, `E:\Demos\dashboard.html`
  - If you omit `https://`, it's added automatically.
  - Windows file paths (e.g., `E:\folder\file.html`) are auto-converted.
- **Open a local file** via the **📂** button (supports `.html`, `.htm`, `.pdf`, images, `.txt`).
- **Reload with cache bust:** Press **Ctrl+Shift+R** to force-reload the current page.

### Navigation

- The **Back** button appears when you have browsing history in the current tab.
- If a page blocks iframe embedding (X-Frame-Options / CSP), the AI Café Presenter shows an error with a button to **open it in a new browser tab** instead.

---

## 📑 Tab System

The AI Café Presenter includes a multi-tab system so you can prepare multiple pages and switch between them instantly. **This is the recommended way to show websites during a presentation** — instead of opening URLs on a second monitor, pre-load them into tabs and switch between them directly within the AI Café Presenter.

### Preparing Tabs Before a Presentation

1. Open the AI Café Presenter in your browser.
2. In the first tab, type or paste a URL into the address bar and press **Enter** or click **Go** to load and save it to the tab (e.g., `https://github.com`).
3. Click **+** to add a new tab, then load the next URL.
4. Repeat until all your websites/pages are ready. Tab titles are automatically set based on the loaded page.
5. Optionally, use **⚙️ → 📤 Export** to save your tab set as a JSON file — you can re-import it later or share it with someone else.

During the presentation, simply click the desired tab in the **📑 tab panel** to instantly switch between your pre-loaded pages.

### Tab Management

| Feature | Details |
|---------|---------|
| **Maximum tabs** | 12 |
| **Default** | 5 empty tabs on first launch |
| **Switch tab** | Click a tab in the tab panel |
| **Add tab** | Click the **+** button |
| **Close tab** | Click **×** or middle-click the tab |
| **Reorder tabs** | Drag and drop in the tab panel |
| **Toggle tab panel** | Click the **📑** button in the toolbar |
| **Export tabs** | Settings (⚙️) → **📤 Export** — saves all tab URLs as a JSON file |
| **Import tabs** | Settings (⚙️) → **📥 Import** — loads tabs from a JSON file |
| **Clear all tabs** | Settings (⚙️) → **Clear All Tabs** |

Tabs are **automatically saved** to your browser's localStorage — they persist across sessions.

Each tab also remembers its **scroll position and form state** (up to 20 states per tab), so switching back restores where you left off.

---

## 📺 Screen Capture (Present Mode)

Screen Capture is one of the **core features** of the AI Café Presenter, alongside Browse Mode. It captures a selected display and streams it into the AI Café Presenter window so you can annotate and control slides — all from one screen.

### How to Start

1. Click the **📺 Capture** button in the toolbar.
2. Your browser will ask you to **choose what to share**. Select the **entire screen/display** that your audience sees (e.g., your projector output).
3. The live feed of Monitor 2 appears inside the AI Café Presenter on Monitor 1.

> **Important:** The captured screen is a **read-only mirror** — you cannot interact with the applications directly through the AI Café Presenter. To actually operate an application (click buttons, type code, etc.), switch to the original screen where the app is running (Monitor 2). What you *can* do on the captured view is **draw annotations** — arrows, rectangles, underlines, circles — using the Draw feature (see below). The one exception is **PowerPoint slide navigation**, which is controlled remotely via the PPT server buttons and keyboard shortcuts (see PowerPoint Control).

### How to Stop

- Click the **📺 Capture** button again (it turns green while active).
- Or close/stop the browser's screen sharing prompt.

### Zoom (100%)

- While capture is active, the **🔍 100%** button becomes available.
- Click it to toggle between **fit-to-window** (default) and **native 100% resolution**.
- At 100%, the viewport follows your mouse, allowing you to pan around the captured screen.

---

## ✏️ Drawing Overlay

The drawing system lets you annotate directly on top of the captured screen or browsed content — perfect for highlighting things during a presentation.

### Activating Draw Mode

- **In Present (Capture) mode:** Press **D** to **toggle** draw mode on/off. A drawing toolbar appears at the top.
- **In Browse mode:** **Hold D** to temporarily draw on top of the page. Releasing D fades the drawings away (configurable).

### Drawing

- **Left-click + drag** to draw freehand strokes.
- **Right-click + drag** to use the **eraser** (removes strokes you drag over).

### Colors

Six neon colors are available in the draw toolbar:
- 🟡 **Neon Yellow** (default)
- 🟢 **Green**
- 🔵 **Cyan**
- 🩷 **Pink**
- 🟠 **Orange**
- ⚪ **White**

Click a color button to select it. The active color is highlighted.

### Line Width

- **−** button: Decrease brush size
- **+** button: Increase brush size
- Current width is shown between the buttons (default: 8px)

### Fade / Auto-Clear Timer

The **⏱️** slider (0–30 seconds) controls how long drawings stay visible before fading:
- **0** = Drawings stay until you clear them manually.
- **1–30s** = Drawings automatically fade after the set duration.
- Default: **5 seconds** in present mode, **1 second** in browse mode.

### Shape Recognition

The drawing engine automatically recognizes shapes from freehand strokes:

| Key (hold while drawing) | Shape |
|--------------------------|-------|
| **A** | Arrow |
| **C** | Circle / Oval |
| **T** | Triangle |
| **S** | Square / Rectangle |
| **X** | X mark |
| **L** | Straight Line |

You can also just draw freehand — the system will attempt to auto-detect the shape if it's close enough. Hold a shape key to **force** recognition.

Press **ESC** while in draw mode to clear any shape override, or press **ESC** again to exit draw mode entirely.

### Shortcuts Help Panel

When draw mode is activated for the first time, a **shortcuts help panel** is shown by default, listing all shape keys and drawing actions. This panel can be toggled on or off by clicking the **?** button (labeled "Toggle Shortcuts Help") in the draw toolbar. Your preference is saved automatically.

### Clear All

Click the **🗑️ Clear** button to instantly remove all drawings from the canvas.

### Cursor

In draw mode, a colored dot follows your cursor (matching your selected brush color). In present mode without draw, a pulsing red dot serves as a laser pointer.

---

## ⛶ Fullscreen

| Trigger | Action |
|---------|--------|
| **F** key | Toggle fullscreen on/off |
| **⛶** button (toolbar) | Toggle fullscreen on/off |
| **ESC** | Exit fullscreen |

Fullscreen applies to the entire AI Café Presenter window. Works in both present and browse modes.

> **Tip:** If you used the browser's native **F11** fullscreen, press **F** first to exit via the API, then **F11** to fully restore the window.

---

## 🎯 PowerPoint Control (Advanced)

> ⚠️ **This section is for advanced users.** Setting up PowerPoint control requires several steps — starting a local server, configuring PowerPoint to display the slideshow on the correct monitor, and understanding how the components work together. This is **not self-explanatory** and requires some time to set up correctly the first time. You will also need to understand how PowerPoint itself handles the transition from editing mode to fullscreen slideshow mode, and how to configure which monitor the slideshow appears on. Read through all the steps below carefully before attempting the setup.

The AI Café Presenter can **remotely control PowerPoint** on your machine via a lightweight local server. This lets you start/stop slideshows and navigate slides without leaving the AI Café Presenter.

### Step 1: Configure PowerPoint's Slideshow Display

**This is critical.** You must tell PowerPoint which monitor to use when switching from editing mode to fullscreen slideshow mode. PowerPoint has a dedicated setting for this:

1. Open your `.pptx` file in PowerPoint.
2. Click the **Slide Show** tab in the ribbon.
3. In the **Monitors** group (right side of the ribbon), you'll see a dropdown labeled **Monitor** — click it and select the monitor where the fullscreen slideshow should appear. This must be the monitor that the AI Café Presenter captures via **📺 Capture**.

The key idea is: when you press **F5** in the AI Café Presenter, PowerPoint switches from editing mode to fullscreen slideshow mode. The **Monitor** dropdown in the Slide Show ribbon determines which screen that fullscreen slideshow appears on. You need to set this to the monitor that the AI Café Presenter is capturing — otherwise your audience won't see the slides.

**2-screen setup:**

| Monitor | What runs here |
|---------|---------------|
| **Monitor 1** | AI Café Presenter (shared in Teams) |
| **Monitor 2** | PowerPoint in **both** editing mode and fullscreen mode |

Set the **Monitor** dropdown (Slide Show tab → Monitors group) to **Monitor 2**. When you press F5, the slideshow opens in fullscreen on Monitor 2 — the same screen the AI Café Presenter is already capturing. You edit and present on the same monitor.

**3-screen setup (recommended):**

| Monitor | What runs here |
|---------|---------------|
| **Monitor 1** | AI Café Presenter (shared in Teams) |
| **Monitor 2** | Fullscreen slideshow (captured by AI Café Presenter) |
| **Laptop** | PowerPoint in editing mode, Teams, notes |

Set the **Monitor** dropdown to **Monitor 2**. You edit the PowerPoint on your laptop screen, but when you press F5, the fullscreen slideshow opens on Monitor 2 — which is exactly the screen the AI Café Presenter captures. This way you keep your laptop free for Teams and notes while the audience sees the slideshow through the AI Café Presenter.

> ⚠️ If you skip this step or select the wrong monitor, PowerPoint may open the fullscreen slideshow on top of the AI Café Presenter (Monitor 1), covering it entirely. You would lose access to all AI Café Presenter features — Browse mode, Drawing, Tabs, and Capture — because the PowerPoint slideshow covers the entire screen. You could still navigate slides normally within PowerPoint, but none of the AI Café Presenter's tools would be usable. This is exactly why you need to redirect the fullscreen slideshow to Monitor 2, so the AI Café Presenter stays visible and can capture the slideshow via the Capture feature.

### Step 2: Start the PPT Server

1. In the AI Café Presenter toolbar, look for the **🎯 PPT** button. When offline, it shows a grayed-out status.
2. Click it to reveal the **server instructions panel**. It shows the path to `START-PPT-CONTROLLER.bat`.
3. Click the path to **copy it to your clipboard**.
4. Press **Win + R**, paste the path, and press **Enter**.
5. A PowerShell window opens. Wait until you see the message: **`[OK] Server running on http://localhost:8765`** — this confirms the server started successfully.
6. Switch back to the AI Café Presenter and click **Done** to close the server instructions panel.
7. The **🎯 PPT** indicator turns **green** — the PPT buttons are now enabled.

> **Keep the PowerShell window open** for the entire session. Closing it stops the server.

### Step 3: Control Your Slideshow

| Button / Key | Action |
|-------------|--------|
| **▶️ F5** or press **F5** | Start slideshow from **slide 1** |
| **▶️ ⇧F5** or press **Shift+F5** | Start from **current slide** |
| **→ / ↓ / Space / PageDown** | **Next** slide |
| **← / ↑ / PageUp** | **Previous** slide |
| **⏹️ ESC** or press **ESC** | **Exit** slideshow |

Additionally, when screen capture is active, hovering near the edges of the captured image reveals transparent **click zones** for slide navigation:
- **Left edge (◀):** Click to go to the previous slide.
- **Right edge (▶):** Click to go to the next slide.

> **Important:** Pressing F5 starts the PowerPoint slideshow in fullscreen on Monitor 2 (as configured in Step 1), but the AI Café Presenter stays in its current mode. If you are in Browse mode, it will continue showing your browsed content — **not** the slideshow. To actually see and present the running slideshow through the AI Café Presenter, you need to click **📺 Capture** and select Monitor 2. Only then will the fullscreen slideshow be mirrored into the AI Café Presenter, where you can draw on it and control it.

### Step 4: Stopping the Slideshow vs. Shutting Down the Server

It is important to understand the difference between these three actions:

| Action | What it does | How to trigger |
|--------|-------------|----------------|
| **Stop slideshow** | Exits the running PowerPoint slideshow (like pressing ESC in PowerPoint). The PPT server **keeps running**. | Press **ESC** or click **⏹️ ESC** in the AI Café Presenter |
| **Shut down PPT server (from AI Café Presenter)** | Sends a shutdown command to the server and stops it. The **🎯 PPT** button changes from "PPT Stop" back to "PPT" (offline). | Click the **🎯 PPT Stop** button (only visible when the server is online) |
| **Shut down PPT server (manually)** | Stops the server process via the BAT file. Same effect as the button above. | Double-click `STOP-PPT-CONTROLLER.bat` or close the PowerShell window |

> ⚠️ **The PPT server does not stop automatically.** If you only close the AI Café Presenter (the browser tab), the PowerShell server keeps running in the background on port `8765` **until you shut it down manually or restart your computer**. Use either the **🎯 PPT Stop** button in the AI Café Presenter or run `STOP-PPT-CONTROLLER.bat` when you are done with your presentation to free up the port and stop the process.

---

## ⌨️ Complete Keyboard Shortcut Reference

| Key | Context | Action |
|-----|---------|--------|
| **F5** | Always | Start PPT slideshow from slide 1 |
| **Shift+F5** | Always | Start PPT from current slide |
| **ESC** | PPT running | Exit slideshow |
| **ESC** | Draw mode | Clear shape override / exit draw |
| **→ ↓ Space PgDn** | PPT running | Next slide |
| **← ↑ PgUp** | PPT running | Previous slide |
| **F** | Always | Toggle fullscreen |
| **D** | Present mode | Toggle draw mode |
| **D** (hold) | Browse mode | Temporary draw overlay |
| **A** | Drawing | Force arrow shape |
| **C** | Drawing | Force circle shape |
| **T** | Drawing | Force triangle shape |
| **S** | Drawing | Force square shape |
| **X** | Drawing | Force X mark shape |
| **L** | Drawing | Force line shape |
| **Ctrl+Shift+R** | Browse mode | Cache-bust reload iframe |

---

## 🔧 Troubleshooting

### Keyboard shortcuts don't work
The AI Café Presenter needs **keyboard focus** on the main panel. If you clicked inside an iframe (e.g., a loaded webpage), move your mouse **out of the iframe** to automatically recapture focus. A hint ("Move mouse out to enable Draw (D)") appears when focus is lost.

### PPT server won't connect
- Make sure the PowerShell window from `START-PPT-CONTROLLER.bat` is still open.
- Check that **no other process** is using port `8765`.
- Run `STOP-PPT-CONTROLLER.bat` first, then restart with the start script.

### PowerPoint opens on the wrong screen
- In PowerPoint: **Slide Show → Set Up Slide Show → "Show on"** → select the correct monitor.
- Make sure your display arrangement is set correctly in Windows **Settings → System → Display**.

### Screen capture shows a black screen
- Some apps (especially DRM-protected content) block screen capture.
- Try capturing the **entire screen** rather than a single window.
- Use Chrome or Edge for best compatibility.

### Page won't load in the iframe
Some websites block being embedded in iframes via X-Frame-Options or CSP headers. The AI Café Presenter detects this and offers to open the page in a **new browser tab** instead.

---

## 📝 Notes

- All settings (tabs, draw preferences, last URLs) are saved in your browser's **localStorage** — they persist as long as you don't clear browser data.
- The AI Café Presenter works best in **Chrome** or **Edge** (Chromium-based browsers). Firefox has limited screen capture support.
- The HTML file is fully self-contained — no internet connection is required except for loading external URLs in browse mode.
