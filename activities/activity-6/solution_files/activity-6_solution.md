# Activity 6: Solution — Controlled Failure — Bad Input (RCA Incident 1)

---

## Task 3 — Error Message

The error message should contain **PayloadTooLarge** (or a similar validation error) in the Preprocess step. The execution failed immediately on the first step without reaching Embed or Postprocess.

---

## Task 4 — RCA Tree Classification

**Classification: BAD INPUT (leaf 4)**

This is a data quality issue, not a scaling issue.

---

## Task 5 — Ruling Out Other Leaves

| RCA Leaf | Matches? | Why / Why not? |
|---|---|---|
| THROTTLED | No | The pipeline was not under load. There was only a single request. No TooManyRequests errors, no Throttles metric spike. |
| EXHAUSTED | No | This was a single request, not a resource exhaustion issue. No OutOfMemory errors. The function did not run out of memory or CPU. |
| TIMED OUT | No | The failure was immediate, not a slow degradation. There were no retries or growing duration. The function failed fast. |
| BAD INPUT | **Yes** | The error was an immediate validation failure (PayloadTooLarge). The payload exceeded the allowed input size. This is a data quality issue with no validation gate. |

---

## Task 6 — Logs Insights Query Output

The query should return log entries showing:
- A `PayloadTooLarge` error in the preprocess function
- An immediate failure (low duration_ms)
- A single ticket_id that caused the problem

---

## Task 7 — Model Incident Report

- **What happened:** A single support ticket with an oversized payload was submitted to the pipeline. The Preprocess Lambda function rejected it with a PayloadTooLarge error, causing the entire Step Functions execution to fail.
- **Evidence:** CloudWatch Logs show `PayloadTooLarge` in the preprocess log group. Step Functions execution status is FAILED. The error occurred on the first step with no other tickets in the batch.
- **Classification:** BAD INPUT (RCA Tree leaf 4) — immediate validation failure caused by data that exceeds size limits.
- **First safe action:** Add a payload size validation check at the start of the Preprocess function. Reject oversized payloads early with a clear, structured error message (including the ticket_id and the size limit) so the caller can fix the data before resubmitting.

---

## Extension — Validation Rule

Add a validation gate at the **start** of the Preprocess function:

1. **Check:** If `len(payload_text) > MAX_PAYLOAD_BYTES` (e.g., 256 KB)
2. **Action:** Return a structured error immediately:
   ```json
   {
     "error": "PayloadTooLarge",
     "ticket_id": "TICKET-123",
     "payload_size_bytes": 512000,
     "max_allowed_bytes": 262144,
     "message": "Ticket text exceeds maximum size. Truncate or split before resubmitting."
   }
   ```
3. **Why early?** Catching it in Preprocess prevents the pipeline from wasting time on Embed (the most expensive step). Fail fast, fail cheap.

---

## Self-Check Checklist

- [ ] I triggered a FAILED execution using the bad input script
- [ ] I found the PayloadTooLarge error in the Step Functions execution detail
- [ ] I correctly classified this as BAD INPUT, not a scaling issue
- [ ] I ruled out the other three RCA leaves with specific reasoning
- [ ] I ran Query 4 in Logs Insights and found the error entry
- [ ] I wrote an incident report with specific evidence (not just "it failed")
- [ ] I understand that this failure happened at low load — it is a data quality issue, not a throughput issue
