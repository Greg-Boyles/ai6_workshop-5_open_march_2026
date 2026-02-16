# Activity 1: Solution — Environment Setup & Orientation

## Expected Stack Outputs

After running `./scripts/01_deploy.sh`, you should see output similar to:

```
Stack deploy complete.

Outputs:
  StateMachineArn : arn:aws:states:eu-west-1:123456789012:stateMachine:AI6-Unit5W-ScaleOrFail-state-machine
  DashboardName   : AI6-Unit5W-ScaleOrFail-dashboard
```

The exact account ID and region will vary based on your lab environment.

## What the Dashboard Should Show

When you first open the CloudWatch Dashboard, you will see several widgets:

- **Embed Duration (p50 / p95)** — no data points yet
- **ConcurrentExecutions** — no data points yet
- **Execution Status (Succeeded / Failed)** — no data points yet
- **Throttles** — no data points yet

All panels display "No data available" or empty graphs. This is expected — you have not triggered any executions yet.

## CloudFormation Resources (Extension)

The Resources tab should show items including:

| Logical ID              | Type                                      |
|-------------------------|-------------------------------------------|
| PreprocessFunction      | AWS::Lambda::Function                     |
| EmbedFunction           | AWS::Lambda::Function                     |
| PostprocessFunction     | AWS::Lambda::Function                     |
| ScaleOrFailStateMachine | AWS::StepFunctions::StateMachine          |
| Dashboard               | AWS::CloudWatch::Dashboard                |
| PreprocessRole          | AWS::IAM::Role                            |
| EmbedRole               | AWS::IAM::Role                            |
| PostprocessRole         | AWS::IAM::Role                            |

(Exact names may differ slightly.)

---

## ✅ Self-Check

- [ ] `./scripts/00_set_region.sh` ran without errors
- [ ] `./scripts/01_deploy.sh` completed successfully
- [ ] You can see `StateMachineArn` and `DashboardName` in the outputs
- [ ] The state machine `AI6-Unit5W-ScaleOrFail-state-machine` is visible in Step Functions
- [ ] The CloudWatch Dashboard loads (with empty metrics)
