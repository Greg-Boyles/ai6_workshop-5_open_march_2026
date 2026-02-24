# Activity 7: Controlled Failure — Throttling (RCA Incident 2 + Fishbone)

**Primary KSB:** S26 — Decision-making with evidence; B2 — Sustainable outcomes; S10 — Monitoring

🎯 **Learning Objective:** Classify a throughput bottleneck using both the RCA Tree and Fishbone framework, then apply the fix and verify

## AWS Docs (Core Services)

See [AWS service docs and key quotes](../../docs/aws_service_docs.md).

---

## 📋 Expected Outputs

- Completed Fishbone diagram with at least one evidence-backed cause
- Before/after comparison of batch duration and ConcurrentExecutions
- A full incident report separating evidence from hypothesis

---

## Context — A Different Kind of Failure

In Activity 6 you classified a **BAD INPUT** failure: a single oversized payload that failed immediately, before any load was applied. That was a data quality issue — nothing to do with capacity.

This activity is a different failure mode. The pipeline is healthy and the data is valid, but **too many items arrive at once**. The bottleneck is throughput, not data. You will:

1. Use the RCA Tree again — but this time reach a different leaf (THROTTLED)
2. Apply the **Fishbone** framework to structure your diagnostic reasoning
3. **Apply the fix and verify** — measure the before/after improvement

---

## 📝 Task 1 — Recall or Re-run the Burst Test

Recall the burst test from Activity 3, where you ran 500 tickets with low concurrency. If you need to re-run it:

⌨️ **Terminal:**

```bash
N=500 MAX_CONCURRENCY=2 ./scripts/03_burst_load.sh
```

Record the batch duration: ___ seconds.

---

## 📝 Task 2 — Examine the CloudWatch Dashboard

1. Open the **CloudWatch** dashboard for the workshop.
2. Look at the following metrics:
   - **Embed Duration p95** — how long is the slowest embed call?
   - **ConcurrentExecutions** — how many Lambda functions are running at the same time?

💻 **Console:** CloudWatch > Dashboards > AI6-Unit5W-ScaleOrFail-dashboard (or open the dashboard matching the `DashboardName` output from Activity 1)

✅ **Checkpoint:** You can see signals that help you decide whether this is a capacity/concurrency issue.

---

## 📝 Task 3 — Classify Using the RCA Tree

Use the Scaling RCA Tree to classify this incident:

### Scaling RCA Tree (4 leaves)

**1) THROTTLED (hard limit)** — Throttles > 0, TooManyRequests errors. Cause: concurrency too low.

**2) EXHAUSTED (resource)** — High p95 at low traffic, OutOfMemory. Cause: model too heavy.

**3) TIMED OUT (dependency)** — Duration grows, retries. Cause: external API slow.

**4) BAD INPUT (data)** — Immediate failures, validation errors. Cause: no validation gate.

Which leaf matches? Write your classification: _______________________________________________

💡 **Tip:** The key evidence is that ConcurrentExecutions is capped at 2 while 500 items are waiting. The per-request duration is normal — the bottleneck is throughput, not per-request performance.

---

## 📝 Task 4 — Complete the Fishbone Diagnostic

### Fishbone Diagnostic: "Why didn't it scale?"

**Effect (head of the fish):** Pipeline slow during traffic spike

**Bones (categories):**

| Bone | Possible Causes |
|---|---|
| **1. Limits / Throttling** | concurrency too low, quotas, rate limits |
| **2. Resources** | memory too low, CPU, cold starts |
| **3. Dependencies** | external API slow, downstream throttling, network |
| **4. Data / Input** | payload too big, schema mismatch, distribution shift |

**Rules:**
- You CANNOT add a cause to a bone unless you can point to a metric or log entry
- Evidence first, then causes, then one safe action

Fill in:

1. **Which bone does your evidence point to?** _______________________________________________
2. **What specific metric or log proves it?** _______________________________________________
3. **What is one safe, reversible action to restore service?** _______________________________________________

⚠️ **Warning:** Separate "Evidence" (what the metrics say) from "Hypothesis" (what you think the cause is). This is integrity in technical decision-making (B4).

---

## 📝 Task 5 — Apply the Fix

Re-run the burst test with higher concurrency:

⌨️ **Terminal:**

```bash
N=500 MAX_CONCURRENCY=10 ./scripts/03_burst_load.sh
```

Record the batch duration: ___ seconds.

---

## 📝 Task 6 — Compare Before and After

Fill in the comparison table:

| Metric | Before (MAX_CONCURRENCY=2) | After (MAX_CONCURRENCY=10) |
|---|---|---|
| Batch duration | ___ seconds | ___ seconds |
| ConcurrentExecutions | ___ | ___ |
| Items processed | 500 | 500 |
| Per-item p95 duration | ___ ms | ___ ms |

✅ **Checkpoint:** You can compare before/after results using metrics and duration evidence.

---

## 📝 Task 7 — Write a Full Incident Report

Complete the following incident report:

- **What happened:** _______________________________________________
- **Evidence:** _______________________________________________
- **Hypothesis:** _______________________________________________
- **Classification:** _______________________________________________
- **Fishbone bone:** _______________________________________________
- **Fix applied:** _______________________________________________
- **Result after fix:** _______________________________________________

⚠️ **Warning:** Your **Evidence** line must reference a specific metric or log entry. Your **Hypothesis** line must be labelled as a hypothesis, not stated as fact. This distinction matters in production incident reviews.

<details>
<summary><strong>Hint: what you should observe</strong></summary>

- Under burst load with low `MAX_CONCURRENCY`, **ConcurrentExecutions** flattens at your configured limit and total batch duration climbs because work queues up.
- The RCA Tree classification should point to **THROTTLED (hard limit)** (capacity constrained by concurrency), not BAD INPUT.
- After increasing concurrency, batch duration should improve substantially while per-item p95 duration is often similar.

</details>

<details>
<summary><strong>Example answer (optional)</strong></summary>

- **Evidence:** "ConcurrentExecutions plateaued at 2 during the burst; overall duration rose even though per-item latency looked normal."
- **Hypothesis:** "We are throughput-limited by Map/Lambda concurrency."
- **Classification:** "THROTTLED (hard limit)."
- **Fix applied:** "Increase MaxConcurrency (e.g. 2 -> 10) and rerun."
- **Result after fix:** "Total batch duration decreased and ConcurrentExecutions increased toward the new limit."

</details>

---

🚀 **Extension:** If you increased MAX_CONCURRENCY to 500, what would be the next bottleneck? Think about:
- Lambda account-level concurrency limits (default: 1,000 across all functions — though note the Pluralsight sandbox caps this at 10, so even MAX_CONCURRENCY=11 would fail here with a `TooManyRequestsException`)
- Cold starts when many new execution environments spin up at once
- Whether the embed model API could handle 500 simultaneous requests

---

🎓 **Complete** — Proceed to [Activity 8: Evidence Portfolio & Reflection](../activity-8/activity-8_start.md)
