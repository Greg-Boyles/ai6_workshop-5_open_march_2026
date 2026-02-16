#!/usr/bin/env bash
set -euo pipefail

# Going Further cleanup: deletes the isolated SageMaker-embed stack and the S3 bucket used for its model/code artifacts.
# Does NOT touch the core workshop stack unless you point STACK_NAME at it (don't).

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

WORKSHOP_NAME="${WORKSHOP_NAME:-AI6-Unit5W-ScaleOrFail-gf-sagemaker}"
STACK_NAME="${STACK_NAME:-$WORKSHOP_NAME}"

AWS_REGION="${AWS_REGION:-$(aws configure get region 2>/dev/null || true)}"
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

WS_HASH="$(python3 - <<PY
import hashlib, os
print(hashlib.sha1(os.environ["WORKSHOP_NAME"].encode("utf-8")).hexdigest()[:10])
PY
)"

S3_BUCKET="ai6-ws5-gf-sm-${AWS_ACCOUNT_ID}-${AWS_REGION}-${WS_HASH}"

PREPROCESS_FN=""
POSTPROCESS_FN=""
EMBED_ENDPOINT=""

# Capture generated Lambda names from stack outputs (template no longer forces FunctionName).
if aws cloudformation describe-stacks --stack-name "$STACK_NAME" >/dev/null 2>&1; then
  PREPROCESS_FN="$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query "Stacks[0].Outputs[?OutputKey=='PreprocessFunctionName'].OutputValue | [0]" --output text 2>/dev/null || true)"
  POSTPROCESS_FN="$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query "Stacks[0].Outputs[?OutputKey=='PostprocessFunctionName'].OutputValue | [0]" --output text 2>/dev/null || true)"
  EMBED_ENDPOINT="$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query "Stacks[0].Outputs[?OutputKey=='EmbedEndpointName'].OutputValue | [0]" --output text 2>/dev/null || true)"
fi

echo "Deleting stack: $STACK_NAME"
aws cloudformation delete-stack --stack-name "$STACK_NAME"
echo "Waiting for delete..."
aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME"

# Delete Lambda log groups (created on first invocation).
for fn in "$PREPROCESS_FN" "$POSTPROCESS_FN"; do
  if [ -n "${fn:-}" ] && [ "$fn" != "None" ]; then
    lg="/aws/lambda/${fn}"
    count="$(aws logs describe-log-groups --log-group-name-prefix "$lg" --query "length(logGroups[?logGroupName=='$lg'])" --output text 2>/dev/null || echo 0)"
    if [ "$count" != "0" ]; then
      echo "Deleting log group: $lg"
      aws logs delete-log-group --log-group-name "$lg" || true
    fi
  fi
done

if [ -n "${EMBED_ENDPOINT:-}" ] && [ "$EMBED_ENDPOINT" != "None" ]; then
  lg="/aws/sagemaker/Endpoints/${EMBED_ENDPOINT}"
  count="$(aws logs describe-log-groups --log-group-name-prefix "$lg" --query "length(logGroups[?logGroupName=='$lg'])" --output text 2>/dev/null || echo 0)"
  if [ "$count" != "0" ]; then
    echo "Deleting log group: $lg"
    aws logs delete-log-group --log-group-name "$lg" || true
  fi
fi

echo "Deleting S3 bucket (model/code artifacts): $S3_BUCKET"
aws s3 rm "s3://${S3_BUCKET}" --recursive >/dev/null 2>&1 || true
aws s3api delete-bucket --bucket "$S3_BUCKET" >/dev/null 2>&1 || true

echo "Cleanup complete."
