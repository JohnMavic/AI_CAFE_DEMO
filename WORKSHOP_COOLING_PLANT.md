# Workshop: Building an Interactive Cooling Plant Monitor with AI

## Iterative Prompting with GitHub Copilot

---

## 🎯 Goal

Create an interactive single-page web application that displays a cooling plant diagram with drawable water flow pipelines and pump control. Participants will learn how to:

1. **Start with a clear initial prompt** to establish layout and visual design
2. **Add an SVG-based pipe editor** with drawing tools and persistence
3. **Bring the pipes to life** with flow animation and advanced interactions
4. **Polish and refine** with a final prompt for professional finishing touches

By the end of this workshop, you will have built a fully functional cooling plant monitoring dashboard — entirely through conversational prompting.

---

## 🛠️ Tools Required

- **Visual Studio Code** (VS Code)
- **GitHub Copilot** (Chat/Agent mode)
- A modern web browser for testing
- The image file `ChatGPT Image Mar 12, 2026, 03_00_43 PM.png` inside an `Images/` folder

---

## 📋 Workshop Structure

| Phase | Duration | Description |
|-------|----------|-------------|
| Introduction | 5 min | Goal overview and tool setup |
| Prompt 1 | 10-15 min | Page layout and visual design |
| Review & Discuss | 5 min | Analyze the result |
| Prompt 2 | 10-15 min | SVG pipe editor with tools |
| Review & Discuss | 5 min | Analyze improvements |
| Prompt 3 | 10-15 min | Flow animation and interactions |
| Review & Discuss | 5 min | Analyze the result |
| Prompt 4 (optional) | 5-10 min | Polish and advanced features |
| Final Review | 5-10 min | Test and discuss learnings |

**Total: ~60-80 minutes (+5-10 min optional)**

---

## 📁 Prerequisites — Folder Setup

Before starting, create the following folder structure:

```
your-workspace/
└── Images/
    └── ChatGPT Image Mar 12, 2026, 03_00_43 PM.png
```

The image shows a technical diagram of a seawater cooling system with pumps, heat exchangers, and piping.

---

## 🚀 The Prompts

### Prompt 1: Page Layout & Visual Design

**Goal:** Create the complete page shell with dark futuristic design, navigation, image display, status bar, and pump toggle.

```
Create a single HTML file called index.html for a "Cooling Plant Monitor" dashboard.

Requirements:
- Dark futuristic design with CSS variables for colors:
  - Background: #0a0e17, Cards: #1a1f2e
  - Neon cyan (#00f0ff) as primary accent, neon blue (#3b82f6), neon magenta (#f72585)
  - Add a subtle animated grid pattern on the body background using CSS ::before
- Sticky top navigation bar with:
  - Left: brand logo (❄ icon in a bordered box) + text "Cooling Plant Monitor" in uppercase with cyan glow
  - Right: three buttons — "✏ Edit Pipes" (cyan), "↻ Refresh" (cyan), "⚠ Alerts" (magenta)
- Main content area with side margins of 25%:
  - Centered title "Cooling Plant" with cyan glow and a gradient underline
  - Subtitle "Seawater Cooling System Overview"
  - Image container with rounded corners (12px), a subtle neon border gradient overlay (::before pseudo-element), and the image at full width. Image path: "Images/ChatGPT Image Mar 12, 2026, 03_00_43 PM.png"
  - Status bar below the image inside the container with:
    - Left side: a toggle switch (neon-styled) labeled "Seawater Pumps OFF", plus status indicators for System (green dot, "Online"), Seawater Intake (cyan dot, "8 °C"), Depth (cyan dot, "100 m"), Efficiency (orange dot, "92%")
    - Right side: a live timestamp updating every second in German locale format (dd.mm.yyyy, HH:MM:SS)
- Footer with text "COOLING PLANT MONITORING DASHBOARD · VANILLA JS · 2026"
- Use vanilla JavaScript only — no external libraries
- Make the toggle switch functional: it should toggle its label between "Seawater Pumps OFF" and "Seawater Pumps ON" and change the label color to cyan when ON
- The Refresh button should briefly show "✓ Refreshed" with a glow effect for 1.2 seconds
- The Alerts button should show a simple alert with "No active alerts."
- Responsive: reduce side margins on smaller screens
```

