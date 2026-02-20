# Activity 8: Evidence Portfolio & Reflection

**Primary KSB:** B2 — Sustainable outcomes; B4 — Integrity; S19 — Capacity scaling

🎯 **Learning Objective:** Compile portfolio evidence and reflect on transferable concepts

## AWS Docs (Core Services)

See [AWS service docs and key quotes](../../docs/aws_service_docs.md).

---

## 📋 Expected Outputs

- Completed evidence checklist with screenshots
- A written reflection paragraph answering the 03:00 pager scenario
- (Optional) Kubernetes mapping table
- Sandbox cleaned up

---

## 📝 Task 1 — Collect Your Evidence Screenshots

Gather screenshots from across the workshop. You may want to repeat activities in order to get a good screenshot. (This will help embed your learning; you'll find it easier the second time!) Tick each item as you save it:

- [ ] Step Functions execution graph — happy path (Activity 2)
- [ ] CloudWatch dashboard showing the "wall" — low concurrency (Activity 3)
- [ ] CloudWatch dashboard after the fix — high concurrency (Activity 4)
- [ ] Step Functions execution showing FAILED status — bad input (Activity 6)
- [ ] CloudWatch Logs Insights query output (Activity 5)
- [ ] Completed RCA Tree classification (Activity 6)

💡 **Tip:** Save screenshots with descriptive filenames, e.g. `act3_cloudwatch_low_concurrency.png`. These are your evidence artefacts for the portfolio.

---

## 📝 Task 2 — Complete the Evidence Checklist

Review each statement. You should be able to answer "yes" to all of them:

- [ ] I can point to the specific bottleneck step and explain why with metrics
- [ ] I have before/after screenshots proving my fix reduced batch duration
- [ ] I classified two different failure types (bad input vs throughput) using evidence
- [ ] I separated evidence from hypothesis in my incident report
- [ ] I completed a fishbone diagram with at least one evidence-backed cause
- [ ] I wrote a reflection paragraph (see Task 3)

⚠️ **Warning:** If you cannot tick an item, go back to the relevant activity and complete it before moving on. Each item maps to a specific KSB.

---

## 📝 Task 3 — Write Your Reflection

Write one paragraph answering this scenario:

> **"It's 03:00 and your team gets paged. The ML pipeline is slow and customers are waiting. What would you check first, and why?"**

Your reflection should reference:
- Which metrics or logs you would check first
- How you would classify the incident (using the RCA Tree or Fishbone)
- Why you would separate evidence from hypothesis before taking action

✅ **Checkpoint:** Your reflection is at least 3-4 sentences and references specific tools or metrics from the workshop.

---

## 📝 Task 4 — Kubernetes Mapping (Optional)

If you have experience with or interest in Kubernetes, complete this mapping table. These concepts transfer directly:

| This Workshop (Serverless) | Kubernetes Equivalent |
|---|---|
| Lambda concurrency | ___ |
| Lambda memory | ___ |
| Step Functions Map state | ___ |
| MaxConcurrency parameter | ___ |

---

## 📝 Task 5 — Clean Up Your Sandbox

Run the cleanup script to tear down all workshop resources:

⌨️ **Terminal:**

```bash
./scripts/99_cleanup.sh
```

✅ **Checkpoint:** The script completes without errors. Your sandbox is clean.

⚠️ **Warning:** Make sure you have saved all your screenshots and notes before running cleanup. The CloudWatch logs and Step Functions executions will be deleted.

---

🚀 **Extension:** Write a second reflection paragraph:

> **"How would you explain the difference between scaling and fixing a bug to a non-technical stakeholder?"**

Think about: what analogy would make the distinction clear? How would you explain that Activity 6 (bad input) needed a different fix than Activity 7 (throttling)?

<details>
<summary><strong>Hint: what you should observe</strong></summary>

- Strong reflections reference *specific* signals from the workshop (for example: ConcurrentExecutions, duration p95, Step Functions execution graph, Logs Insights queries).
- A good first step at 03:00 is usually: check the dashboard for saturation/throttling, then check Step Functions for failure patterns, then pull logs for the failing step.

</details>

<details>
<summary><strong>Example answer (optional)</strong></summary>

> "At 03:00 I’d start with the CloudWatch dashboard to see if we’re saturated (for example, ConcurrentExecutions plateauing or throttles/errors). If it looks like a throughput issue, I’d check the Step Functions execution graph to confirm which step is slow or failing and whether failures are clustered in one state. Then I’d use Logs Insights to pull recent errors and compare step durations so I can separate evidence from hypothesis before changing concurrency or timeouts."

</details>

---

🎓 **Complete** — You have finished Workshop 5: Scale or Fail. Well done.
