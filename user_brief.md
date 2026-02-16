# User Brief: Flash Sale Friday

## Project Title

**Scale or Fail** — Keeping the ML Pipeline Alive Under a 10x Traffic Spike

---

## Background

You are an ML engineer at a subscription business that runs a customer support ticket triage pipeline. The pipeline uses a three-step serverless architecture on AWS:

1. **Preprocess** — validates and cleans incoming ticket text
2. **Embed (Model)** — generates a semantic embedding using a MiniLM-style model to classify the ticket
3. **Postprocess** — applies business rules to assign priority and routing

On a normal day, the pipeline handles a steady trickle of tickets with no issues. But today is **Flash Sale Friday**. Marketing has launched a promotion, and support ticket volume is about to spike **10x** for approximately 30 minutes.

Your team deployed this pipeline months ago. It works. But nobody has ever tested it under burst load.

---

## The Problem

When the traffic spike hits:

- The pipeline slows to a crawl
- Customers wait longer for support responses
- The operations team starts getting alerts
- Nobody knows *which part* of the pipeline is the bottleneck

Your job today is to **find the bottleneck, fix it, and prove the fix worked** — using evidence, not guesswork.

---

## Your Mission

Across 8 activities, you will:

1. **Deploy** the pipeline infrastructure using CloudFormation
2. **Verify** it works with a single ticket (the happy path)
3. **Stress-test** it with a burst of 40 tickets at low parallelism
4. **Scale** the bottleneck and measure the improvement
5. **Investigate** the orchestration layer and logs
6. **Diagnose** a data validation failure using structured RCA
7. **Diagnose** a throughput bottleneck using the Fishbone method
8. **Document** your evidence for your portfolio

---

## Deliverables

By the end of the workshop, you should have:

- Screenshots of your CloudWatch dashboard (before and after scaling)
- Screenshots of Step Functions execution graphs (success and failure)
- A completed Scaling Map identifying the bottleneck
- A completed RCA Tree classification for two incidents
- A completed Fishbone diagram for the throughput incident
- A mini incident report separating evidence from hypothesis
- A reflection paragraph: "What would you check first at 03:00 and why?"

---

## Success Criteria

You have succeeded when you can:

1. Point to the **specific step** that is the bottleneck and explain **why** with metrics
2. Show a **before/after comparison** proving your fix reduced batch duration
3. **Classify two different failure types** (bad input vs throttling) using evidence
4. Separate what you **know** (evidence) from what you **think** (hypothesis)

---

## Constraints

- **Sandbox:** AWS Cloud Sandbox via Pluralsight (us-east-1 region)
- **Time:** ~4 hours of active sandbox time
- **Services:** Lambda, Step Functions, CloudWatch, CloudFormation only
- **No code changes required** — you scale through configuration and orchestration parameters

---

## The Three Mantras

Keep these in mind throughout:

> **Scaling is the job** — you scale the bottleneck, not the whole pipeline.
>
> **Orchestration is the mechanism** — Step Functions controls how work flows and how much runs in parallel.
>
> **Root Cause Analysis is the safety net** — when things break, classify with evidence, not guesses.
