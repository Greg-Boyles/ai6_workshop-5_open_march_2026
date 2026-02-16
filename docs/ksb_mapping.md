# KSB Mapping — Workshop 5 (AI6)
## Orchestrating Complex ML Pipelines in Production (Scale or Fail)

This file maps **Workshop 5** to the **Machine Learning Engineer (Level 6) occupational standard (ST1398 v1.0)**.

Workshop spine:
- **Scaling is the job**
- **Orchestration is the mechanism**
- **Root Cause Analysis is the safety net**

---

## Workshop-to-Duty Alignment

**Primary duties this workshop supports**
- **Duty 4:** Monitor and support ML models through operational deployment in the live environment.
- **Duty 5:** Monitor operating resource implications; develop scalable and environmentally sustainable systems.
- **Duty 6:** Deliver responsive technical engineering support services to mitigate operational impact whilst ensuring business continuity.

---

## Primary KSB Mapping by Activity

### Scaling is the Job (Activities 1–4)

**K12 — Deployment approaches for new data pipelines and automated processes.**
- **Activities 1 & 2:** Learners deploy infrastructure via CloudFormation and verify a single execution through the Step Functions pipeline.
- Evidence: Stack deployment outputs, execution graph screenshot, step identification.

**S19 — Ensure the model capacity is scaled in proportion to the operating requirements.**
- **Activities 3 & 4:** Learners hit the capacity wall under burst load, then increase concurrent capacity and verify the impact.
- Evidence:
  - Screenshot: CloudWatch dashboard showing batch duration before/after
  - Screenshot: ConcurrentExecutions widget before/after
  - One sentence: "We scaled the bottleneck step (Embed) by increasing Map MaxConcurrency from 2 to 10, which reduced batch duration from ~15-20s to ~4-7s."

**S22 — Identify the ML/AI platform architecture and specific hardware, to contribute to solving a computational problem using allocated resources.**
- **Activity 4:** Learners justify *what* is being scaled (the model step vs pre/post) and *why*, using the orchestration map plus metrics.
- Evidence: Scaling Map worksheet, one-sentence explanation.

---

### Orchestration is the Mechanism (Activity 5)

**K12 — Deployment approaches for new data pipelines and automated processes.**
- **Activity 5:** Learners use the orchestration map (Step Functions) to explain how a request travels through steps and how boundaries make bottlenecks visible.
- Evidence: Step Functions execution graph, comparison of two executions.

**S10 — Apply techniques for monitoring models in the live environment to check they remain fit for purpose and stable.**
- **Activity 5:** Learners use live observability signals (duration, invocations, errors) to assess pipeline stability.
- Evidence: CloudWatch Logs Insights query results, dashboard widget interpretation.

---

### Root Cause Analysis is the Safety Net (Activities 6–8)

**S26 — Undertake independent, impartial decision-making respecting the opinions and views of others in complex, unpredictable and changing circumstances.**
- **Activities 6 & 7:** Teams classify incidents using an RCA tree and fishbone, select the most likely root cause, and propose one safe action with evidence.
- Evidence:
  - Completed RCA Tree (4-leaf classification)
  - Completed Fishbone (scaling-centric categories)
  - Mini incident report (what happened, evidence, classification, first action)

**B2 — Takes personal responsibility and prioritises sustainable outcomes in how they carry out the duties of their role.**
- **Activities 7 & 8:** Learners treat scaling and observability as responsibility for service continuity.
- Evidence: One-sentence reflection: "What would you check first at 03:00 and why?"

**B4 — Acts with integrity, giving due regard to legal, ethical and regulatory requirements.**
- **Activities 6 & 7:** Learners use disciplined evidence-based RCA (no guessing; state what you know vs assume).
- Evidence: Incident report explicitly separates "Evidence" from "Hypothesis".

---

## Activity-to-KSB Quick Reference

| Activity | Title | Primary KSBs |
|----------|-------|---------------|
| 1 | Environment Setup & Orientation | K12 |
| 2 | The Happy Path | K12 |
| 3 | Hit the Wall | S19 |
| 4 | Scale Up & Compare | S19, S22 |
| 5 | Understand Orchestration | K12, S10 |
| 6 | Controlled Failure: Bad Input | S26, B4 |
| 7 | Controlled Failure: Throttling + Fishbone | S26, B2, S10 |
| 8 | Evidence Portfolio & Reflection | B2, B4, S19 |

---

## Secondary (Optional) Mappings

- **K11 — How ML methods are applied to maximise the impact to the organisation.**
  Optional (going further): Framing "why scaling matters" in business terms (lost revenue, degraded customer experience, operational load).

---

## References

- **Machine learning engineer (Level 6) occupational standard, ST1398 v1.0 (Skills England)**
