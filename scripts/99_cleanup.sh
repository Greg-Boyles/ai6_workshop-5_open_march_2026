#!/usr/bin/env bash
set -euo pipefail
WORKSHOP_NAME="${WORKSHOP_NAME:-AI6-Unit5W-ScaleOrFail}"
STACK_NAME="${STACK_NAME:-$WORKSHOP_NAME}"

echo "Deleting stack: $STACK_NAME"
aws cloudformation delete-stack --stack-name "$STACK_NAME"
echo "Waiting for delete..."
aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME"

# Lambda creates log groups on first invocation; CloudFormation does not manage/delete them.
# We delete only the three workshop log groups (if present).
for fn in preprocess embed postprocess; do
  lg="/aws/lambda/${WORKSHOP_NAME}-${fn}"
  count="$(aws logs describe-log-groups --log-group-name-prefix "$lg" --query "length(logGroups[?logGroupName=='$lg'])" --output text 2>/dev/null || echo 0)"
  if [ "$count" != "0" ]; then
    echo "Deleting log group: $lg"
    aws logs delete-log-group --log-group-name "$lg" || true
  fi
done

echo "Deleted."
