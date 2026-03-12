# Workshop: Building an AI Evolution Timeline & Productivity Visualizer with AI

## Iterative Prompting with GitHub Copilot

---

## 🎯 Goal

Create an interactive single-page web application that visualizes the evolution of AI from 2015 to 2026 alongside a cumulative productivity impact chart. Participants will learn how to:

1. **Build a futuristic dual-panel layout** with glass-morphism and animated backgrounds
2. **Render an interactive timeline** on HTML Canvas with real AI milestones
3. **Add a productivity impact chart** with configurable parameters and linked controls
4. **Polish with a methodology page** and responsive enhancements

By the end of this workshop, you will have built a fully functional data visualization dashboard — entirely through conversational prompting.

---

## 🛠️ Tools Required

- **Visual Studio Code** (VS Code)
- **GitHub Copilot** (Chat/Agent mode)
- A modern web browser for testing

---

## 📋 Workshop Structure

| Phase | Duration | Description |
|-------|----------|-------------|
| Introduction | 5 min | Goal overview and tool setup |
| Prompt 1 | 10-15 min | Layout, design, and controls panel |
| Review & Discuss | 5 min | Analyze the result |
| Prompt 2 | 10-15 min | Timeline canvas with AI milestones |
| Review & Discuss | 5 min | Analyze improvements |
| Prompt 3 | 10-15 min | Productivity chart and interactivity |
| Review & Discuss | 5 min | Analyze the result |
| Prompt 4 (optional) | 5-10 min | About page and polish |
| Final Review | 5-10 min | Test and discuss learnings |

**Total: ~60-80 minutes (+5-10 min optional)**

---

## 🚀 The Prompts

### Prompt 1: Layout, Animated Background & Controls Panel

**Goal:** Create the page shell with a futuristic dark design, animated background, and a fully wired controls panel.

```
Create a single HTML file called ai-timeline-productivity.html for an "AI Evolution Timeline & Personal Productivity (2015–2026)" visualization.

Requirements:
- Dark futuristic design with CSS variables:
  - Background: #0a0a1a, purple accent: #1a0a2e
  - Cyan: #00f5ff, Magenta: #ff2bd6, Lime/Microsoft: #7CFF6B, Amber: #FFD24A
  - Glass panel background: rgba(20, 20, 40, 0.6) with backdrop-filter blur(20px)
- Animated background with three layers:
  1. A slow-shifting gradient (20s infinite animation, using translate keyframes)
  2. A starfield made of radial-gradient dots with a twinkling opacity animation (30s)
  3. A dark vignette overlay (radial-gradient from transparent center to semi-black edges)
- Header: centered h1 with gradient text (cyan → magenta → lime), uppercase, letter-spacing 2px
- Below the header, add a "How It Works" button (cyan accent, rounded pill style)
- Main layout: a .container div that fills the viewport height minus the header (~80px), containing:
  1. A controls panel (glass-panel style, full width) with a CSS grid of controls:
     - Year slider ("Time Travel"): range 2015-2026, step 0.1, spanning 2 columns. Show current value and a "Nearest: —" text below
     - Role selector: a <select> dropdown with options "Vision Engineer" and "Office Worker"
     - AI Warp Factor slider: range 0-10, step 1, default 3. Show current value as "3/10"
     - Baseline Growth slider: range 0-5%, step 0.1, default 1.5. Show as "1.5%/year"
     - Display Options: two toggle switches — "Log Scale" (off) and "Exp. Timeline" (on by default)
     - Show Providers: three colored toggle switches — "OpenAI" (cyan), "Anthropic" (magenta), "Microsoft" (lime), all checked
     - A "Reset to Defaults" button (magenta accent)
  2. Below the controls, a two-column grid with two glass panels side by side:
     - Left panel titled "🕐 AI Timeline (2015–2026)" with a <canvas> element inside
     - Right panel titled "📈 Cumulative Productivity Over Time" with a <canvas> element inside
     - Between the panels, add a draggable splitter (15px wide, with a small vertical bar that glows cyan on hover)
- Style all toggle switches as custom neon-styled sliders (no native checkbox appearance)
- Style all range inputs with custom cyan thumbs and dark tracks
- Style the select dropdown with glass-morphism (dark bg, glass border, cyan focus)
- Make the two-column layout collapse to single column below 1024px (hide the splitter)
- Use vanilla JavaScript only — no external libraries
- Wire up all sliders to display their current values in real-time
- The Reset button should restore all controls to their default values
```

