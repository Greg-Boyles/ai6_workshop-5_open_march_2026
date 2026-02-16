# Activity 4: Solution — Scale Up & Compare

## Expected Batch Result

```
Batch complete.
  Tickets processed : 40
  Max concurrency   : 10
  Total duration    : 5.2s
  Status            : ALL SUCCEEDED
```

Typical duration range: **4–7 seconds**.

---

## Side-by-Side Comparison

| Metric                | MAX_CONCURRENCY=2 | MAX_CONCURRENCY=10 |
|-----------------------|--------------------|---------------------|
| Total batch duration  | ~17 s              | ~5 s                |
| Tickets processed     | 40                 | 40                  |
| Throughput (tickets/s)| ~2.4               | ~8                  |

The batch is roughly **3–4x faster** with 5x more concurrency. The speedup is not perfectly linear because of overhead (cold starts, scheduling, network).

---

## Dashboard Observations

### ConcurrentExecutions
- With MAX_CONCURRENCY=2: flat plateau at **2**
- With MAX_CONCURRENCY=10: peak reaches **up to 10**

### Embed Duration p95
- **Roughly the same** (~200–400 ms) in both runs.
- This confirms we did not make individual invocations faster — we ran more of them in parallel.

### Key Insight
The per-invocation cost is unchanged. The improvement comes entirely from **parallelism** — processing more tickets simultaneously.

---

## Explanation

> "We increased **parallel workers (MAX_CONCURRENCY)** from **2** to **10**, which meant **more tickets could be processed simultaneously. The same code, same model, same per-ticket duration — but 5x more items running at once, resulting in ~3–4x faster total batch completion**."

This is **horizontal scaling**: adding more identical workers rather than making each worker faster.

---

## Next Bottleneck (MAX_CONCURRENCY=40)

If we set MAX_CONCURRENCY=40 (one slot per every ticket), several things change:

1. **Lambda cold starts** — 40 Lambda functions spinning up simultaneously means many will be cold starts, each adding 1–3 seconds of initialization time. This temporarily increases the Embed duration for those invocations.

2. **Account-level concurrency limits** — AWS accounts have a default Lambda concurrency limit (typically 1,000 per region). At 40, we are unlikely to hit it, but in production with multiple services this becomes a real concern.

3. **Diminishing returns** — The batch duration cannot go below the single-execution time (~400 ms) no matter how much concurrency we add. Overhead from scheduling and cold starts means the practical floor is higher.

4. **Cost implications** — More parallel Lambda invocations means higher peak cost (though total compute cost for 40 tickets is the same). In real systems, sustained high concurrency increases spend.

**The next bottleneck** shifts from concurrency to **cold start latency** and **account-level limits**.

---

## Extension — Sweet Spot Results

| MAX_CONCURRENCY | Typical Duration | Throughput (tickets/s) |
|-----------------|------------------|------------------------|
| 2               | ~17 s            | ~2.4                   |
| 5               | ~8 s             | ~5.0                   |
| 10              | ~5 s             | ~8.0                   |
| 20              | ~3.5 s           | ~11.4                  |

Diminishing returns become visible between 10 and 20 — the duration improvement gets smaller as cold starts and scheduling overhead begin to dominate. The sweet spot for 40 tickets is typically around **10–15 concurrent executions**.

---

## ✅ Self-Check

- [ ] Batch of 40 tickets at MAX_CONCURRENCY=10 completed in ~4–7 seconds
- [ ] Duration is significantly faster than Activity 3 (MAX_CONCURRENCY=2)
- [ ] CloudWatch shows ConcurrentExecutions reaching up to 10
- [ ] Embed Duration p95 per invocation is roughly the same as before
- [ ] You can explain the difference as horizontal scaling (more workers, not faster workers)
- [ ] You can describe what would happen at MAX_CONCURRENCY=40 and name the next bottleneck