**Expected Result:**
- ✅ Dark themed page with animated grid background
- ✅ Sticky navbar with brand and neon buttons
- ✅ Cooling plant image displayed with gradient border effect
- ✅ Working pump toggle with label change
- ✅ Status bar with live timestamp
- ✅ Responsive layout

**Discussion Points:**
- How does specifying exact CSS values (colors, radii) influence the result?
- What did the AI assume vs. what did we specify?
- Why is it important to specify "vanilla JavaScript, no external libraries"?

---

### Prompt 2: SVG Pipe Editor

**Goal:** Add an SVG overlay on the image and a complete pipe editing system with toolbar.

```
Great foundation! Now add a pipe editor system on top of the image.

Requirements:
- Add an SVG element as an overlay on top of the image inside the image-wrapper div:
  - Position: absolute, covering the full image area
  - viewBox: "0 0 1057 617" with preserveAspectRatio="xMidYMid meet"
  - pointer-events: none by default, auto when in edit mode
  - Use SVG's getScreenCTM().inverse() for mouse-to-SVG coordinate conversion (not getBoundingClientRect) to avoid offset issues with preserveAspectRatio
- Store pipeline data as an array of objects in localStorage (key: "coolingPlantPipelines"). Each pipeline has: id, name, points (array of {x, y, color}), direction (1 or -1)
  - x/y are stored as percentages (0-100) of the viewBox dimensions
- The "✏ Edit Pipes" button toggles between edit and present mode:
  - In edit mode: button changes to "▶ Done — Present" (magenta color), SVG gets cursor: crosshair
  - In present mode: button reverts to "✏ Edit Pipes" (cyan)
- Show an edit toolbar (only visible in edit mode) above the image with:
  - Pipe management: a <select> dropdown listing all pipes, "+ New" button, "× Delete" button, "↩ Undo" button (hidden until a pipe is deleted)
  - Drawing tools: "✏ Insert Pt" (insert point on existing segment), "↔ Extend" (add points to start/end — default active), "✋ Move" (select/drag), "⌫ Delete Pt"
  - Direction toggle: "→ Forward" / "← Reverse" button
  - Color selection: "● Blue" (#00d4ff) and "● Red" (#ff3355) buttons
  - Style: dark background, flex layout, neon-styled buttons with active state highlighting
- Edit mode behavior:
  - "Extend" tool: click on SVG adds a point to the closest end (start or end) of the selected pipe
  - "Insert Pt" tool: click near an existing segment inserts a point on that segment (ignore clicks far from any segment, threshold ~20 viewBox units)
  - "Move" tool: mousedown on a vertex starts drag, mousemove updates position, mouseup saves
  - "Delete Pt" tool: click on a vertex removes it. Also show a "×" icon on hover. Change cursor to not-allowed in delete mode
  - Double-click any vertex: toggle its color between blue and red
  - Right-click any vertex: delete it (with preventDefault on contextmenu)
- In edit mode, render pipelines as colored lines between vertices, with colored circle vertices (r=6) showing the vertex color. Only show vertices for the selected pipe
- Show a direction arrow (▶) at the midpoint of the selected pipe in edit mode
- All changes auto-save to localStorage
```

**Expected Result:**
- ✅ SVG overlay positioned precisely on the image
- ✅ Edit/Present mode toggle working
- ✅ Toolbar with all pipe management tools
- ✅ Can create new pipes and add points by clicking
- ✅ Can drag vertices to reposition them
- ✅ Can delete points, toggle colors, change direction
- ✅ Data persists in localStorage across page reloads

