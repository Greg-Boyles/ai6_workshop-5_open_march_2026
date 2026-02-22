# Workshop 5: Orchestrating Complex ML Pipelines in Production

## Cloud Service Docs (Core Services)

See [AWS service docs and key quotes](docs/aws_service_docs.md).

As you grow into the role of an ML Engineer, becoming comfortable with seeking out and reading official documentation is an essential professional skill — not just for AWS, but for whichever cloud platform you work on.

Official cloud provider documentation is actively maintained, updated to reflect new features and service changes, and reviewed by the teams who build those services. Relying on outdated or third-party sources can lead to misunderstandings, because unofficial materials often lag behind current service behaviour.

Whether you primarily work with AWS or GCP, the core patterns you practise here — deploying managed services, observing them with monitoring tools, and tuning orchestration — transfer directly. The specific service names and console layouts differ, but the thinking is the same.

By developing the habit of navigating and interpreting authoritative documentation, you strengthen your ability to troubleshoot effectively, make informed design decisions, and stay aligned with industry best practices.

> **Going further:** If you want to understand how the AWS services used in this workshop map onto their GCP counterparts, the [AWS, Azure, and GCP service comparison](https://docs.cloud.google.com/docs/get-started/aws-azure-gcp-service-comparison) is a useful reference. Search for each service (Lambda, Step Functions, CloudWatch, CloudFormation) and find its equivalent — you may find there is more than one, which itself tells you something about how the platforms differ in their design philosophy. Reading the equivalent service's documentation is a good way to deepen your understanding of both platforms.

## Scale or Fail

A hands-on workshop where you deploy, stress-test, and troubleshoot a serverless ML pipeline on AWS. You will hit a real scaling wall, diagnose it with evidence, fix it, and prove the fix worked.

- **Duration:** 5 working hours (plus one hour for lunch)
- **Platform:** AWS (Lambda, Step Functions, CloudWatch, CloudFormation)
- **Sandbox:** Pluralsight AWS Cloud Sandbox

---

## Scaling Knob Used In This Workshop

In simple terms, a "scaling knob" is a single setting you can turn up or down to make part of the system do more (or less) work at the same time.

For this workshop we use the Step Functions `Map` state's `max_concurrency` as the main scaling knob. It's an orchestration-level control that determines how many items inside a Map state run in parallel.

> **Step Functions** is a service that helps different parts of your workflow run in the right order, like a flowchart that coordinates each step.

Why this knob?
- It's easy to change and observe during hands-on exercises.
- It works well inside sandbox environments where account-level limits (like Lambda reserved concurrency) may be restricted.
- It demonstrates the common pattern: increase parallelism at the orchestrator, measure the result, then fix any new bottlenecks that appear.

What `max_concurrency` does:
- If `max_concurrency` is 5, at most five Map iterations run at the same time. New items wait until one finishes.
- Increasing it lets more tasks run at once (faster throughput), but can reveal downstream bottlenecks (databases, external APIs) or increase cost.

Useful links:
- [Step Functions Map state / concurrency](https://docs.aws.amazon.com/step-functions/latest/dg/state-map.html)
- [Lambda concurrency controls](https://docs.aws.amazon.com/lambda/latest/dg/configuration-concurrency.html)
- [Pluralsight AWS sandbox limits](https://help.pluralsight.com/hc/en-us/articles/24425443133076-AWS-cloud-sandbox)

---

## Where This Fits in the ML Lifecycle

The earlier AI6 workshops focused on the upstream phases of [CRISP-ML(Q)](https://ml-ops.org/content/crisp-ml): business and data understanding, data engineering, model training, and model evaluation. This workshop picks up at the end of that journey.

Once a model passes evaluation, it enters the **Deployment** phase — integration into a live software system — and then the **Monitoring and Maintenance** phase, where you continuously observe its behaviour in production, detect degradation, and respond to incidents. This workshop gives you hands-on practice with both: you deploy the pipeline, stress-test it, observe it with metrics and logs, and apply structured Root Cause Analysis when things go wrong.

This maps directly to [**Duty 6** of the Machine Learning Engineer apprenticeship standard](https://skillsengland.education.gov.uk/apprenticeships/st1398-v1-0?view=standard): *"Deliver responsive technical engineering support services; to mitigate operational impact whilst ensuring business continuity."*

The "model step" in this workshop is intentionally simulated so you can focus on the operational patterns rather than model training. If you want to see what those same patterns look like with a real managed inference endpoint, [Activity 9 (Going Further)](activities/activity-9-going-further/activity-9_start-going-further.md) makes that connection concrete.

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

**Scaling is the job.**

**Orchestration is the mechanism.**

**Root Cause Analysis is the safety net.**

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

Read the [User Brief](user_brief.md) first to understand the scenario. You may also wish to look ahead to [Activity 8](activities/activity-8/activity-8_start.md) before starting Task 1 because it requires you to gather screenshots from previous activities. There's no harm in repeating previous activities (and, in fact, some benefit), but you may wish to proceed with your eyes open!

### Scaling is the Job

| Activity | Title | Focus |
|----------|-------|-------|
| [Activity 1](activities/activity-1/activity-1_start.md) | Environment Setup & Orientation | Deploy the stack, navigate the console |
| [Activity 2](activities/activity-2/activity-2_start.md) | The Happy Path | Run a single ticket, identify pipeline steps |
| [Activity 3](activities/activity-3/activity-3_start.md) | Hit the Wall | Burst load at low concurrency, find the bottleneck |
| [Activity 4](activities/activity-4/activity-4_start.md) | Scale Up & Compare | Increase parallelism, measure the improvement |

### RCA is the Safety Net

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

You will have met these prerequisites by engaging with previous workshops.

- AWS Cloud Sandbox access (Pluralsight)
- Familiarity with the AWS Console (basic navigation)
- Comfort with running shell commands in a terminal

See the [Setup Guide](docs/setup_guide.md) for environment preparation.

---

## From Commands to Scripts

In the previous workshop you deployed Azure infrastructure by copying individual
`az` CLI commands into the terminal one at a time. That works, but this workshop
takes the next step: the AWS CLI commands are bundled into shell scripts in the
[`scripts/`](scripts/) folder.

Instead of pasting a sequence of commands manually, you run a single script and
it handles the sequence for you — setting variables, running the AWS CLI calls in
the right order, and printing output so you can see what happened.

This pattern is a core technique in engineering teams, though not the only one — in the previous workshop you used Bicep for this on Azure, and in this workshop CloudFormation plays the same role. Tools like these handle the infrastructure declaration, while scripts handle the invocation. Deployment steps, pipeline invocations, and teardown procedures live in scripts because they are:

- **Repeatable** — the same script run by any engineer produces the same result
- **Auditable** — the script is the documentation as well as the automation
- **Extensible** — a script is the seed of a CI/CD pipeline or runbook

You will not need to write scripts in this workshop, but you are encouraged to
open them and read them. The commands inside are real AWS CLI calls, and
understanding what they do (not just that they work) is part of the job.

**Looking up a command in the AWS CLI reference**

The [AWS CLI reference](https://docs.aws.amazon.com/cli/latest/reference/) is
structured by service. To look up any command, navigate to the service name and
then the subcommand.

For example, the first script, [`scripts/01_deploy.sh`](scripts/01_deploy.sh),
runs:

```bash
aws cloudformation deploy \
  --stack-name "$STACK_NAME" \
  --template-file "$TEMPLATE_FILE" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides ...
```

In the reference, this lives under [cloudformation → deploy](https://docs.aws.amazon.com/cli/latest/reference/cloudformation/deploy.html). There you can see that `--capabilities
CAPABILITY_NAMED_IAM` is an explicit acknowledgement that the template creates
IAM resources with custom names — AWS requires you to opt in to this rather than
letting it happen silently. Knowing that turns a flag you might have ignored into
a safety design decision you can reason about.

---

## Key Resources

- [Glossary](docs/glossary.md) — key terminology
- [Architecture Diagrams](diagrams/ascii_diagrams.md) — pipeline and orchestration visuals
- [Fishbone Printable](docs/fishbone_printable.pdf) — for team RCA exercises
- [KSB Mapping](docs/ksb_mapping.md) — how activities map to the standard (optional)
