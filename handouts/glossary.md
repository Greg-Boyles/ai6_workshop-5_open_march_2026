# One-page Glossary


- **Scaling**: keeping the system responsive when traffic grows.
- **Bottleneck**: the slowest/most limited step that controls overall throughput.
- **P95 duration (95th percentile)**: a performance metric indicating that 95% of requests or transactions finish faster than a specific threshold, while the slowest 5% take longer. It is used to identify bottlenecks, measure the user experience for the slowest transactions, and ignore outliers that skew averages.
- **Horizontal scaling**: adding more workers (more concurrent executions / replicas).
- **Vertical scaling**: giving each worker more resources (memory/CPU per request).

- **Orchestration**: defining the workflow of steps (the map of work) with guardrails like retries and timeouts.
- **Pipeline**: the ordered steps that transform an input into an output.

- **Observability**: using metrics, logs, and traces to understand the system’s behaviour.
- **RCA (Root Cause Analysis)**: a repeatable way to explain *why* the incident happened, using evidence.

- **Throttling**: requests being rejected due to hard limits (often concurrency/quotas).
- **Cold start**: serverless start-up overhead for new runtime instances.

Kubernetes "transferable" vocabulary (if you're familiar with DevOps/ Data Engineering):
- Lambda concurrency ≈ number of pod replicas / autoscaler behaviour
- Lambda memory ≈ pod requests/limits
- Step Functions graph ≈ a DAG orchestrator view (Argo/Airflow)