**Expected Result:**
- ✅ Animated starfield background with gradient shift
- ✅ Glass-morphism control panel with all inputs
- ✅ Two canvas panels side by side with draggable splitter
- ✅ All sliders update their displayed values in real-time
- ✅ Reset button works
- ✅ Responsive layout (single column on mobile)

**Discussion Points:**
- How does specifying exact CSS variable values ensure visual consistency?
- Why use canvas elements instead of SVG for this kind of visualization?
- How does the layered background approach (gradient + starfield + vignette) create depth?

---

### Prompt 2: Timeline Canvas with AI Milestones

**Goal:** Render the AI timeline with real milestone data, interactive dots, and provider filtering.

```
Excellent foundation! Now add the AI timeline data and render it on the left canvas.

Requirements:
- Define an events array with real AI milestones (date, provider, label, type). Include these events:
  - OpenAI: OpenAI announced (2015-12), GPT-1 (2018-06), GPT-2 (2019-02), GPT-3 (2020-06), Codex (2021-08), InstructGPT (2022-03), ChatGPT launch (2022-11), GPT-4 (2023-03), GPT-4o (2024-05), o1-preview (2024-09), o3-mini (2025-01), GPT-4.5 (2025-02), GPT-5 (2025-08)
  - Anthropic: Claude 1 (2023-03), Claude 2 (2023-07), Claude 3 (2024-03), Claude 3.5 Sonnet (2024-06), Claude 4 (2025-05), Opus 4.5 (2025-11)
  - Microsoft: GitHub Copilot preview (2021-06), Copilot GA (2022-06), Bing Chat (2023-02), M365 Copilot announced (2023-03), M365 Copilot GA (2023-11), Copilot Chat GA (2023-12), Copilot Free Tier (2024-12), Agent Mode (2025-02)
- Write a dateToYear() function that converts ISO date strings to fractional years (e.g., "2023-06-15" → 2023.45)
- Canvas rendering for the timeline:
  - Set up proper HiDPI/Retina support (use devicePixelRatio for crisp rendering)
  - Draw a horizontal time axis at the bottom with year labels (2015-2026)
  - Support "Exponential Timeline" mode: compress early years (less activity), expand recent years (more releases). Use a power function (e.g., t^2.5) to redistribute the x-axis
  - Draw three horizontal provider lanes (OpenAI at top, Anthropic middle, Microsoft bottom)
  - For each event, draw a glowing dot at the correct x (date) and y (provider lane) position
  - Color dots by provider: cyan for OpenAI, magenta for Anthropic, lime for Microsoft
  - Draw vertical label text next to each dot (rotated -45°), with the event label
  - Only show events for providers whose toggle is checked
  - Draw a vertical cyan "cursor line" at the current year slider position
- Add hover interaction:
  - When the mouse hovers over a dot (within ~12px radius), show a floating tooltip with provider, label, and formatted date
  - The tooltip should be a styled div (glass-morphism, positioned near the mouse), not a canvas drawing
  - Provider name in the tooltip should be colored (cyan/magenta/lime)
- Add click interaction: clicking a dot pins an info panel (positioned at bottom-left of the canvas) showing the event details, with a close button
- Add a legend below the timeline canvas: three colored dots with labels (OpenAI, Anthropic, Microsoft / GitHub)
- The "Nearest: —" text below the year slider should update to show the event closest to the current slider position
- Wire up the provider toggles to show/hide events and re-render
- Wire up the Exp. Timeline toggle to switch between linear and exponential x-axis
- Resize and re-render the canvas on window resize
```

**Expected Result:**
- ✅ Timeline shows real AI milestones as colored dots
- ✅ Provider filtering via toggle switches
- ✅ Exponential vs. linear timeline toggle works
- ✅ Year slider moves a cursor line across the timeline
- ✅ Hover tooltips with event details
- ✅ Click-to-pin info panel
- ✅ Legend with provider colors

**Discussion Points:**
- Why provide exact event data rather than letting the AI generate it?
- How does the exponential time compression improve readability?
- What is the role of `devicePixelRatio` for canvas sharpness?

