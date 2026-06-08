# Speaker Notes: Token Economy CLI
## English Edition

### Slide 1-5: Introduction & Context

**Slide 1 (Title)**
- Welcome the audience
- "Today we're talking about something that's become critical in the last 6 months: AI is expensive, and we need to be strategic about it."

**Slides 2-5 (Problem & Setup)**
- Set the stage: "You've all been using LLMs. You know they work. But you might not realize what's happening behind the scenes in terms of cost."
- Explain the pipeline briefly: prompt → tokenization → GPU → response. Every step has a cost.
- "This isn't a theoretical problem. I'm going to show you tools that actually work."

---

### Slides 6-18: CLI Tools (fd, rg, yq, xq, jq, snip)

For each tool section, follow this pattern:

1. **Show the problem** (WITHOUT section):
   - "See this? The agent reads 50,000 tokens just to extract one field from a JSON file. That's $0.50 wasted."

2. **Show the solution** (WITH section):
   - "Now with [tool], we tell the agent: 'I already extracted what matters. Here it is.' 200 tokens. Done."

3. **Emphasize the psychological shift**:
   - "It's not about replacing the agent. It's about being smart *before* you call the agent."

---

### Slide 19-20: Decision Tree & AI Integration

**Slide 19 (Decision Tree)**
- "This is your mental model going forward. Bookmark this slide."
- Walk through the tree: "Are you looking for files? Use fd. Text inside? Use rg. A specific field? Use the right extractor."

**Slide 20 (AI Integration)**
- "These tools don't live in a vacuum. They integrate into your workflow at three levels:"
  - **Skills**: Discoverable by agents based on context
  - **Hooks**: Automatic post-processing after tool use
  - **Plugins**: Complete packages you can ship to teams
- "The point is: make the agent *aware* of these options. Let it choose when to use them."

---

### 🎯 **Transition to Slide 21 (CRITICAL MOMENT)**

**Before moving to Slide 21, insert this narrative:**

> *"I created this presentation 3 months ago. Back then, I was focused on the CLI tools—fd, rg, yq. They save 30-90% of tokens. Good return on investment.*
>
> *But on June 1st, something changed. Pricing exploded. API costs didn't just go up by 10 or 20%. On premium models—the ones people actually use for reasoning—we're talking 2x, 3x, sometimes 5x what we paid in March.*
>
> *And that's when I realized: the CLI tools are just the beginning. They're the low-hanging fruit. But there's a bigger question: how do we fundamentally change how we think about AI?*
>
> *That's what the next three slides are about. This isn't just about being cheaper. It's about being smarter, more strategic, and taking back control."*

---

### Slide 21: Beyond - Response Compression

**Caveman & Laconic**
- "These are output reduction strategies. Your agent thinks the same way, but it talks less."
- Emphasize: "65-90% fewer tokens in the response. Same accuracy. Just fewer words."
- "This is about training agents to be concise. To assume the reader knows context."

---

### Slide 22: Beyond - Code Intelligence

**Code Review Graph, AST Indexing**
- "Now we're talking about reducing *input* tokens. The agent doesn't read 27,000 files; it reads only the 15 that matter."
- "Structural indexing is the next frontier. It's not about being faster—it's about being *smarter*."
- Mention: "This requires infrastructure, but it's worth it for large teams."

---

### Slide 23: Why This Matters Now

- "The pricing reality is that every generation of models gets more expensive on premium tiers."
- "You can't optimize your way out of this alone. You need *strategy*."

---

### **Slide 24: Taking Back Control**

**The Core Message:**
- "Six months ago, we ran tests manually. Then we said 'let LLMs do it all.' Now we're realizing that middle path is best: *propose, then decide*."

**What to emphasize:**
- "This isn't about distrust. It's about cost discipline. You know your tests better than the AI does. You filter out noise. You decide what matters."
- "And when you do that—when you *think* before you call the LLM—you save 18,000 tokens. That's $18 per test run. Across a team? Massive."

**Tell the story:**
- "Three months ago, this would've felt paranoid. 'Why would I not trust automation?' But in June 2026? It's just smart operations."

---

### Slide 25: Strategy Over Abundance

**The Tone Here is Optimistic:**
- "This isn't a recession. This is maturity."
- Walk through the three pillars:
  1. **Spec-driven development**: Write clear requirements. Every line saves iterations.
  2. **Right tool selection**: Ask 'does the AI need to do this?' not 'can the AI do this?'
  3. **Deliberate cost accounting**: Track it. Make it visible.

**Key line:**
- "If you're in a team that hasn't started tracking AI spend, you're leaving money on the table. Literally. Someone will notice in Q3."

---

### Slide 26: Infrastructure Reality

**Make it Personal:**
- "Let's put numbers to this. A standard email costs you a tenth of a cent. Feels free, right? It's not."
- "A code debug session? That's 9 grams of CO₂. Do that 50 times a day across your team? You're looking at 450g CO₂ daily. That's real."
- "A deep research agent? One run = 2 km of car driving in terms of CO₂."

**The Big Picture:**
- "Behind every API call are servers consuming 10-12 kilowatts. The price per token fell 90% since 2024. But *volume* exploded. Global AI emissions are in the tens of millions of tonnes yearly."

**Close with:**
- "This doesn't mean stop using AI. It means use it *deliberately*. Choose your battles. Make every call count."

---

## General Delivery Tips

1. **Pace**: Spend ~2 min per tool (slides 6-18), 5 min on the transition + slides 21-26. Total ~40-50 min for deep dive.

2. **Audience Engagement**:
   - Ask: "Who's run a build with verbose output and fed the whole thing to an LLM?" (Hands up)
   - Then: "That's 18,000 tokens you didn't need to spend."

3. **The Turning Point** (Slide 24):
   - This is where the talk shifts from "here are tools" to "here's why we need a new mindset."
   - Slow down. Let it land.

4. **Close Strong** (Slide 26):
   - End with: "The golden age of infinite AI was fun. It's over. The strategic age has begun. Be on the right side of that transition."

---

## Q&A Anticipation

**Q: "Doesn't this slow down development?"**
- A: "No. It speeds it up. When you think *before* you ask, you ask better questions. Better questions = better answers = fewer iterations."

**Q: "What about teams with unlimited budgets?"**
- A: "Even they benefit from this. Fewer tokens = faster response time. Faster response time = more iterations = better product."

**Q: "Is this about cost or environment?"**
- A: "Both. They're the same thing. If you understand the cost, you understand the environmental impact."
