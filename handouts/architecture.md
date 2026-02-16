# Architecture

## AWS Docs (Core Services)

See `docs/aws_service_docs.md` for the core AWS service docs links and key quotes.

```
                (Burst load)
                     |
                     v
        +---------------------------+
        |  Step Functions (workflow)|
        |  AI6-Unit5W-ScaleOrFail-  |
        |  state-machine            |
        +-------------+-------------+
                      |
                      v
            +-------------------+
            | Preprocess Lambda |
            |  (fast)           |
            +---------+---------+
                      |
                      v
            +-------------------+
            | Embed / Model     |
            | Lambda (slow)     |  (simulated ~250ms)
            +---------+---------+
                      |
                      v
            +-------------------+
            | Postprocess       |
            | Lambda (fast)     |
            +---------+---------+
                      |
                      v
                 Output JSON

Scaling:
- Throughput is primarily controlled by the Step Functions Map state's `MaxConcurrency` (passed in as `max_concurrency`).
- The intentional "wall" is demonstrated when `MaxConcurrency` is low (for example 2) and work queues up under burst load.

Observability:
- CloudWatch Dashboard: Duration p95, Throttles, Errors
- CloudWatch Logs: structured JSON per step
- Step Functions execution graph: where time/errors occur
```
