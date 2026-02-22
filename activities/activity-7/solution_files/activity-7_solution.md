# Activity 7: Solution — Controlled Failure — Throttling (RCA Incident 2 + Fishbone)

---

## Task 3 — RCA Tree Classification

**Classification: THROTTLED (leaf 1)**

The pipeline is slow because MaxConcurrency is set to 2, meaning only 2 tickets are processed in parallel at a time. With 500 tickets queued, the batch takes a long time to complete — not because each ticket is slow, but because the throughput is capped.

---

## Task 4 — Fishbone Diagnostic

### Fishbone Diagnostic: "Why didn't it scale?"

**Effect (head of the fish):** Pipeline slow during traffic spike

**Completed fishbone:**

1. **Which bone does your evidence point to?** Bone 1 — Limits / Throttling
2. **What specific metric or log proves it?** CloudWatch ConcurrentExecutions metric shows a flat line at 2. The Step Functions Map state has MaxConcurrency=2. 500 items are queued but only 2 process at a time, creating a serial bottleneck.
3. **What is one safe, reversible action to restore service?** Increase MaxConcurrency from 2 to 10. This is safe because it can be reverted immediately, and 10 is within the Lambda account concurrency limit for this environment.

**Why not the other bones?**

| Bone | Why ruled out? |
|---|---|
| Resources | Per-request duration is normal (~250ms for embed). No OutOfMemory errors. The function is not resource-constrained. |
| Dependencies | No timeout errors or growing duration. Each individual request completes normally. |
| Data / Input | No validation errors. All 500 tickets process successfully — they just process slowly in aggregate. |

---

## Task 6 — Before/After Comparison

| Metric | Before (MAX_CONCURRENCY=2) | After (MAX_CONCURRENCY=10) |
|---|---|---|
| Batch duration | ~120-180 seconds | ~35-50 seconds |
| ConcurrentExecutions | 2 | up to 10 |
| Items processed | 500 | 500 |
| Per-item p95 duration | ~200-300ms | ~200-300ms |

Key observation: Per-item duration did not change. The improvement came entirely from processing more items in parallel. This confirms the bottleneck was throughput (parallelism), not per-request performance.

---

## Task 7 — Model Incident Report

- **What happened:** A batch of 500 support tickets was submitted to the ML pipeline. The batch took approximately 120-180 seconds to complete, well above the expected ~35-50 seconds. No individual ticket failed, but overall throughput was unacceptably slow.
- **Evidence:** CloudWatch ConcurrentExecutions metric capped at 2. Step Functions Map state shows MaxConcurrency=2. Per-request embed duration p95 is ~300ms (normal). Batch duration is ~120 seconds for 500 items.
- **Hypothesis:** The slow batch duration is caused by the MaxConcurrency parameter being set too low (2), forcing the Map state to process tickets almost serially. This is a configuration bottleneck, not a code or infrastructure issue.
- **Classification:** THROTTLED (RCA Tree leaf 1) — throughput capped by low parallelism setting.
- **Fishbone bone:** Limits / Throttling — the concurrency cap is an intentional safety limit set too conservatively for the current workload.
- **Fix applied:** Increased MaxConcurrency from 2 to 10 by re-running the burst script with `MAX_CONCURRENCY=10`.
- **Result after fix:** Batch duration dropped from ~120 seconds to ~40 seconds. ConcurrentExecutions rose from 2 to 10. Per-item duration remained unchanged, confirming the fix addressed the correct bottleneck.

---

## Extension — Next Bottleneck at MAX_CONCURRENCY=500

If you set MAX_CONCURRENCY to 500, the next bottleneck would likely be:

1. **Cold starts:** Spinning up 500 Lambda execution environments simultaneously causes a burst of cold starts. Each cold start adds 500ms-2s of initialization time, temporarily increasing p95 duration.
2. **Account-level concurrency:** AWS Lambda has a default account-wide concurrency limit of 1000 unreserved. If other functions are running, you could approach this limit.
3. **Downstream throttling:** If the embed model API has its own rate limit, 500 simultaneous requests might trigger throttling from the model provider.

The correct approach is to increase concurrency incrementally (2 > 10 > 20) while monitoring these metrics, rather than jumping straight to the maximum.

---

## Self-Check Checklist

- [ ] I correctly classified this as THROTTLED, not EXHAUSTED or TIMED OUT
- [ ] I completed the Fishbone with at least one evidence-backed cause (ConcurrentExecutions=2)
- [ ] I can explain why per-item duration stayed the same while batch duration improved
- [ ] My incident report separates Evidence (metrics) from Hypothesis (interpretation)
- [ ] I documented the before/after comparison with specific numbers
- [ ] I understand that increasing concurrency is a safe, reversible action
