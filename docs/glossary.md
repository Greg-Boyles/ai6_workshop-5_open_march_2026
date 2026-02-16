# Glossary

## Scaling

- **Scaling** — keeping the system responsive when traffic grows.
- **Bottleneck** — the slowest or most limited step that controls overall throughput.
- **P95 duration (95th percentile)** — a performance metric indicating that 95% of requests finish faster than a specific threshold. Used to measure user experience for the slowest transactions while ignoring extreme outliers.
- **Horizontal scaling** — adding more workers (more concurrent executions / replicas).
- **Vertical scaling** — giving each worker more resources (memory/CPU per request).

## Orchestration

- **Orchestration** — defining the workflow of steps (the map of work) with guardrails like retries and timeouts.
- **Pipeline** — the ordered steps that transform an input into an output.
- **Map state** — a Step Functions construct that processes a list of items, optionally in parallel, with a configurable `MaxConcurrency` limit.

## Observability

- **Observability** — using metrics, logs, and traces to understand the system's behaviour.
- **RCA (Root Cause Analysis)** — a repeatable way to explain *why* an incident happened, using evidence rather than guesses.
- **CloudWatch Logs Insights** — a query language for searching and analysing log data in CloudWatch.

## Failure Modes

- **Throttling** — requests being rejected or delayed due to hard limits (concurrency quotas).
- **Cold start** — serverless start-up overhead when a new runtime instance is initialised.
- **PayloadTooLarge** — a validation error when input data exceeds the accepted size limit.

## Kubernetes Transferable Vocabulary

If you are familiar with container orchestration:

| This workshop | Kubernetes equivalent |
|---------------|----------------------|
| Lambda concurrency | Number of pod replicas / autoscaler behaviour |
| Lambda memory | Pod resource requests and limits |
| Step Functions graph | DAG orchestrator view (Argo Workflows / Airflow) |
| Map state MaxConcurrency | Parallelism setting in a Job or Workflow |
