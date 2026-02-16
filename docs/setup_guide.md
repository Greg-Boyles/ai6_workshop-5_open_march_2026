# Setup Guide

## AWS Docs (Core Services)

See [AWS service docs and key quotes](aws_service_docs.md).

## Environment: AWS Cloud Sandbox

This workshop uses the **AWS Cloud Sandbox** provided via Pluralsight / A Cloud Guru.

⚠️ **Warning:** Do not start the sandbox until your coach tells you to (~10:45). The sandbox has a ~4 hour time limit.

---

## Step 1: Start Your Sandbox

1. Go to your Pluralsight / A Cloud Guru sandbox
2. Start an **AWS Cloud Sandbox**
3. Wait for the sandbox to provision (this takes 1-2 minutes)
4. Click **Open Console** to access the AWS Management Console

---

## Step 2: Open CloudShell

1. In the AWS Console, click the **CloudShell** icon in the top navigation bar (it looks like a terminal prompt `>_`)
2. Wait for CloudShell to initialise (first time may take 30 seconds)

✅ **Checkpoint:** You should see a terminal prompt like:
```
[cloudshell-user@ip-10-x-x-x ~]$
```

---

## Step 3: Upload Workshop Files

### Option A: Upload zip (recommended)

1. Your coach will provide a zip file of the workshop repository
2. In CloudShell, click **Actions** (top right) > **Upload file**
3. Select the zip file and upload it
4. Run:

```bash
unzip ai6_unit5w_scale_or_fail*.zip
cd ai6_workshop-5
chmod +x scripts/*.sh
```

### Option B: Clone from repository

If you have access to the repository:

```bash
git clone <repository-url>
cd ai6_workshop-5
chmod +x scripts/*.sh
```

✅ **Checkpoint:** Run `ls` and you should see:
```
activities/  data/  diagrams/  docs/  infra/  README.md  scripts/  user_brief.md
```

### Option C: Ask your coach for help (backup)

If you cannot upload files and cannot clone the repo, ask your coach for the backup setup method.

---

## Step 4: Set Your Region

```bash
./scripts/00_set_region.sh
```

Expected output:
```
Region set to: us-east-1
```

💡 **Tip:** The sandbox only supports `us-east-1` and `us-west-2`. We standardise on `us-east-1`.

---

## Step 5: Deploy the Stack

```bash
./scripts/01_deploy.sh
```

This deploys a CloudFormation stack with:
- 3 Lambda functions (Preprocess, Embed, Postprocess)
- 1 Step Functions state machine
- 1 CloudWatch dashboard
- Associated IAM roles and log groups

📘 **Note:** This workshop scales via Step Functions Map `max_concurrency` (not by changing Lambda reserved concurrency).

⚠️ **Warning:** Deployment takes 2-3 minutes. Do not interrupt it.

✅ **Checkpoint:** You should see a table of stack outputs including:
- `StateMachineArn`
- `DashboardName`

---

## Step 6: Verify in the Console

1. 💻 Open **Step Functions** in the AWS Console
   - You should see a state machine called `AI6-Unit5W-ScaleOrFail-state-machine`
2. 💻 Open **CloudWatch > Dashboards**
   - You should see a dashboard with widgets for Lambda metrics (typically `AI6-Unit5W-ScaleOrFail-dashboard`)

🎓 **You are ready to begin Activity 1.**

---

## Troubleshooting

### Deploy fails
- Confirm your region is `us-east-1`: `aws configure get region`
- Re-run: `./scripts/01_deploy.sh`

### Permission denied running scripts
```bash
chmod +x scripts/*.sh
```

### CloudShell disconnects
- CloudShell times out after ~20 minutes of inactivity
- Reconnect and `cd ai6_workshop-5` to return to your working directory
- Your deployed stack is still running (it's independent of CloudShell)