**Discussion Points:**
- Why use `getScreenCTM().inverse()` instead of `getBoundingClientRect()` for coordinate mapping?
- How does building on "Great foundation!" maintain context?
- What is the balance between describing behavior vs. implementation details?

---

### Prompt 3: Flow Animation & Visual Effects

**Goal:** Add animated water flow along the pipes when the pump is activated.

```
Excellent progress! Now add the flow animation and visual effects for present mode.

Requirements:
- In present mode, render each pipe as a series of per-edge polyline segments (one polyline per pair of consecutive vertices)
- Each segment gets two visual layers:
  1. A glow layer (thicker, semi-transparent, blurred) behind the main line
  2. The main pipe line on top
- Color each segment based on its start and end vertex colors:
  - Same color: use that color directly for stroke
  - Different colors: create an SVG linearGradient (gradientUnits="userSpaceOnUse") transitioning from start to end vertex color
  - Apply the same gradient logic to the glow layer
- CSS for pipe rendering:
  - .pipe-glow: stroke-width 14, opacity 0.4, stroke-linecap round, filter blur(6px), no fill
  - .pipe-segment: stroke-width 3.5, no fill, stroke-linecap round, stroke-linejoin round
  - .pipe-segment.active: add a dashed stroke pattern (stroke-dasharray: 8 12) for flow animation
- Flow animation:
  - When the pump toggle is ON and mode is "present", add class "active" to all pipe segments
  - Run a requestAnimationFrame loop that continuously decreases a global offset by 0.8 per frame
  - Apply strokeDashoffset to each active segment, calculated as: lenBefore + offset * direction
    - lenBefore = cumulative length of all previous segments in the same pipe
    - direction = the pipe's direction property (1 or -1)
  - This creates the visual effect of dashes flowing along the pipe path
  - Stop the animation loop (cancelAnimationFrame) when pump is OFF or mode switches to edit
- Update the Alerts button to show pipe count and total vertex count in the alert message
- Ensure toggling between edit and present mode correctly starts/stops animation based on pump state
```

**Expected Result:**
- ✅ Pipes render with beautiful glow effects in present mode
- ✅ Color gradients between different-colored vertices
- ✅ Animated dashes flow along pipes when pump is ON
- ✅ Flow direction follows each pipe's direction setting
- ✅ Animation starts/stops cleanly with pump toggle and mode changes

**Discussion Points:**
- How does describing the visual effect ("dashes flowing along the pipe") help vs. only describing the technical implementation?
- Why split rendering into per-edge segments instead of one polyline per pipe?
- When is it helpful to specify exact CSS values (stroke-width, dasharray)?

---

### Prompt 4: Polish & Responsive Refinements (Optional)

**Goal:** Add final polish, edge-case handling, and responsive adjustments.

```
Almost there! Final polish:

- Add CSS transitions and hover effects:
  - Vertices: hover shows a subtle glow fill (rgba(0, 240, 255, 0.25))
  - Selected vertices get a drop-shadow filter
  - Edit lines for selected pipes should be brighter/thicker than unselected
  - Smooth transitions on all buttons and toggle switches (0.3s ease)
- Add a gradient border effect on the image container using a ::before pseudo-element with mask-composite
- Migrate data on load: if old pipeline data lacks vertex colors, default to "blue"
- Fix duplicate pipe names on load: auto-rename to "Pipe N" with next available number
- Responsive improvements:
  - Below 768px: reduce side margins to 5%, make toolbar wrap, reduce font sizes
  - Below 480px: make navbar controls full width, reduce status item font sizes
  - Toolbar sections should wrap on narrow screens with proper spacing
- Add proper line-height: 0 on the image wrapper to prevent phantom spacing below the image
- Ensure the edit toolbar uses a scrollable flex-wrap layout so all tools remain accessible on smaller screens
```

