#!/usr/bin/env bash
set -euo pipefail

# Pluralsight/A Cloud Guru AWS sandbox restriction: only us-east-1 and us-west-2 are allowed.
# We use us-east-1 for consistency.
export AWS_REGION="${AWS_REGION:-us-east-1}"
aws configure set region "$AWS_REGION"
echo "Region set to: $AWS_REGION"
