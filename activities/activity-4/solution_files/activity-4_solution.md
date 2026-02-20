# Activity 4: Solution — Scale Up & Compare

## Expected Batch Result

```
Batch complete.
  Tickets processed : 500
  Max concurrency   : 10
  Total duration    : 41s
  Status            : ALL SUCCEEDED
```

Typical duration range: **35-50 seconds**.

---

## Side-by-Side Comparison

| Metric                | MAX_CONCURRENCY=2 | MAX_CONCURRENCY=10 |
|-----------------------|--------------------|---------------------|
| Total batch duration  | ~126 s             | ~41 s               |
| Tickets processed     | 500                | 500                 |
| Throughput (tickets/s)| ~4.0               | ~12.2               |

The batch is roughly **3–4x faster** with 5x more concurrency. The speedup is not perfectly linear because of overhead (cold starts, scheduling, network).

---

## Dashboard Observations

### ConcurrentExecutions
- With MAX_CONCURRENCY=2: flat plateau at **2**
- With MAX_CONCURRENCY=10: peak reaches **up to 10**

### Embed Duration p95
- **Roughly the same** (~200–300 ms) in both runs.
- This confirms we did not make individual invocations faster — we ran more of them in parallel.

### Key Insight
The per-invocation cost is unchanged. The improvement comes entirely from **parallelism** — processing more tickets simultaneously.

---

## Explanation

> "We increased **parallel workers (MAX_CONCURRENCY)** from **2** to **10**, which meant **more tickets could be processed simultaneously. The same code, same model, same per-ticket duration — but 5x more items running at once, resulting in ~3–4x faster total batch completion**."

This is **horizontal scaling**: adding more identical workers rather than making each worker faster.

---

## Next Bottleneck (MAX_CONCURRENCY=500)

If we set MAX_CONCURRENCY=500 (one slot per every ticket), several things change:

1. **Lambda cold starts** — 500 Lambda functions spinning up simultaneously means many will be cold starts, each adding 1–3 seconds of initialisation time. This temporarily increases the Embed duration for those invocations.

2. **Account-level concurrency limits** — AWS accounts have a default Lambda concurrency limit (typically 1,000 per region). At 500, we are unlikely to hit it, but in production with multiple services this becomes a real concern.

3. **Diminishing returns** — The batch duration cannot go below the single-execution time (~400 ms) no matter how much concurrency we add. Overhead from scheduling and cold starts means the practical floor is higher.

4. **Cost implications** — More parallel Lambda invocations means higher peak cost (though total compute cost for 500 tickets is the same). In real systems, sustained high concurrency increases spend.

**The next bottleneck** shifts from concurrency to **cold start latency** and **account-level limits**.

---

## Extension — Sweet Spot Results

| MAX_CONCURRENCY | Typical Duration | Throughput (tickets/s) |
|-----------------|------------------|------------------------|
| 2               | ~126 s           | ~4.0                   |
| 5               | ~68 s            | ~7.3                   |
| 10              | ~41 s            | ~12.2                  |
| 20              | ~28 s            | ~ 17.9                 |
| 30              | ~26 s            | ~ 19.2                 |

Diminishing returns become visible between 10 and 20 — the duration improvement gets smaller as cold starts and scheduling overhead begin to dominate. The sweet spot for 500 tickets is probably around **20 concurrent executions**.

---

## ✅ Self-Check

- [ ] Batch of 500 tickets at MAX_CONCURRENCY=10 completed in ~41 seconds
- [ ] Duration is significantly faster than Activity 3 (MAX_CONCURRENCY=2)
- [ ] CloudWatch shows ConcurrentExecutions reaching up to 10
- [ ] Embed Duration p95 per invocation is roughly the same as before
- [ ] You can explain the difference as horizontal scaling (more workers, not faster workers)
- [ ] You can describe what would happen at MAX_CONCURRENCY=500 and name the next bottleneck
