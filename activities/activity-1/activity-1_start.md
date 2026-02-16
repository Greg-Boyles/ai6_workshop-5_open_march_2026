# Activity 1: Environment Setup & Orientation

**Primary KSB:** K12 — Deployment approaches for new data pipelines and automated processes

🎯 **Learning Objective:** Deploy the ML pipeline infrastructure and orient yourself within the AWS console

## AWS Docs (Core Services)

See [AWS service docs and key quotes](../../docs/aws_service_docs.md).

## 📋 Expected Outputs

- CloudFormation stack deployed successfully
- State machine ARN and Dashboard name noted
- Familiarity with the Step Functions console and CloudWatch Dashboard

---

## 📝 Task 1 — Open CloudShell and Set Region

1. Open the **AWS Console** and launch **CloudShell** (icon in the top navigation bar).
2. Clone the workshop repository (if not already done) and navigate to the project root.
3. Run the region-setup script:

⌨️ **Terminal:**

```bash
./scripts/00_set_region.sh
```

4. Confirm the output shows your target region (`us-east-1`).

✅ **Checkpoint:** The script prints the configured region and `aws configure get region` returns `us-east-1`.

---

## 📝 Task 2 — Deploy the Stack

1. Run the deployment script:

⌨️ **Terminal:**

```bash
./scripts/01_deploy.sh
```

2. Wait for the deployment to complete — this takes **2–3 minutes**.
3. When finished, the script prints a set of **stack outputs**. Note these down:
   - `StateMachineArn`
   - `DashboardName`

✅ **Checkpoint:** The script exits with `Stack deploy complete` and outputs are visible.

⚠️ **Warning:** If the deploy fails with a permissions error, check that you are using the correct lab account and region.

---

## 📝 Task 3 — Find the State Machine

💻 **Console:**

1. Navigate to **Step Functions** in the AWS Console.
2. Click **State machines** in the left sidebar.
3. Find the state machine named `AI6-Unit5W-ScaleOrFail-state-machine` (or use the `StateMachineArn` output from the deploy script).
4. Click into it — you should see an empty **Executions** list (no runs yet).

✅ **Checkpoint:** The state machine `AI6-Unit5W-ScaleOrFail-state-machine` is visible and accessible.

---

## 📝 Task 4 — Find the CloudWatch Dashboard

💻 **Console:**

1. Navigate to **CloudWatch** in the AWS Console.
2. Click **Dashboards** in the left sidebar.
3. Open the dashboard matching the `DashboardName` from the stack outputs.
4. Observe the widgets — all metrics will be **empty** at this stage (no executions have run yet).

✅ **Checkpoint:** The dashboard loads without errors. Metrics are present but show no data.

---

## 📝 Task 5 — Record Stack Outputs

Write down or screenshot the following stack outputs for use in later activities:

| Output Key         | Your Value |
|--------------------|------------|
| `StateMachineArn`  |            |
| `DashboardName`    |            |

💡 **Tip:** You can retrieve stack outputs again at any time by running:

⌨️ **Terminal:**

```bash
aws cloudformation describe-stacks \
  --stack-name AI6-Unit5W-ScaleOrFail \
  --query "Stacks[0].Outputs"
```

---

## 🚀 Extension

Open the **CloudFormation** console, find the `AI6-Unit5W-ScaleOrFail` stack, and browse the **Resources** tab. See how many resources were created and what types they are (Lambda functions, IAM roles, Step Functions state machine, CloudWatch dashboard, etc.).

---

🎓 **Complete** — proceed to [Activity 2](../activity-2/activity-2_start.md)
