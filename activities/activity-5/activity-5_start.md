# Activity 5: Understand Orchestration (Reading the Logs)

**Primary KSB:** K12 — Deployment approaches; S10 — Monitoring in live environment

🎯 **Learning Objective:** Understand how Step Functions orchestration provides visibility and control over parallel processing

## AWS Docs (Core Services)

See [AWS service docs and key quotes](../../docs/aws_service_docs.md).

---

## 📋 Expected Outputs

- Three CloudWatch Logs Insights queries executed successfully
- Understanding of which pipeline step takes the most time
- Written answer: "How does orchestration help you see where time is spent?"

---

## 📝 Task 1 — Open the State Machine

1. Open **Step Functions** > **State machines** in the AWS Console.
2. Click **AI6-Unit5W-ScaleOrFail-state-machine** to open the state machine (or use the `StateMachineArn` output from Activity 1).

💻 **Console:** Step Functions > State machines > AI6-Unit5W-ScaleOrFail-state-machine

---

## 📝 Task 2 — Examine the State Machine Definition

1. View the state machine definition in the **visual editor**.
2. Identify the **Map state** — this is the parallel processing construct.
3. Find the **MaxConcurrency** parameter on the Map state.

✅ **Checkpoint:** You can see the Map state and its MaxConcurrency value in the definition.

💡 **Tip:** The Map state iterates over an array of inputs and runs a sub-workflow for each item. MaxConcurrency controls how many run in parallel.

---

## 📝 Task 3 — Compare Execution Histories

1. Go to the **Executions** tab.
2. Open the execution from Activity 3 (low concurrency run) in one browser tab.
3. Open the execution from Activity 4 (high concurrency run) in another browser tab.
4. Compare side-by-side:
   - How long did each batch take?
   - How many items processed in parallel?
   - Where did time stack up?

✅ **Checkpoint:** You can see the difference in execution duration and parallelism between the two runs.

---

## 📝 Task 4 — Open CloudWatch Logs Insights

1. Open **CloudWatch** > **Logs Insights** in the AWS Console.

💻 **Console:** CloudWatch > Logs > Logs Insights

2. Select the following log groups (tick all three):
   - `/aws/lambda/AI6-Unit5W-ScaleOrFail-preprocess`
   - `/aws/lambda/AI6-Unit5W-ScaleOrFail-embed`
   - `/aws/lambda/AI6-Unit5W-ScaleOrFail-postprocess`

⚠️ **Warning:** Make sure all three log groups are selected before running queries, or you will only see partial results.

---

## 📝 Task 5 — Query 1: Recent Log Lines

Paste the following query and click **Run query**:

```sql
fields @timestamp, @message
| filter @timestamp > ago(15m)
| sort @timestamp desc
| limit 50
```

This shows the most recent 50 log lines across all three Lambda functions.

✅ **Checkpoint:** You see log entries from preprocess, embed, and postprocess functions.

---

## 📝 Task 6 — Query 2: Extract Structured Fields (Try It First)

Write a Logs Insights query that extracts:
- `step`
- `ticket_id`
- `duration_ms`

Then display those fields in a table.

✅ **Checkpoint:** You can see columns for step, ticket_id, and duration_ms in the results.

---

## 📝 Task 7 — Query 3: Aggregate Duration by Step (Try It First)

Write a Logs Insights query that calculates:
- average duration by `step`
- max duration by `step`
- count by `step`

✅ **Checkpoint:** You can see the slowest step when you sort by average duration.

---

## 📝 Task 8 — Answer the Question

Write your answer to this question:

> **"How does orchestration help you see where time is spent?"**

Think about:
- How the Map state separates each ticket's processing into distinct steps
- How MaxConcurrency controls throughput
- How Logs Insights lets you aggregate and compare step durations

<details>
<summary><strong>Hint: what you should observe</strong></summary>

If you want a working solution for Query 2:

```sql
fields @timestamp, @message
| filter @timestamp > ago(15m)
| parse @message /"step"\s*:\s*"(?<step>[^"]+)"/
| parse @message /"duration_ms"\s*:\s*(?<duration_ms>\d+)/
| parse @message /"ticket_id"\s*:\s*"(?<ticket_id>[^"]+)"/
| display @timestamp, step, ticket_id, duration_ms, @message
| sort @timestamp desc
| limit 100
```

And for Query 3:

```sql
fields @timestamp, @message
| filter @timestamp > ago(15m)
| parse @message /"step"\s*:\s*"(?<step>[^"]+)"/
| parse @message /"duration_ms"\s*:\s*(?<duration_ms>\d+)/
| stats avg(duration_ms) as avg_ms, max(duration_ms) as max_ms, count(*) as n by step
| sort avg_ms desc
```

You should see **Embed** at (or near) the top by `avg_ms`.

</details>

<details>
<summary><strong>Example answer (optional)</strong></summary>

> "Orchestration breaks the work into named steps and makes parallelism explicit (Map + MaxConcurrency). That lets you measure where time is spent per step (logs/metrics) and change throughput by tuning concurrency, without guessing."

</details>

---

🚀 **Extension:** Write your own Logs Insights query to find the ticket with the longest Embed duration. What ticket_id had the slowest embed step?

---

🎓 **Complete** — Proceed to [Activity 6: Controlled Failure — Bad Input](../activity-6/activity-6_start.md)
