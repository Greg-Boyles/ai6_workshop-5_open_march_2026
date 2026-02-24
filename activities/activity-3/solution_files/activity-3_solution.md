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

#### Preprocess (pre-model)
- **What does this step do?**
  Validates and cleans the input ticket text so downstream steps receive safe, well-formed data.

- **What is the scaling knob?**
  The Step Functions Map `max_concurrency` setting — it controls how many pipeline iterations run in parallel, and therefore how many Preprocess invocations run at once.

- **Speculate: what might failure under load look like?**
  Failures here are more likely to be data-related than capacity-related — for example, a ticket with an oversized or malformed payload causing an immediate validation error.

#### Embed / Model (inference)
- **What does this step do?**
  Converts the ticket text into a semantic vector representation (sentence embedding) and classifies the support route.

- **What is the scaling knob?**
  The Step Functions Map `max_concurrency` setting — same knob as the other steps, but Embed feels it most because it is the slowest step in each iteration.

- **Speculate: what might failure under load look like?**
  Long durations, throttling, timeouts, cold starts, or memory pressure as more requests pile up than Lambda can serve concurrently.

#### Postprocess (post-model)
- **What does this step do?**
  Applies business rules (priority assignment, action recommendation) and formats the final response.

- **What is the scaling knob?**
  The Step Functions Map `max_concurrency` setting — same knob, but this step is so fast it rarely becomes the constraint.

- **Speculate: what might failure under load look like?**
  If this step calls external services, slow or unavailable dependencies could cause timeouts, retries, or message backlogs under load.

### Decide: which step do you scale FIRST?

> "I would scale **Embed** first because **it has the highest p95 duration (~250 ms vs ~1 ms for other steps) and is the compute-intensive ML inference step. The ConcurrentExecutions metric confirms it is the constraint — only 2 can run at a time, so additional tickets must wait their turn**."

---

## Bottleneck Answer

> "The bottleneck is the **Embed** step. Evidence: (1) ConcurrentExecutions plateaus at exactly 2 — the chart shows the ceiling directly, from which we can infer that additional tickets must wait their turn. (2) Embed Duration p95 is ~250 ms, which is hundreds of times longer than Preprocess or Postprocess. (3) The total batch time (~126s) closely matches the theoretical minimum of 500 tickets / 2 concurrency * ~500 ms per execution."

---

## ✅ Self-Check

- [ ] Batch of 500 tickets completed with `ALL SUCCEEDED`
- [ ] Batch duration was approximately 120-180 seconds
- [ ] CloudWatch Dashboard shows ConcurrentExecutions plateauing at 2
- [ ] Embed Duration p95 is clearly the dominant step (~200–400 ms)
- [ ] Scaling Map is fully completed with answers for all three steps
- [ ] You can explain why Embed is the bottleneck using metric evidence
