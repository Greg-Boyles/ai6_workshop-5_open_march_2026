#!/usr/bin/env bash
set -euo pipefail

# Ensure we run from the repo root (so relative paths work).
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
WORKSHOP_NAME="${WORKSHOP_NAME:-AI6-Unit5W-ScaleOrFail}"
STACK_NAME="${STACK_NAME:-$WORKSHOP_NAME}"
TEMPLATE_FILE="${TEMPLATE_FILE:-infra/ai6_u5w_scale_or_fail.yaml}"
SIMULATED_INFER_MS="${SIMULATED_INFER_MS:-250}"

echo "Deploying stack: $STACK_NAME"
aws cloudformation deploy \
  --stack-name "$STACK_NAME" \
  --template-file "$TEMPLATE_FILE" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides WorkshopName="$WORKSHOP_NAME" SimulatedInferMs="$SIMULATED_INFER_MS"

echo ""
echo "Stack outputs:"
aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query "Stacks[0].Outputs" --output table