---

### Prompt 3: Productivity Chart & Panel Splitter

**Goal:** Render the productivity impact chart and make the draggable splitter functional.

```
Great progress! Now add the productivity chart on the right canvas and make the panel splitter draggable.

Requirements:
- Define a productivityBoosts object mapping event dates to productivity weights per role:
  - Each entry has { developer: weight, office: weight } where weight is 0.0 to 0.35
  - Key boosts: ChatGPT launch (dev: 0.35, office: 0.25), GPT-4 (dev: 0.25, office: 0.15), GitHub Copilot GA (dev: 0.25, office: 0.03), M365 Copilot GA (dev: 0.10, office: 0.25), GPT-5 (dev: 0.30, office: 0.20), Copilot Chat GA (dev: 0.30, office: 0.05)
  - Assign smaller weights (0.05-0.15) to other milestones based on their relevance to each role
- Productivity calculation:
  - "Baseline" curve: compound growth at the baseline growth rate (default 1.5%/year) from 2015 to current year, WITHOUT any AI
  - "With AI" curve: same baseline growth PLUS cumulative AI boosts. For each AI event before the current year, add its weight × (AI Warp Factor / 10) to the cumulative productivity
  - Both curves should be plotted as percentage growth from a starting value of 0% in 2015
- Canvas rendering for the productivity chart:
  - HiDPI support (same as timeline canvas)
  - Y-axis: percentage values with grid lines. Support both linear and logarithmic scale (controlled by the Log Scale toggle)
  - X-axis: years 2015-2026
  - Draw the baseline curve as a dashed amber/yellow line
  - Draw the AI-boosted curve as a solid glowing cyan line with a filled gradient area below
  - The chart should only render up to the current year slider position (not beyond)
  - Show a "current values" bar below the chart with:
    - "Baseline Growth (No AI): +X%" in amber
    - "AI Productivity Multiplier: X.XXx" in magenta
  - Add a legend below the chart: amber dot "No AI (Baseline)" and cyan dot "With AI Tools"
- Role selector: when switching between "Vision Engineer" and "Office Worker", use the corresponding weights from productivityBoosts and re-render
- AI Warp Factor slider: scales the AI boost weights (0 = no AI impact, 10 = maximum impact)
- Baseline Growth slider: changes the compound growth rate for the baseline curve
- Draggable panel splitter:
  - On mousedown on the splitter, start tracking mouse movement
  - On mousemove, resize the two panels by adjusting the CSS grid-template-columns (e.g., "Xfr 15px Yfr")
  - On mouseup, stop dragging
  - Re-render both canvases after each resize
  - Add visual feedback: the splitter bar should glow and expand while dragging
  - Prevent text selection during drag (user-select: none)
- All controls should trigger re-render of both canvases
- Year slider should animate smoothly: both the timeline cursor and the productivity chart endpoint move together
```

**Expected Result:**
- ✅ Productivity chart shows baseline vs. AI-boosted curves
- ✅ Curves respond to year slider (grow over time)
- ✅ Role selector changes productivity weights
- ✅ AI Warp Factor scales the AI impact
- ✅ Log scale toggle works on productivity chart
- ✅ Draggable splitter resizes both panels
- ✅ Current values display updates in real-time

**Discussion Points:**
- How does separating data (productivityBoosts) from rendering logic improve maintainability?
- Why is the multiplicative approach (weights × dependence) better than fixed values?
- What makes the draggable splitter challenging (canvas resize, re-render, event handling)?

---

### Prompt 4: About/Methodology Page & Final Polish (Optional)

**Goal:** Add a "How It Works" methodology page and responsive refinements.

