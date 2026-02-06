# Workshop: Building an Interactive Web Application with AI

## Iterative Prompting with GitHub Copilot

---

## 🎯 Goal

Create an interactive single-page web application that visualizes and compares Human vs AI capabilities using radar charts. Participants will learn how to:

1. **Start with a clear initial prompt** to establish the foundation
2. **Iterate with focused correction prompts** to add features
3. **Polish and refine** with a final prompt for professional finishing touches

By the end of this workshop, you will have built a fully functional, visually appealing comparison tool - entirely through conversational prompting.

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
| Prompt 1 | 10-15 min | Create the foundation |
| Review & Discuss | 5 min | Analyze the result |
| Prompt 2 | 10-15 min | Add interactivity |
| Review & Discuss | 5 min | Analyze improvements |
| Prompt 3 | 10-15 min | Polish and finalize |
| Final Review | 5-10 min | Test and discuss learnings |

**Total: ~60-75 minutes**

---

## 🚀 The Prompts

### Prompt 1: Foundation

**Goal:** Create the basic structure with visual design and core functionality.

```
Create a single HTML file that compares Human vs AI capabilities using radar charts. 

Requirements:
- Dark futuristic design with gradient background
- Two radar charts side by side: Human (cyan color) and AI (magenta color)
- 24 attributes organized in 6 groups: Cognitive, Learning & Expertise, Drive & Execution, Creative & Intuitive, Social & Emotional, Self & Physical
- Sliders on the left for Human values, sliders on the right for AI values (scale 1-10)
- Use vanilla JavaScript with Canvas - no external libraries
- Make it responsive
```

**Expected Result:**
- ✅ Dark themed single HTML file
- ✅ Two radar charts displaying
- ✅ Slider panels on left and right
- ✅ Basic responsive layout

**Discussion Points:**
- How specific should the initial prompt be?
- What did the AI assume vs. what did we specify?

---

### Prompt 2: Add Interactivity

**Goal:** Enhance the application with interactive features and data persistence.

```
Great start! Now add these features:

- Add a "Combine" button that merges both charts into one "Best of Both Worlds" view with smooth crossfade animation
- The combined chart should show the maximum value of each attribute, with point colors indicating who leads (cyan for Human, magenta for AI)
- Add tooltips when hovering over attribute names
- Synchronize scrolling between the two slider panels
- Save all values to localStorage so they persist on reload
```

**Expected Result:**
- ✅ Combine/Separate toggle with animation
- ✅ Combined chart with color-coded points
- ✅ Tooltips on attribute names
- ✅ Synchronized panel scrolling
- ✅ Values persist after page reload

**Discussion Points:**
- Why start with positive feedback ("Great start!")?
- How to balance between too many features vs. too few per prompt?

---

### Prompt 3: Polish and Professional Touches

**Goal:** Add final polish, user controls, and export functionality.

```
Almost perfect! Final improvements:

- Add display controls to adjust label positioning, font size and radar size (with separate settings for normal and combined view)
- Add Export/Import buttons to save and load settings as JSON file
- Add a Reset to Defaults button
- The title should change from "Human vs AI" to "Human + AI" when combined, with matching neon yellow color scheme
- Add glow effects to the slider thumbs and chart borders
```

**Expected Result:**
- ✅ Display control sliders (collapsible panel)
- ✅ Export/Import JSON functionality
- ✅ Reset to defaults button
- ✅ Dynamic title with color transition
- ✅ Glowing visual effects

**Discussion Points:**
- How do correction prompts build on previous context?
- When is "good enough" actually good enough?

---

## 💡 Key Learnings

### Effective Prompting Strategies

1. **Be Specific About Technology**
   - "vanilla JavaScript" prevents external dependencies
   - "Canvas" directs the implementation approach

2. **Describe Visual Intent**
   - "Dark futuristic design" sets the mood
   - Specific colors ("cyan", "magenta") ensure consistency

3. **Structure Your Requirements**
   - Use bullet points for clarity
   - Group related features together

4. **Iterate with Context**
   - Build on previous results
   - Reference existing elements ("the combined chart should...")

5. **Give Positive Feedback**
   - "Great start!" and "Almost perfect!" maintain context
   - Signals continuation rather than replacement

---

## 🔄 Troubleshooting Tips

| Issue | Solution |
|-------|----------|
| Chart not displaying | Check browser console for Canvas errors |
| Sliders not updating chart | Verify event listeners are connected |
| Layout broken on mobile | Ask to "fix responsive layout for mobile portrait mode" |
| Colors look wrong | Be more specific: "use #00ffff for cyan" |
| Animation too fast/slow | Specify: "use 1.2 second transition" |

---

## 📁 Expected Output

After completing all three prompts, you should have:

```
your-workspace/
└── human-ai-comparison.html    # Complete single-file application (~1000-1500 lines)
```

The file should:
- Work standalone (no server required)
- Open directly in any modern browser
- Save settings automatically
- Export/Import configurations as JSON

---

## 🎓 Workshop Takeaways

1. **Start broad, then refine** - Your first prompt creates the foundation
2. **Iterate in focused steps** - Each prompt should have a clear purpose
3. **Context is preserved** - Copilot remembers previous responses in the conversation
4. **Be specific about what matters** - Colors, animations, behavior
5. **Trust but verify** - Always test the output in a real browser

---

## 📝 Notes for Facilitators

- Have a working example ready in case of technical issues
- Encourage participants to experiment with variations
- Discuss how different phrasings might yield different results
- Time buffer: Some prompts may need minor follow-up corrections

---

*Workshop created for AI Café - February 2nd, 2026*
