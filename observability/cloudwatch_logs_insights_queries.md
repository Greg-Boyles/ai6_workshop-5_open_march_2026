# CloudWatch Logs Insights — ready-to-run queries (copy/paste)

## AWS Docs

- **CloudWatch Logs Insights**: `https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html`
> "With CloudWatch Logs Insights, you can interactively search and analyze your log data in Amazon CloudWatch Logs."

Open **CloudWatch → Logs Insights**.

Select log groups:
- `/aws/lambda/AI6-Unit5W-ScaleOrFail-preprocess`
- `/aws/lambda/AI6-Unit5W-ScaleOrFail-embed`
- `/aws/lambda/AI6-Unit5W-ScaleOrFail-postprocess`

> Coach tip: if learners can’t find the log groups, use the CloudFormation stack outputs to confirm the function names.

---

## 1) Recent log lines (last 15 minutes)
```sql
fields @timestamp, @message
| filter @timestamp > ago(15m)
| sort @timestamp desc
| limit 50
```

## 2) Extract the structured JSON fields we log
```sql
fields @timestamp, @message
| filter @timestamp > ago(15m)
| parse @message /"step"\s*:\s*"(?<step>[^"]+)"/
| parse @message /"duration_ms"\s*:\s*(?<duration_ms>\d+)/
| parse @message /"ticket_id"\s*:\s*"(?<ticket_id>[^"]+)"/
| display @timestamp, step, ticket_id, duration_ms, @message
| sort @timestamp desc
| limit 100
```

## 3) Average + max duration by step (last 15 minutes)
```sql
fields @timestamp, @message
| filter @timestamp > ago(15m)
| parse @message /"step"\s*:\s*"(?<step>[^"]+)"/
| parse @message /"duration_ms"\s*:\s*(?<duration_ms>\d+)/
| stats avg(duration_ms) as avg_ms, max(duration_ms) as max_ms, count(*) as n by step
| sort avg_ms desc
```

## 4) Spot “bad input” events (PayloadTooLarge)
```sql
fields @timestamp, @message
| filter @timestamp > ago(60m)
| filter @message like /PayloadTooLarge/
| sort @timestamp desc
| limit 50
```

### Where throttling shows up (quick reminder)
For this workshop, throttling evidence is most obvious in:
- **CloudWatch metric:** Embed Lambda → **Throttles**
- **User impact:** rising Duration p95 (“latency wall”)
- **Step Functions behaviour:** retries/backoff (executions may still succeed)