```
Almost done! Add the "How It Works" page and final polish.

Requirements:
- "How It Works" button behavior:
  - Clicking it hides the main container and shows an about-page div
  - The about-page has a sticky "← Back" button (magenta accent) at the top
  - Clicking "Back" hides the about-page and shows the main container again
- About page content with glass-panel styled methodology sections:
  - Section 1 "The Idea": Explain the tool visualizes cumulative AI productivity impact for two roles
  - Section 2 "The Two Charts": Describe the timeline (left) and productivity chart (right)
  - Section 3 "The Formula": Show the productivity formula in a styled code box
  - Section 4 "Evidence Base": A styled table listing real studies with findings (e.g., "GitHub Research 2022: 55% faster task completion", "MIT/Stanford 2023: +14% tasks per hour", "Microsoft Work Trend Index 2024: +29% speed")
  - Section 5 "Assumptions & Limitations": Bullet list of key assumptions
  - Add a methodology note callout (magenta left border, italic text)
- The about page should scroll with a hidden-styled scrollbar (thin, transparent track)
- Add title attributes (tooltips) to all controls explaining what each setting does
- Responsive refinements:
  - Below 1024px: controls grid collapses to fewer columns, panels stack vertically
  - Ensure canvases resize properly when the window or panel dimensions change
```

**Expected Result:**
- ✅ "How It Works" page with methodology explanation
- ✅ Evidence base table with real studies
- ✅ Formula display
- ✅ Smooth page transitions
- ✅ Helpful tooltips on all controls
- ✅ Fully responsive

**Discussion Points:**
- When is a methodology/about page important for data visualizations?
- How does the "hide/show" pattern compare to multi-page navigation?
- What role do tooltips play in self-documenting UIs?

---

## 💡 Key Learnings

### Effective Prompting Strategies

1. **Separate Data from Logic**
   - Define the events array and productivity weights explicitly in the prompt
   - This ensures accuracy — AI milestones have real dates that matter

2. **Canvas Requires Specific Instructions**
   - Unlike DOM elements, canvas rendering needs explicit drawing steps
   - Specify HiDPI support, axis rendering, grid lines, and animation approach

3. **Layer Complexity: Layout → Data → Interaction → Polish**
   - Prompt 1 builds the visual shell with all controls
   - Prompt 2 adds the timeline data and rendering
   - Prompt 3 connects everything with the productivity chart
   - Each layer can be tested independently

4. **Be Precise About Mathematical Models**
   - The productivity formula (compound growth + weighted AI boosts) needs exact description
   - Ambiguity here leads to incorrect visualizations

5. **Interactive Canvas Needs Coordinate Math**
   - Hit detection (hover over dots), tooltip positioning, and exponential time compression
   - Specifying the approach (e.g., "within ~12px radius") prevents guesswork

---

## 🔄 Troubleshooting Tips

| Issue | Solution |
|-------|----------|
| Canvas appears blurry | Ensure devicePixelRatio scaling is applied to canvas width/height |
| Timeline dots misaligned | Verify dateToYear() correctly calculates fractional years |
| Productivity curve looks flat | Check that AI Warp Factor is > 0 and weights are being summed |
| Splitter not working | Ensure mousedown/mousemove/mouseup events are on the correct elements |
| Background animation janky | Reduce animation complexity or use `will-change: transform` |
| Tooltip appears in wrong position | Use `position: fixed` with clientX/clientY, not offsetX/offsetY |
| Provider toggles don't filter | Verify the render function checks toggle state before drawing each event |

---

## 📁 Expected Output

After completing all prompts, you should have:

```
your-workspace/
└── ai-timeline-productivity.html    # Complete single-file application (~1500-2000 lines)
```

The file should:
- Work standalone (no server required)
- Open directly in any modern browser
- Display interactive AI timeline with real milestones
- Calculate and visualize productivity impact
- Offer configurable parameters via sliders and toggles
- Include a methodology/about page

---

## 🎓 Workshop Takeaways

1. **Canvas visualizations need explicit rendering logic** — Unlike DOM, you draw every pixel
2. **Real data beats placeholder data** — Using actual AI release dates creates an authentic result
3. **Mathematical models need careful specification** — Compound growth formulas must be exact
4. **Interactive canvas = coordinate math** — Hit detection, tooltips, and axis scaling are non-trivial
5. **Progressive complexity works** — Shell → Data → Interaction → Polish

---

## 📝 Notes for Facilitators

- Have a working example ready in case of technical issues
- Canvas rendering can be tricky — if a canvas appears blank, check the browser console
- The productivity formula is the most complex part; walk through it with participants
- The draggable splitter (Prompt 3) often needs minor follow-up corrections
- If running short on time, Prompt 4 can be skipped — the visualization is fully functional after Prompt 3
- Encourage participants to experiment with different AI Warp Factor values

---

*Workshop created for AI Café Demo — February 2026*