**Expected Result:**
- ✅ Smooth hover effects and transitions throughout
- ✅ Gradient border on image container
- ✅ Robust data migration for legacy pipe data
- ✅ Fully responsive on mobile devices
- ✅ Clean, professional visual polish

**Discussion Points:**
- Which enhancements are essential vs. optional in a time-boxed workshop?
- How do we decide when to split a prompt into a bonus step?
- What role does "defensive coding" (data migration, deduplication) play?

---

## 💡 Key Learnings

### Effective Prompting Strategies

1. **Layer Complexity Gradually**
   - Prompt 1 builds the visual shell — no interactivity on the diagram yet
   - Prompt 2 adds the editor system — building on the existing layout
   - Prompt 3 adds animation — building on the existing data model
   - Each prompt can be verified independently before moving on

2. **Be Specific About Technical Choices**
   - `preserveAspectRatio="xMidYMid meet"` prevents distortion
   - `getScreenCTM().inverse()` avoids coordinate offset bugs
   - Exact CSS values ensure visual consistency

3. **Describe Both Behavior and Intent**
   - "Dashes flowing along the pipe" (intent) + `strokeDashoffset` (implementation)
   - Helps the AI understand *what* you want and *how* to achieve it

4. **Give Positive Feedback Between Prompts**
   - "Great foundation!", "Excellent progress!" maintain context
   - Signals continuation rather than replacement

5. **Keep Data Models Explicit**
   - Specifying `{x, y, color}` and `direction` early prevents rework later
   - The animation system relies on the data model from Prompt 2

---

## 🔄 Troubleshooting Tips

| Issue | Solution |
|-------|----------|
| SVG overlay not aligned with image | Check that image-wrapper has `position: relative` and SVG has `position: absolute; top: 0; left: 0` |
| Mouse clicks offset from actual position | Ensure `getScreenCTM().inverse()` is used instead of `getBoundingClientRect()` |
| Flow animation not starting | Verify pump toggle sets `flowActive` and mode is "present" |
| Pipes disappear after reload | Check localStorage key is consistent between save/load |
| Gradients not rendering | Ensure `gradientUnits="userSpaceOnUse"` and coordinates match segment endpoints |
| Edit toolbar overlapping image | Add proper `display: none` when not in edit mode |
| Image has phantom spacing below | Set `line-height: 0` on the image wrapper |

---

## 📁 Expected Output

After completing all prompts, you should have:

```
your-workspace/
├── Images/
│   └── ChatGPT Image Mar 12, 2026, 03_00_43 PM.png
└── index.html    # Complete single-file application (~1200-1400 lines)
```

The file should:
- Work standalone (no server required)
- Open directly in any modern browser
- Allow drawing water flow paths on the cooling plant diagram
- Animate flow when pump is toggled on
- Save all pipe data automatically to localStorage
- Be fully responsive

---

## 🎓 Workshop Takeaways

1. **Start with the shell, then add interaction** — A solid visual foundation makes it easier to layer features
2. **Coordinate systems matter** — Using SVG's native coordinate transformation avoids subtle bugs
3. **Data model design is critical** — Define your data structure early, it affects everything downstream
4. **Iterate in focused steps** — Each prompt has a clear purpose and verifiable outcome
5. **Trust but verify** — Always test the output in a real browser, especially mouse interactions

---

## 📝 Notes for Facilitators

- Have a working example ready in case of technical issues
- The image file must be in the `Images/` folder before starting — verify this with participants
- If coordinate offset issues arise, explain the difference between `getBoundingClientRect()` and `getScreenCTM()`
- Encourage participants to draw a few pipe segments and toggle the pump to see flow animation
- Time buffer: Prompt 2 (pipe editor) tends to need the most follow-up corrections
- If running short on time, Prompt 4 can be skipped — the app is fully functional after Prompt 3

---

*Workshop created for Cooling Plant Demo — March 12th, 2026*
