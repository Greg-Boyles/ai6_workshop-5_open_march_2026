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

## 📝 Task 0 — Ensure you're setup

If you haven't done so already, follow the [setup guide](../../docs/setup_guide.md).

---

## 📝 Task 1 — Find the State Machine

💻 **Console:**

1. Navigate to **Step Functions** in the AWS Console.
2. Click **State machines** in the left sidebar.
3. Find the state machine named `AI6-Unit5W-ScaleOrFail-state-machine` (or use the `StateMachineArn` output from the deploy script, if you have a different name).
4. Click into it — you should see an empty **Executions** list (no runs yet).

✅ **Checkpoint:** The state machine `AI6-Unit5W-ScaleOrFail-state-machine` is visible and accessible.

---

## 📝 Task 2 — Find the CloudWatch Dashboard

💻 **Console:**

1. Navigate to **CloudWatch** in the AWS Console. (You may find it beneficial to do this in a new tab, so you have both Step Functions and CloudWatch open in your browser.)
2. Click **Dashboards** in the left sidebar.
3. Open the dashboard matching the `DashboardName` from the stack outputs.
4. Observe the widgets — all metrics will be **empty** at this stage ("No data available." — no executions have run yet).

✅ **Checkpoint:** The dashboard loads without errors. Metrics are present but show no data.

---

## 📝 Task 3 — Record Stack Outputs

From your CloudShell terminal (having recently run `./scripts/01_deploy.sh`), write down or screenshot the following stack outputs for use in later activities:

| Output Key         | Your Value |
|--------------------|------------|
| `StateMachineArn`  |            |
| `DashboardName`    |            |

💡 **Tip:** You can retrieve stack outputs again at any time by running from your terminal:

```bash
aws cloudformation describe-stacks \
  --stack-name AI6-Unit5W-ScaleOrFail \
  --query "Stacks[0].Outputs"
```

After running this, if you notice your terminal is unresponsive to your input, you may need to press Ctrl + C to regain control of the terminal.

---

## 🚀 Extension

Open the **CloudFormation** console, find the `AI6-Unit5W-ScaleOrFail` stack, and browse the **Resources** tab. See how many resources were created and what types they are ([Lambda functions](../../diagrams/aws_lambda.jpg), IAM roles, Step Functions state machine, CloudWatch dashboard, etc.).

---

🎓 **Complete** — proceed to [Activity 2](../activity-2/activity-2_start.md)
