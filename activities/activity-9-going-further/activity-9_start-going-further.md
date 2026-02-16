# Activity 9 (Going Further, Optional): Replace Embed With a SageMaker Endpoint (Isolated)

**Primary KSB:** S19 — Ensure the model capacity is scaled in proportion to the operating requirements

🎯 **Learning Objective:** See what changes when the “model step” runs on a managed model endpoint (SageMaker) instead of Lambda, while keeping the core workshop stack unchanged.

## Prerequisite: Start an AWS AI Sandbox

This activity requires SageMaker permissions. Start an **AWS AI Sandbox** in Pluralsight:

`https://app.pluralsight.com/hands-on/playground/ai-sandboxes`

## Context: “Workshop Pipeline” vs “ML Pipeline”

So far in the AI6 workshops, we’ve mostly been thinking about the **end-to-end ML lifecycle** (often described by CRISP-ML(Q)): getting to a good model and getting it deployed responsibly.

This workshop’s “pipeline” is different:
- **Workshop pipeline (application workflow):** ingest ticket → preprocess → embed → route/score
- **ML pipeline (CRISP-ML(Q) / MLOps):** data/feature prep → train → evaluate → register → deploy → monitor

In the core workshop, the “model step” is implemented as **simple rules/code inside Lambda** (a stand-in for a real model) so we can focus on scaling and observability.

In this Going Further activity, we keep the *same application workflow*, but swap that stand-in for a **managed inference endpoint** (SageMaker). We’re focusing on what changes operationally when “embed” is a managed service (new scaling knobs, new throttling surface area, and new latency/metrics to watch).

## AWS Docs (Core Services)

See [AWS service docs and key quotes](../../docs/aws_service_docs.md).

---

## What This Adds (And What It Does Not)

This is an **isolated** exercise:
- It deploys a separate CloudFormation stack using `activities/activity-9-going-further/aws/sagemaker-embed/cloudformation/template.yaml`.
- It creates a **SageMaker serverless endpoint** and updates the Step Functions workflow to call it for the Embed step.
- It uploads a tiny inference script bundle to **S3** for SageMaker to run (script mode).
- All infrastructure/scripts for this activity live under `activities/activity-9-going-further/aws/sagemaker-embed/`.

It does **not** change:
- The core workshop template: `infra/ai6_u5w_scale_or_fail.yaml`
- The core workshop scripts/activities

⚠️ **Cost note:** SageMaker endpoints can incur cost. This variant uses a **serverless endpoint** and keeps concurrency intentionally low.

---

## 📋 Expected Outputs

- A second workshop stack deployed with a distinct stack name
- A successful Step Functions execution where Embed is served by SageMaker
- Evidence you can point to:
  - Step Functions execution graph still shows the 3 logical steps
  - CloudWatch dashboard now includes SageMaker endpoint metrics for the Embed step (ModelLatency, Invocations)

---

## 📝 Task 1 — Deploy the Isolated “SageMaker Embed” Stack

⌨️ **Terminal:**

```bash
# Keep the variant isolated by giving it its own name.
WORKSHOP_NAME=AI6-Unit5W-ScaleOrFail-gf-sagemaker \
SAGEMAKER_MAX_CONCURRENCY=2 \
./activities/activity-9-going-further/aws/sagemaker-embed/scripts/deploy.sh
```

✅ **Checkpoint:** The deploy finishes and prints stack outputs.

---

## 📝 Task 2 — Run a Happy Path Execution

Use the normal invocation script, but point it at the *variant* stack:

⌨️ **Terminal:**

```bash
WORKSHOP_NAME=AI6-Unit5W-ScaleOrFail-gf-sagemaker \
./scripts/02_invoke_one.sh
```

✅ **Checkpoint:** Execution is `SUCCEEDED`.

---

## 📝 Task 3 — Observe the “New Bottleneck Surface Area”

💻 **Console:**

1. Open the Step Functions execution graph for your variant state machine.
2. Open the CloudWatch dashboard output for the variant stack.
3. Compare:
   - Previously: Embed was `AWS/Lambda` Duration and concurrency
   - Now: Embed is `AWS/SageMaker` endpoint metrics (for example, ModelLatency)

⌨️ **Optional terminal (make the bottleneck visible):**

```bash
# This should usually succeed (matches the endpoint serverless MaxConcurrency=2).
WORKSHOP_NAME=AI6-Unit5W-ScaleOrFail-gf-sagemaker \
N=10 MAX_CONCURRENCY=2 \
./scripts/03_burst_load.sh

# This should fail with SageMaker throttling (exceeds the endpoint MaxConcurrency=2).
WORKSHOP_NAME=AI6-Unit5W-ScaleOrFail-gf-sagemaker \
N=10 MAX_CONCURRENCY=4 \
./scripts/03_burst_load.sh
```

Write 2–3 sentences:
- What changed operationally when moving “model inference” onto SageMaker?
- What scaling knob(s) now exist at the endpoint layer?

---

## 📝 Task 4 — Clean Up (Variant Only)

⌨️ **Terminal:**

```bash
WORKSHOP_NAME=AI6-Unit5W-ScaleOrFail-gf-sagemaker \
./activities/activity-9-going-further/aws/sagemaker-embed/scripts/cleanup.sh
```

✅ **Checkpoint:** Stack delete completes.
