# Activity 3: Hit the Wall (Burst Load at Low Concurrency)

**Primary KSB:** S19 — Ensure the model capacity is scaled in proportion to the operating requirements

🎯 **Learning Objective:** Create a burst load that demonstrates the throughput bottleneck and collect evidence

## AWS Docs (Core Services)

See [AWS service docs and key quotes](../../docs/aws_service_docs.md).

## 📋 Expected Outputs

- Batch execution completed with measurable duration
- CloudWatch Dashboard evidence of the concurrency wall
- A completed Scaling Map identifying the bottleneck step
- Answer to: "Which step is the bottleneck? What evidence proves it?"

---

## 📝 Task 1 — Send a Burst of 500 Tickets at Low Concurrency

📘 **Note:** In this workshop, the scaling knob you are tuning is Step Functions Map `max_concurrency` (passed as `MAX_CONCURRENCY` in the script), rather than Lambda reserved concurrency.

Run the burst-load script with 500 tickets and a maximum concurrency of 2:

⌨️ **Terminal:**

```bash
N=500 MAX_CONCURRENCY=2 ./scripts/03_burst_load.sh
```

This sends 500 tickets through the pipeline, but only allows **2 executions to run in parallel** at any time.

✅ **Checkpoint:** The script completes and prints the total batch duration.

---

## 📝 Task 2 — Record the Batch Duration

When the script finishes, it prints a summary. Record the total duration:

| Metric              | Your Value |
|---------------------|------------|
| Total batch duration |           |
| Tickets processed    | 500        |
| Max concurrency      | 2         |

---

## 📝 Task 3 — Observe the Dashboard

💻 **Console:**

1. Navigate to **CloudWatch** > **Dashboards** > open your dashboard. (If you've left this open from a previous activity, you may need to click the refresh button in the top-right.)
2. Look at the following widgets:
   - **Embed Duration p95** — how long is each Embed invocation taking?
   - **ConcurrentExecutions** — does it plateau at 2?
3. Notice the pattern: tickets are queuing up because only 2 can run at once.

💡 **Tip:** The dashboard may take **1–2 minutes** to update after the burst completes. Refresh the page if metrics appear stale.

📘 **Step duration vs Duration p95:** In the previous activity, you read the duration of individual iterations of steps in the state machine graph. These durations will differ from the logged p95 durations in the dashboard. The origins of these two values are different; the latter comes directly from calculations in the lamda, while the former is AWS-determined. It's *not* the case that one is correct and the other is wrong, and it's also *not* the case that one is more useful than the other; they serve slightly different purposes.

✅ **Checkpoint:** The dashboard shows concurrency and duration signals you can use as evidence.

---

## 📝 Task 4 — Complete the Scaling Map

Work through the Scaling Map exercise below. This helps you systematically identify which part of the pipeline to scale.

### Step 1 — Name the 3 pipeline steps

1. **_______________**
2. **_______________**
3. **_______________**

### Step 2 — For each step, answer the 3 questions

#### Preprocess (pre-model)
- **A) What does this step do?**
  _Your answer:_

- **B) What scaling knob exists?**
  _Your answer:_

- **C) What does failure under load look like?**
  _Your answer:_

#### Embed / Model (inference)
- **A) What does this step do?**
  _Your answer:_

- **B) What scaling knob exists?**
  _Your answer:_

- **C) What does failure under load look like?**
  _Your answer:_

#### Postprocess (post-model)
- **A) What does this step do?**
  _Your answer:_

- **B) What scaling knob exists?**
  _Your answer:_

- **C) What does failure under load look like?**
  _Your answer:_

### Step 3 — Decide: which step do you scale FIRST?

Pick the step that is both:
1. **Slowest** (duration p95)
2. And/or **rejecting work** (throttles/errors)

> "I would scale **___** first because **___**."

---

## 📝 Task 5 — Answer the Bottleneck Question

Using your dashboard evidence and scaling map, answer:

> "Which step is the bottleneck? What evidence proves it?"

Write 2–3 sentences referencing specific metrics from the dashboard.

<details>
<summary><strong>Hint: what you should observe</strong></summary>

- With `MAX_CONCURRENCY=2`, the pipeline should feel like it is “queueing” work: the batch duration is noticeably longer than a single execution.
- On the dashboard, **ConcurrentExecutions** should flatten at (or near) your configured concurrency, and the Embed step should be the most time-consuming per item.

</details>

<details>
<summary><strong>Example answer (optional)</strong></summary>

- "The bottleneck is **Embed**, because it has the highest duration and the system can only process **2 items in parallel** (ConcurrentExecutions plateaus), so items wait their turn."
- "I would scale **Embed** first because it dominates the per-item latency and controls overall throughput under a Map state."

</details>

---

🎓 **Complete** — proceed to [Activity 4](../activity-4/activity-4_start.md)
