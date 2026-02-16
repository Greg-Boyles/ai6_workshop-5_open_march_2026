# Architecture Diagrams

## 1. Pipeline Overview

```
                 (Burst load: 40 tickets)
                          |
                          v
           +-----------------------------+
           |  Step Functions State Machine|
           |  AI6-Unit5W-ScaleOrFail      |
           +-----------------------------+
                          |
                    [Map State]
                   MaxConcurrency
                     = 2 or 10
                          |
              +-----------+-----------+
              |           |           |
              v           v           v    ... (up to MaxConcurrency)
     +----------------+  +----------------+
     | Per-ticket flow|  | Per-ticket flow|
     +----------------+  +----------------+
              |
              v
    +-------------------+
    | Preprocess Lambda |
    |  (fast, ~10ms)    |
    | Validate + clean  |
    +---------+---------+
              |
              v
    +-------------------+
    | Embed / Model     |
    | Lambda (slow,     |
    | ~250ms simulated) |  <-- THE BOTTLENECK
    +---------+---------+
              |
              v
    +-------------------+
    | Postprocess       |
    | Lambda (fast,     |
    | ~10ms)            |
    +---------+---------+
              |
              v
         Output JSON
    {route, priority, action}
```

---

## 2. The Scaling Wall (Before vs After)

### Before: MaxConcurrency = 2

```
Time -->

Worker 1: [T-0001][T-0003][T-0005][T-0007] ... [T-0039]
Worker 2: [T-0002][T-0004][T-0006][T-0008] ... [T-0040]

Total: 40 tickets / 2 workers = 20 batches x ~250ms = ~15-20 seconds
```

### After: MaxConcurrency = 10

```
Time -->

Worker 1:  [T-0001][T-0011][T-0021][T-0031]
Worker 2:  [T-0002][T-0012][T-0022][T-0032]
Worker 3:  [T-0003][T-0013][T-0023][T-0033]
Worker 4:  [T-0004][T-0014][T-0024][T-0034]
Worker 5:  [T-0005][T-0015][T-0025][T-0035]
Worker 6:  [T-0006][T-0016][T-0026][T-0036]
Worker 7:  [T-0007][T-0017][T-0027][T-0037]
Worker 8:  [T-0008][T-0018][T-0028][T-0038]
Worker 9:  [T-0009][T-0019][T-0029][T-0039]
Worker 10: [T-0010][T-0020][T-0030][T-0040]

Total: 40 tickets / 10 workers = 4 batches x ~250ms = ~4-7 seconds
```

---

## 3. Observability Stack

```
+------------------+     +------------------+     +------------------+
| Step Functions   |     | Lambda Functions |     | CloudWatch       |
|                  |     |                  |     |                  |
| - Execution      |     | - Preprocess     |     | - Dashboard      |
|   history        |     | - Embed          |     |   (metrics)      |
| - Visual graph   |     | - Postprocess    |     | - Logs Insights  |
| - Input/Output   |     |                  |     |   (queries)      |
| - Error details  |     | Each emits:      |     | - Alarms         |
+------------------+     | - Structured     |     +------------------+
                          |   JSON logs      |
                          | - Duration       |
                          | - Invocations    |
                          | - Errors         |
                          | - Throttles      |
                          +------------------+
```

---

## 4. RCA Classification Tree

```
Pipeline slow or failing under load?
          |
    +-----+------+------+------+
    |            |       |      |
    v            v       v      v
THROTTLED   EXHAUSTED  TIMED   BAD
(hard       (resource  OUT     INPUT
 limit)      per req)  (dep)   (data)
    |            |       |      |
Evidence:   Evidence:  Evidence: Evidence:
Throttles>0 High p95   Duration  Immediate
or rejected at low     grows    failures,
requests    traffic    over     validation
                       time     errors
```

---

## 5. Fishbone Diagnostic

```
    Limits          Resources       Dependencies     Data/Input
      |                |                |                |
  concurrency     memory too low   external API     payload too big
  quotas          CPU bound        downstream svc   schema mismatch
  rate limits     cold starts      network latency  distribution shift
      |                |                |                |
      +-------+--------+--------+------+
              |
              v
    [Pipeline slow / failing during traffic spike]
              (Effect = head of the fish)
```
