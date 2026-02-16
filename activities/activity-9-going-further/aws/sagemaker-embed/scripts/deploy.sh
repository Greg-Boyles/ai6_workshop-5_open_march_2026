#!/usr/bin/env bash
set -euo pipefail

# Going Further: deploy an isolated stack variant where the Embed step is a SageMaker serverless endpoint.
# This does NOT modify the core workshop stack/template.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

WORKSHOP_NAME="${WORKSHOP_NAME:-AI6-Unit5W-ScaleOrFail-gf-sagemaker}"
STACK_NAME="${STACK_NAME:-$WORKSHOP_NAME}"
TEMPLATE_FILE="${TEMPLATE_FILE:-cloudformation/template.yaml}"

SIMULATED_INFER_MS="${SIMULATED_INFER_MS:-250}"
SAGEMAKER_MAX_CONCURRENCY="${SAGEMAKER_MAX_CONCURRENCY:-2}"

AWS_REGION="${AWS_REGION:-$(aws configure get region 2>/dev/null || true)}"
if [ -z "${AWS_REGION:-}" ]; then
  echo "AWS region is not set. Run ./scripts/00_set_region.sh first." >&2
  exit 1
fi

AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

WS_HASH="$(python3 - <<PY
import hashlib, os
print(hashlib.sha1(os.environ["WORKSHOP_NAME"].encode("utf-8")).hexdigest()[:10])
PY
)"

# Bucket must be globally unique, so include account+region+hash.
S3_BUCKET="ai6-ws5-gf-sm-${AWS_ACCOUNT_ID}-${AWS_REGION}-${WS_HASH}"
MODEL_KEY="sagemaker/${WORKSHOP_NAME}/model.tar.gz"
CODE_KEY="sagemaker/${WORKSHOP_NAME}/source.tar.gz"

echo "Deploying going-further stack: $STACK_NAME"
echo "WorkshopName: $WORKSHOP_NAME"
echo "S3 bucket:     $S3_BUCKET"
echo "Model key:     $MODEL_KEY"
echo "Code key:      $CODE_KEY"

if ! aws s3api head-bucket --bucket "$S3_BUCKET" >/dev/null 2>&1; then
  echo "Creating bucket: $S3_BUCKET"
  if [ "$AWS_REGION" = "us-east-1" ]; then
    aws s3api create-bucket --bucket "$S3_BUCKET" >/dev/null
  else
    aws s3api create-bucket --bucket "$S3_BUCKET" --create-bucket-configuration "LocationConstraint=$AWS_REGION" >/dev/null
  fi
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
mkdir -p "$TMP_DIR/model" "$TMP_DIR/source"

cat > "$TMP_DIR/source/inference.py" <<'PY'
import json, time, math, hashlib, os

DIM = 384
SIM_MS = int(os.environ.get("SIMULATED_INFER_MS", "250"))
MODEL_NAME = "sentence-transformers/all-MiniLM-L6-v2 (simulated via SageMaker script mode)"

PROTOTYPES = {
    "billing": "charged twice refund invoice payment",
    "delivery": "delivery late missing parcel tracking",
    "technical": "cannot login error bug crash password reset",
    "cancellation": "cancel subscription stop service end membership"
}

def _embed(text: str):
    vec = [0.0] * DIM
    for token in (text or "").lower().split():
        h = hashlib.md5(token.encode("utf-8")).digest()
        idx = int.from_bytes(h[:2], "big") % DIM
        sign = 1.0 if (h[2] % 2 == 0) else -1.0
        vec[idx] += sign
    norm = math.sqrt(sum(v*v for v in vec)) or 1.0
    return [v / norm for v in vec]

PROTO_EMB = {k: _embed(v) for k, v in PROTOTYPES.items()}

def _cos(a, b):
    return sum(x*y for x, y in zip(a, b))

def model_fn(model_dir):
    # No trained artifacts needed; keep it deterministic and cheap.
    return None

def input_fn(request_body, request_content_type):
    if request_content_type and "json" in request_content_type:
        if isinstance(request_body, (bytes, bytearray)):
            request_body = request_body.decode("utf-8")
        return json.loads(request_body or "{}")
    raise ValueError(f"Unsupported content type: {request_content_type}")

def predict_fn(data, model):
    start = time.time()
    ticket_id = data.get("ticket_id", "T-UNKNOWN")
    text = data.get("text", "")

    time.sleep(SIM_MS / 1000.0)

    vec = _embed(text)
    scores = {k: _cos(vec, e) for k, e in PROTO_EMB.items()}
    best = max(scores, key=scores.get)
    best_score = float(scores[best])

    top_idx = sorted(range(DIM), key=lambda i: abs(vec[i]), reverse=True)[:12]
    sig = ";".join(f"{i}:{vec[i]:.3f}" for i in top_idx)
    emb_hash = hashlib.md5(sig.encode("utf-8")).hexdigest()[:10]

    out = dict(data)
    out.update({
        "model": MODEL_NAME,
        "embedding_dim": DIM,
        "embedding_hash": emb_hash,
        "route": best,
        "route_score": round(best_score, 3),
        "duration_ms": int((time.time() - start) * 1000),
    })
    print(json.dumps({"step":"embed","ticket_id":ticket_id,"duration_ms":out["duration_ms"],"route":best,"route_score":out["route_score"],"emb_hash":emb_hash}))
    return out

def output_fn(prediction, accept):
    return json.dumps(prediction).encode("utf-8")
PY

echo "placeholder" > "$TMP_DIR/model/README.txt"
tar -C "$TMP_DIR/model" -czf "$TMP_DIR/model.tar.gz" .
tar -C "$TMP_DIR/source" -czf "$TMP_DIR/source.tar.gz" .

echo "Uploading SageMaker artifacts..."
aws s3 cp "$TMP_DIR/model.tar.gz" "s3://${S3_BUCKET}/${MODEL_KEY}" >/dev/null
aws s3 cp "$TMP_DIR/source.tar.gz" "s3://${S3_BUCKET}/${CODE_KEY}" >/dev/null

aws cloudformation deploy \
  --stack-name "$STACK_NAME" \
  --template-file "$TEMPLATE_FILE" \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    WorkshopName="$WORKSHOP_NAME" \
    SimulatedInferMs="$SIMULATED_INFER_MS" \
    SageMakerModelDataBucket="$S3_BUCKET" \
    SageMakerModelDataKey="$MODEL_KEY" \
    SageMakerCodeBucket="$S3_BUCKET" \
    SageMakerCodeKey="$CODE_KEY" \
    SageMakerMaxConcurrency="$SAGEMAKER_MAX_CONCURRENCY"

echo ""
echo "Stack outputs:"
aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query "Stacks[0].Outputs" --output table
