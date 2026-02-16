# Activity 2: Solution — The Happy Path (Single Execution)

## Expected Execution Result

The script `./scripts/02_invoke_one.sh` should output something like:

```
Execution ARN: arn:aws:states:eu-west-1:123456789012:execution:AI6-Unit5W-ScaleOrFail:run-20260214-1430
Status: SUCCEEDED
Duration: 0.45s

Output:
{
  "route": "billing",
  "route_score": 0.87,
  "priority": "normal",
  "action": "auto-respond"
}
```

The exact values for `route`, `route_score`, `priority`, and `action` depend on the sample ticket used, but the structure will match.

## Step Durations

| Step        | Typical Duration | What It Does                                      |
|-------------|------------------|---------------------------------------------------|
| Preprocess  | ~5–15 ms         | Validates and cleans the input ticket text         |
| **Embed**   | **~200–400 ms**  | Runs the ML model (sentence embedding + routing)   |
| Postprocess | ~5–15 ms         | Applies business rules (priority, action)          |

## Answer: Identifying the Model Step

> "The model step is **Embed** because **it has the longest duration (~250 ms vs ~10 ms for pre/post), which is where the ML inference (sentence embedding and route classification) happens**."

## Output JSON Fields

| Field         | Description                              | Example Value    |
|---------------|------------------------------------------|------------------|
| `route`       | Predicted support category               | `"billing"`      |
| `route_score` | Confidence score (0–1)                   | `0.87`           |
| `priority`    | Business-rule priority                   | `"normal"`       |
| `action`      | Recommended next action                  | `"auto-respond"` |

## Extension — Embed Log Entry

In the CloudWatch log group for the Embed function, a structured log entry typically includes:

```json
{
  "level": "INFO",
  "message": "Embed complete",
  "input_length": 142,
  "model_load_ms": 120,
  "inference_ms": 85,
  "total_ms": 210,
  "route": "billing",
  "route_score": 0.87
}
```

Key observations:
- `model_load_ms` is high on a cold start, near zero on a warm invocation
- `inference_ms` is the actual ML computation time

---

## ✅ Self-Check

- [ ] `./scripts/02_invoke_one.sh` reported `SUCCEEDED`
- [ ] You can see the execution in the Step Functions console
- [ ] The execution graph shows three green (succeeded) steps
- [ ] Embed is clearly the slowest step (~200–400 ms)
- [ ] Output JSON contains `route`, `route_score`, `priority`, and `action`
- [ ] You can explain why Embed is the model step
