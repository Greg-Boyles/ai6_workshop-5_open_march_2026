# Activity 3: Solution — Hit the Wall (Burst Load at Low Concurrency)

## Expected Batch Result

```
Batch complete.
  Tickets processed : 500
  Max concurrency   : 2
  Total duration    : 126s
  Status            : ALL SUCCEEDED
```

Typical duration range: **120–180 seconds**.

Why so slow? With only 2 parallel slots, the pipeline processes tickets roughly 2 at a time. Each ticket takes ~500 ms end-to-end, so 500 tickets / 2 concurrency = ~250 sequential batches of ~500 ms each.

---

## Dashboard Evidence

### ConcurrentExecutions
- The graph shows a **flat plateau at 2** for the duration of the burst.
- This is the concurrency ceiling imposed by `MAX_CONCURRENCY=2`.

### Embed Duration p95
- The Embed step consistently shows **~200–300 ms** per invocation.
- Preprocess and Postprocess remain at **<1 ms**.
- The Embed step dominates the total execution time.

---

## Completed Scaling Map

### Step 1 — Name the 3 pipeline steps

1. **Preprocess**
2. **Embed**
3. **Postprocess**

### Step 2 — For each step, answer the 3 questions

#### Preprocess (pre-model)
- **A) What does this step do?**
  Validates and cleans the input ticket text so downstream steps receive safe, well-formed data.

- **B) What scaling knob exists?**
  Lambda concurrency (horizontal scaling) and memory/CPU per invocation (vertical scaling).

- **C) What does failure under load look like?**
  Input validation errors, schema mismatches, CPU spikes (rare — this step is lightweight).

#### Embed / Model (inference)
- **A) What does this step do?**
  Converts the ticket text into a semantic vector representation (sentence embedding) and classifies the support route.

- **B) What scaling knob exists?**
  Lambda concurrency (horizontal) and memory/CPU per invocation (vertical). This is usually the bottleneck because the ML model is compute-intensive.

- **C) What does failure under load look like?**
  Throttling, long durations, timeouts, cold starts, memory pressure / out-of-memory errors.

#### Postprocess (post-model)
- **A) What does this step do?**
  Applies business rules (priority assignment, action recommendation) and formats the final response.

- **B) What scaling knob exists?**
  Lambda concurrency, but this step is fast. In real systems it can become a dependency bottleneck if it calls external services.

- **C) What does failure under load look like?**
  Slow dependency symptoms (timeouts to downstream APIs), retries, message backlogs.

### Step 3 — Which step to scale first?

> "I would scale **Embed** first because **it has the highest p95 duration (~250 ms vs ~1 ms for other steps) and is the compute-intensive ML inference step. The ConcurrentExecutions metric confirms it is the constraint — only 2 can run at a time, creating a queue**."

---

## Bottleneck Answer

> "The bottleneck is the **Embed** step. Evidence: (1) ConcurrentExecutions plateaus at exactly 2, meaning tickets are queuing rather than running in parallel. (2) Embed Duration p95 is ~250 ms, which is hundreds of times longer than Preprocess or Postprocess. (3) The total batch time (~126s s) closely matches the theoretical minimum of 500 tickets / 2 concurrency * ~500 ms per execution."

---

## Extension — N=750 Results

| Scenario                     | Typical Duration |
|------------------------------|------------------|
| N=500, MAX_CONCURRENCY=2     | ~120-180 s         |
| N=750, MAX_CONCURRENCY=2     | ~180-270 s         |

The wall gets proportionally worse: more tickets with the same concurrency ceiling means a longer queue.

---

## ✅ Self-Check

- [ ] Batch of 500 tickets completed with `ALL SUCCEEDED`
- [ ] Batch duration was approximately 120-180 seconds
- [ ] CloudWatch Dashboard shows ConcurrentExecutions plateauing at 2
- [ ] Embed Duration p95 is clearly the dominant step (~200–400 ms)
- [ ] Scaling Map is fully completed with answers for all three steps
- [ ] You can explain why Embed is the bottleneck using metric evidence
