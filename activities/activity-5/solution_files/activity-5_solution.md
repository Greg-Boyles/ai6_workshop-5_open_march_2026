# Activity 5: Solution — Understand Orchestration (Reading the Logs)

---

## Task 2 — State Machine Definition

The Map state is the key orchestration construct. It:
- Iterates over an array of ticket inputs
- Runs the Preprocess > Embed > Postprocess sub-workflow for each item
- Uses **MaxConcurrency** to control how many items run in parallel at the same time

---

## Task 3 — Execution Comparison

| Metric | Activity 3 (low concurrency) | Activity 4 (high concurrency) |
|---|---|---|
| MaxConcurrency | 2 | 10 |
| Batch duration | ~120-180 seconds | ~35-50 seconds |
| ConcurrentExecutions | 2 | up to 10 |
| Items processed | 500 | 500 |

The high concurrency run processed the same number of items in significantly less time because more items were processed in parallel.

---

## Task 5 — Query 1 Output

You should see log entries from all three functions: preprocess, embed, and postprocess. Each entry contains a JSON-structured message with fields like `step`, `ticket_id`, and `duration_ms`.

---

## Task 6 — Query 2 Output

``` sql
fields step, ticket_id, duration_ms
| filter ispresent(step) and ispresent(ticket_id) and ispresent(duration_ms)
| display step, ticket_id, duration_ms
```

The parsed output should show distinct columns:
- **step:** preprocess, embed, or postprocess
- **ticket_id:** the unique ID for each support ticket
- **duration_ms:** how long that step took in milliseconds

---

## Task 7 — Query 3 Output (Expected Results)

``` sql
fields step, duration_ms
| filter ispresent(step) and ispresent(duration_ms)
| stats 
    avg(duration_ms) as avg_duration_ms,
    max(duration_ms) as max_duration_ms,
    count(*) as count
  by step
| sort step asc
```

| step | avg_ms | max_ms | n |
|---|---|---|---|
| embed | ~250 | ~300 | 500 |
| preprocess | ~0.01 | ~0.02 | 500 |
| postprocess | ~0.03 | ~0.1 | 500 |

The **Embed** step dominates processing time at approximately 250ms on average, compared to roughly <1ms for the other steps. This is expected — embedding involves a model inference call, which is computationally heavier than text preprocessing or result writing.

---

## Task 8 — Model Answer

> **"How does orchestration help you see where time is spent?"**

Orchestration isolates each processing step (Preprocess, Embed, Postprocess) into separate Lambda functions with separate log groups. This means:

1. **Visibility:** Each step emits its own structured logs with duration metrics, so you can pinpoint exactly which step is the bottleneck without reading through a monolithic application log.
2. **Control:** The Map state's MaxConcurrency parameter gives you a single dial to control parallelism. You can increase it to process more items simultaneously, or decrease it to stay within resource limits.
3. **Aggregation:** CloudWatch Logs Insights lets you run SQL-like queries across all log groups at once, computing averages, maximums, and counts by step — turning raw logs into actionable metrics.

Without orchestration, all three steps would run inside a single function, making it much harder to isolate where time is being spent.

---

## Extension — Longest Embed Duration Query

```sql
fields @timestamp, @message
| parse @message /"step"\s*:\s*"(?<step>[^"]+)"/
| parse @message /"duration_ms"\s*:\s*(?<duration_ms>\d+)/
| parse @message /"ticket_id"\s*:\s*"(?<ticket_id>[^"]+)"/
| filter step = "embed"
| sort duration_ms desc
| limit 1
```

This query filters to only embed steps, sorts by duration descending, and returns the single ticket with the longest embed time.

---

## Self-Check Checklist

- [ ] All three queries ran without errors
- [ ] Query 3 shows Embed with the highest avg_ms (~250ms)
- [ ] I can explain why orchestration provides better visibility than a monolithic function
- [ ] I understand what MaxConcurrency controls
- [ ] I can write a Logs Insights query using `parse` and `stats`
