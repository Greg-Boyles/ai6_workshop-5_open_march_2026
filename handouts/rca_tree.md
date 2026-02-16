# Handout — Scaling RCA Tree (4 leaves)

When your pipeline is slow or failing under load, classify it into one of these.

## AWS Docs (Core Services)

- **AWS Lambda**: `https://docs.aws.amazon.com/lambda/latest/dg/welcome.html`
> "AWS Lambda is a compute service that runs code without the need to manage servers."

- **AWS Step Functions**: `https://docs.aws.amazon.com/step-functions/latest/dg/welcome.html`
> "With AWS Step Functions, you can create workflows, also called State machines, to build distributed applications, automate processes, orchestrate microservices,"

- **Amazon CloudWatch**: `https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html`
> "Amazon CloudWatch monitors your Amazon Web Services (AWS) resources and the applications you run on AWS in real time,"

---

## 1) THROTTLED (hard limit)
**What it looks like**
- CloudWatch: Throttles > 0
- Step Functions event history: TooManyRequests / throttling errors
- Symptoms: some requests fail immediately even though code is “fine”

**Likely causes**
- Reserved concurrency too low
- Account concurrency/quotas hit

**First safe actions**
- Increase reserved concurrency for the bottleneck function (small step: +3 to +10)
- Reduce burst size (rate limiting) *temporarily*
- Add retries/backoff (or increase attempts) if you can tolerate delay

---

## 2) EXHAUSTED (resource per request)
**What it looks like**
- Duration p95 is high even at low traffic
- Errors like OutOfMemory / timeouts on single requests
- CPU-bound behaviour

**Likely causes**
- Model too heavy for the chosen runtime
- Memory too low, causing slowdowns / repeated work

**First safe actions**
- Increase memory (vertical scaling) for that function
- Reduce payload size (token limits)
- Consider alternative hosting (container service / GPU) if model cannot fit

---

## 3) TIMED OUT (dependency / backlog)
**What it looks like**
- Duration grows over time
- Timeouts, retries, “stuck” feeling
- Often the slow part is *not* the model

**Likely causes**
- External dependency slow (DB, API)
- Backlog/queue build-up

**First safe actions**
- Identify the dependency
- Add caching, batching, async patterns (future work)
- Increase timeout only after proving where the time is going

---

## 4) BAD INPUT (schema / payload)
**What it looks like**
- Immediate failures on certain requests
- Clear validation errors (PayloadTooLarge, missing fields)

**Likely causes**
- No validation gate
- Unexpected upstream changes

**First safe actions**
- Validate early (preprocess)
- Reject fast with clear error + logging
- Add schema checks / versioning (future work)
