#!/usr/bin/env bash
set -euo pipefail
WORKSHOP_NAME="${WORKSHOP_NAME:-AI6-Unit5W-ScaleOrFail}"
STACK_NAME="${STACK_NAME:-$WORKSHOP_NAME}"

SM_ARN="$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[?OutputKey=='StateMachineArn'].OutputValue | [0]" --output text)"
echo "State machine: $SM_ARN"

# Deterministic >5000 char payload to trigger PayloadTooLarge in Preprocess.
INPUT="$(python3 - <<'PY'
import json
print(json.dumps({
  "max_concurrency": 1,
  "tickets": [
    {"ticket_id": "T-BAD-1", "text": "x"*5100}
  ]
}))
PY
)"

EXEC_ARN="$(aws stepfunctions start-execution --state-machine-arn "$SM_ARN" --input "$INPUT" --query "executionArn" --output text)"
echo "ExecutionArn: $EXEC_ARN"
echo "This execution should FAIL in Preprocess with PayloadTooLarge."
echo "Open Step Functions -> Executions -> click this execution -> see the error."
