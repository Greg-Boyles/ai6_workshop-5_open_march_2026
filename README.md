# Workshop 5: Orchestrating Complex ML Pipelines in Production

## AWS Docs (Core Services)

See [AWS service docs and key quotes](docs/aws_service_docs.md).

As you grow into the role of an ML Engineer, becoming comfortable with seeking out and reading high‑quality documentation isn't just a useful habit, it's an essential professional skill.

AWS's official documentation is actively maintained, continuously updated to reflect new features and service changes, and rigorously reviewed by AWS experts, making it the most reliable place to understand how cloud and AI tooling really works in practice. Relying on outdated or third‑party sources can lead to misunderstandings, because archived or unofficial materials often lag behind current service behaviour and may no longer be accurate as AWS evolves. 

By developing the confidence to navigate and interpret authoritative documentation, you strengthen your ability to troubleshoot effectively, make informed design decisions, and stay aligned with industry best practices; key capabilities for any ML Engineer building robust, production‑ready solutions.

## Scale or Fail

A hands-on workshop where you deploy, stress-test, and troubleshoot a serverless ML pipeline on AWS. You will hit a real scaling wall, diagnose it with evidence, fix it, and prove the fix worked.

**Duration:** 5 hours (with lunch)
**Platform:** AWS (Lambda, Step Functions, CloudWatch, CloudFormation)
**Sandbox:** Pluralsight / A Cloud Guru AWS Cloud Sandbox

---

## Scaling Knob Used In This Workshop

This workshop intentionally uses **Step Functions Map `max_concurrency`** as the primary scaling knob.

AWS supports other concurrency controls too (for example **Lambda reserved concurrency**), but some sandbox environments may restrict certain controls.

- Step Functions Map state / concurrency: `https://docs.aws.amazon.com/step-functions/latest/dg/state-map.html`
- Lambda concurrency controls: `https://docs.aws.amazon.com/lambda/latest/dg/configuration-concurrency.html`
- Pluralsight AWS sandbox limits: `https://help.pluralsight.com/hc/en-us/articles/24425443133076-AWS-cloud-sandbox`

---

## Learning Objectives

By the end of this workshop you will be able to:

1. Deploy an ML inference pipeline using Infrastructure as Code (CloudFormation)
2. Identify the bottleneck step in a multi-stage pipeline under burst load
3. Scale the bottleneck using orchestration parallelism and measure the improvement
4. Use CloudWatch metrics and Logs Insights to observe system behaviour under load
5. Classify production incidents using structured RCA (Root Cause Analysis)
6. Apply the Fishbone diagnostic method to separate evidence from hypothesis
7. Compile an evidence portfolio demonstrating scaling, monitoring, and decision-making skills

---

## The Workshop Spine

> **Scaling is the job.**
> **Orchestration is the mechanism.**
> **Root Cause Analysis is the safety net.**

---

## Emoji Guide

| Emoji | Meaning |
|-------|---------|
| 🎯 | **Learning Objective** — what you will achieve |
| 📋 | **Expected Outputs** — end result to aim for |
| 📝 | **Task/Step** — something to do |
| ⌨️ | **Terminal** — shell command to run |
| 💻 | **Console** — AWS Console action to take |
| ✅ | **Checkpoint** — verify your progress |
| 🤔 | **Reflect** — think deeply about this |
| 💡 | **Tip/Hint** — helpful suggestion |
| ⚠️ | **Warning** — do not miss this |
| 📘 | **Explanation** — background theory |
| 🚀 | **Extension** — optional stretch challenge |
| 🎓 | **Complete** — activity finished |

---

## Workshop Structure

Read the [User Brief](user_brief.md) first to understand the scenario.

### Morning — Scaling is the Job

| Activity | Title | Focus |
|----------|-------|-------|
| [Activity 1](activities/activity-1/activity-1_start.md) | Environment Setup & Orientation | Deploy the stack, navigate the console |
| [Activity 2](activities/activity-2/activity-2_start.md) | The Happy Path | Run a single ticket, identify pipeline steps |
| [Activity 3](activities/activity-3/activity-3_start.md) | Hit the Wall | Burst load at low concurrency, find the bottleneck |
| [Activity 4](activities/activity-4/activity-4_start.md) | Scale Up & Compare | Increase parallelism, measure the improvement |

### Afternoon — RCA is the Safety Net

| Activity | Title | Focus |
|----------|-------|-------|
| [Activity 5](activities/activity-5/activity-5_start.md) | Understand Orchestration | Read the logs, query with Logs Insights |
| [Activity 6](activities/activity-6/activity-6_start.md) | Controlled Failure: Bad Input | Trigger a data error, classify with RCA Tree |
| [Activity 7](activities/activity-7/activity-7_start.md) | Controlled Failure: Throttling | Fishbone analysis, apply fix, verify |
| [Activity 8](activities/activity-8/activity-8_start.md) | Evidence Portfolio & Reflection | Compile evidence, reflect, clean up |

### Optional — Going Further

| Activity | Title | Focus |
|----------|-------|-------|
| [Activity 9](activities/activity-9-going-further/activity-9_start-going-further.md) | Replace Embed With SageMaker Endpoint (Isolated) | Managed inference bottlenecks + throttling surface area |

---

## Prerequisites

- AWS Cloud Sandbox access (Pluralsight / A Cloud Guru)
- Familiarity with the AWS Console (basic navigation)
- Comfort with running shell commands in a terminal

See the [Setup Guide](docs/setup_guide.md) for environment preparation.

---

## Key Resources

- [Glossary](docs/glossary.md) — key terminology
- [Architecture Diagrams](diagrams/ascii_diagrams.md) — pipeline and orchestration visuals
- [Fishbone Printable](docs/fishbone_printable.pdf) — for team RCA exercises
- [KSB Mapping](docs/ksb_mapping.md) — how activities map to the standard (optional)
