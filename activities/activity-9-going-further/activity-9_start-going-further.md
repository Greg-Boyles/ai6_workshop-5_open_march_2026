# Activity 9 (Going Further, Optional): Replace Embed With a SageMaker Endpoint (Isolated)

**Primary KSB:** S19 — Ensure the model capacity is scaled in proportion to the operating requirements

🎯 **Learning Objective:** See what changes when the “model step” runs on a managed model endpoint (SageMaker) instead of Lambda, while keeping the core workshop stack unchanged.

## Prerequisite: Start an AWS AI Sandbox

This activity requires SageMaker permissions and runs in a **separate sandbox** from the main workshop. Start an **AWS AI Sandbox** in Pluralsight:

`https://app.pluralsight.com/hands-on/playground/ai-sandboxes`

Because this is a fresh environment, you will need to repeat the environment setup before running Task 1. Follow **Steps 1–4** of the [setup guide](../../../docs/setup_guide.md) (start sandbox, open CloudShell, upload and unzip the workshop files, set your region). You do **not** need to run `./scripts/01_deploy.sh` — Task 1 below uses its own deploy script instead.

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

💡 **Tip:** If you see `Permission denied`, the script is not yet executable. You've solved this before — check the troubleshooting section of the [setup guide](../../../docs/setup_guide.md) for the pattern, and adapt the path to match this script's location.

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

In Activities 3 and 7, the throttle was at the **orchestrator level** — the Step Functions Map state. Now Embed calls a SageMaker endpoint, which has its own concurrency cap. Before running the commands below, read the AWS docs on what happens when that cap is exceeded:

> [AWS SageMaker Serverless Inference — endpoint concurrency](https://docs.aws.amazon.com/sagemaker/latest/dg/serverless-endpoints.html)

💻 **Console:**

1. Open the Step Functions execution graph for your variant state machine.
2. Open the CloudWatch dashboard output for the variant stack.
3. Compare:
   - Previously: Embed was `AWS/Lambda` Duration and concurrency
   - Now: Embed is `AWS/SageMaker` endpoint metrics (for example, `ModelLatency`, `Invocations`)

⌨️ **Optional terminal (make the throttle visible):**

```bash
# This should usually succeed (matches the endpoint MaxConcurrency=2).
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
- How does a throttled SageMaker endpoint behave differently from the throttling in Activities 3 and 7 — and which Fishbone bone does each map to?

<details>
<summary><strong>Hint: what you should observe</strong></summary>

- When `MAX_CONCURRENCY=4` exceeds the endpoint cap, look at how the Step Functions execution status differs from what you saw in Activities 3 and 7 when the Map state was the bottleneck.
- Pay attention to whether executions **slow down** or **fail outright**.

</details>

<details>
<summary><strong>Example answer (optional)</strong></summary>

- **What changed:** “Embed is now a network call to a managed endpoint rather than an in-process Lambda call. The latency source is now `ModelLatency` on the SageMaker side, and a new failure mode appears if the endpoint's concurrency cap is exceeded.”
- **Scaling knobs:** “The endpoint's `MaxConcurrency` controls how many simultaneous invocations it accepts. Raising it increases throughput; exceeding it causes throttling errors.”
- **Contrast with Activities 3 & 7:** “In Activities 3 and 7, exceeding `max_concurrency` on the Map state caused work to **queue silently** — everything still succeeded, just more slowly (**Bone 1: Limits/Throttling** within our own infrastructure). Here, exceeding the SageMaker endpoint's `MaxConcurrency` causes invocations to be **rejected** — executions fail rather than wait (**Bone 3: Dependencies** — a cap imposed by an external service). The fix is the same idea at a different layer: raise the relevant `MaxConcurrency` parameter.”

</details>

---

## 📝 Task 4 — Clean Up (Variant Only)

⌨️ **Terminal:**

```bash
WORKSHOP_NAME=AI6-Unit5W-ScaleOrFail-gf-sagemaker \
./activities/activity-9-going-further/aws/sagemaker-embed/scripts/cleanup.sh
```

✅ **Checkpoint:** Stack delete completes.

---

## 🚀 Extension — Map the Workshop to Your Cloud of Choice

A senior engineer recognises the *kind* of resource, not just its AWS name. If you were asked to build this same pipeline on Azure or GCP tomorrow, would you know where to start?

Cloud platforms don't always carve up functionality the same way. What AWS packages as one service might be split across two on Azure, or combined differently on GCP. The mapping won't always be 1:1 — and noticing *where* it isn't is part of the exercise.

Using the [AWS, Azure, and GCP service comparison](https://docs.cloud.google.com/docs/get-started/aws-azure-gcp-service-comparison) linked in the README, look up each service used in this workshop and fill in the equivalents for your chosen cloud yourself:

| Workshop Resource | What it does | Your cloud equivalent |
|---|---|---|
| AWS Lambda | | |
| Step Functions (Map state) | | |
| CloudWatch Logs | | |
| CloudWatch Logs Insights | | |
| CloudWatch Dashboard | | |
| CloudFormation | | |
| SageMaker endpoint *(if you did Activity 9)* | | |

Then, using [draw.io](https://app.diagrams.net) (free, browser-based, no account needed):

1. Pick Azure or GCP
2. Draw the three-step pipeline (Preprocess → Embed → Postprocess) using that cloud's service icons — draw.io has built-in icon sets for both
3. Add the orchestration layer and the observability layer
4. Export as PNG and save it alongside your Activity 8 portfolio screenshots

✅ **Checkpoint:** Your diagram shows the same logical architecture as the workshop, using a different cloud's services and naming.
