#!/usr/bin/env bash
set -euo pipefail
WORKSHOP_NAME="${WORKSHOP_NAME:-AI6-Unit5W-ScaleOrFail}"
STACK_NAME="${STACK_NAME:-$WORKSHOP_NAME}"

SM_ARN="$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query "Stacks[0].Outputs[?OutputKey=='StateMachineArn'].OutputValue" --output text)"
echo "State machine: $SM_ARN"

INPUT='{"max_concurrency":1,"tickets":[{"ticket_id":"T-1001","text":"My delivery is late and the tracking link is broken. Please help."}]}'
EXEC_ARN="$(aws stepfunctions start-execution --state-machine-arn "$SM_ARN" --input "$INPUT" --query "executionArn" --output text)"
echo "ExecutionArn: $EXEC_ARN"

# Wait for completion (poll; works even when 'aws stepfunctions wait' isn't available)
for i in $(seq 1 60); do
  STATUS="$(aws stepfunctions describe-execution --execution-arn "$EXEC_ARN" --query status --output text)"
  if [ "$STATUS" = "SUCCEEDED" ]; then
    echo "Status: SUCCEEDED"
    break
  elif [ "$STATUS" = "FAILED" ] || [ "$STATUS" = "TIMED_OUT" ] || [ "$STATUS" = "ABORTED" ]; then
    echo "Status: $STATUS"
    aws stepfunctions describe-execution --execution-arn "$EXEC_ARN" --output json
    exit 1
  fi
  sleep 2
done

echo "Output:"
aws stepfunctions describe-execution --execution-arn "$EXEC_ARN" --query "output" --output text | python3 -m json.tool
