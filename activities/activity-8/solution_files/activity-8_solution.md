# Activity 8: Solution — Evidence Portfolio & Reflection

---

## Task 1 — Evidence Screenshots

Your portfolio should contain at minimum these artefacts:

1. **Happy path execution graph (Activity 2):** Shows all three steps (Preprocess > Embed > Postprocess) completing successfully in sequence within the Map state.
2. **CloudWatch "wall" dashboard (Activity 3):** Shows ConcurrentExecutions capped at 2, with batch duration of ~15-20 seconds. The "wall" is visible as a flat line on the concurrency metric.
3. **CloudWatch after-fix dashboard (Activity 4):** Shows ConcurrentExecutions rising to 10, with batch duration dropping to ~4-7 seconds.
4. **FAILED execution (Activity 6):** Shows the Preprocess step in red, with a PayloadTooLarge error.
5. **Logs Insights output (Activity 5):** Shows the aggregate stats query with Embed having the highest avg_ms.
6. **RCA Tree classification (Activity 6):** BAD INPUT classification with reasoning for ruling out the other three leaves.

---

## Task 2 — Evidence Checklist

All items should be ticked. Here is what each maps to:

| Checklist Item | KSB Mapping |
|---|---|
| Point to bottleneck step with metrics | S10 — Monitoring in live environment |
| Before/after screenshots | S19 — Capacity scaling |
| Two failure type classifications | S26 — Decision-making with evidence |
| Evidence vs hypothesis separation | B4 — Integrity in technical decisions |
| Fishbone with evidence-backed cause | S26 — Decision-making with evidence |
| Reflection paragraph | B2 — Sustainable outcomes |

---

## Task 3 — Example Reflection

> "At 03:00 when paged for a slow ML pipeline, I would first open the CloudWatch dashboard to check ConcurrentExecutions and Duration p95 metrics. These two numbers tell me whether the problem is throughput (concurrency capped — THROTTLED) or per-request performance (each request slow — EXHAUSTED or TIMED OUT). I would then check Step Functions executions for any FAILED states and run a Logs Insights query to look for errors. Before making any change, I would write down what the metrics show (evidence) separately from what I think is happening (hypothesis), because at 03:00 it is easy to confuse correlation with causation. Only after classifying the incident using the RCA Tree would I take a safe, reversible action — like increasing MaxConcurrency by a small amount — and watch the metrics to confirm the fix."

---

## Task 4 — Kubernetes Mapping Answers

| This Workshop (Serverless) | Kubernetes Equivalent |
|---|---|
| Lambda concurrency | **Pod replica count** — how many instances of your container are running simultaneously. Controlled by `replicas` in a Deployment or HPA (Horizontal Pod Autoscaler). |
| Lambda memory | **Resource requests/limits** — the `resources.requests.memory` and `resources.limits.memory` fields in a Pod spec. This is vertical scaling per container. |
| Step Functions Map state | **Job with parallelism** — a Kubernetes Job with `spec.parallelism` processes multiple items concurrently, similar to how the Map state fans out work. |
| MaxConcurrency parameter | **parallelism field on a Job** or **maxReplicas on an HPA** — controls the upper bound on how many pods run simultaneously, just as MaxConcurrency caps parallel Lambda executions. |

---

## Extension — Example Second Reflection

> "Scaling and fixing a bug are different problems that need different solutions. A bug is like a broken machine on an assembly line — one specific part is wrong and needs to be repaired. Scaling is like adding more lanes to a motorway — nothing is broken, but you need more capacity to handle traffic. In Activity 6, we had a 'broken machine' — a single oversized ticket that the system could not process at any scale. The fix was validation, not more capacity. In Activity 7, everything worked correctly, but too slowly — like a single-lane motorway during rush hour. The fix was adding more lanes (increasing MaxConcurrency). Explaining this to a stakeholder: 'Bug means something is wrong. Scaling means something is too small. They need different fixes.'"

---

## Self-Check Checklist

- [ ] I have all 6 evidence screenshots saved with descriptive filenames
- [ ] I ticked all items on the evidence checklist (or went back to complete missing ones)
- [ ] My reflection is at least 3-4 sentences and mentions specific metrics (ConcurrentExecutions, Duration p95)
- [ ] My reflection explains why I would separate evidence from hypothesis
- [ ] I ran the cleanup script successfully
- [ ] (Optional) I completed the Kubernetes mapping table
- [ ] (Optional) I wrote a second reflection on explaining scaling vs bugs to stakeholders
