# CloudWatch Logs Insights — ready-to-run queries (copy/paste)

## AWS Docs

- **CloudWatch Logs Insights**: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html
> "With CloudWatch Logs Insights, you can interactively search and analyze your log data in Amazon CloudWatch Logs."

Open **CloudWatch → Logs Insights**.

Select log groups:
- `/aws/lambda/AI6-Unit5W-ScaleOrFail-preprocess`
- `/aws/lambda/AI6-Unit5W-ScaleOrFail-embed`
- `/aws/lambda/AI6-Unit5W-ScaleOrFail-postprocess`

> Coach tip: if learners can’t find the log groups, use the CloudFormation stack outputs to confirm the function names.

---

## 1) Recent log lines
```sql
fields @timestamp, @message
| sort @timestamp desc
| limit 50
```

## 2) Extract the structured JSON fields we log
```sql
fields @timestamp, step, ticket_id, duration_ms
| filter ispresent(step) and ispresent(ticket_id) and ispresent(duration_ms)
| sort @timestamp desc
```

> CloudWatch automatically parses JSON log messages, so you can reference fields like `step` directly without regex.

## 3) Average + max duration by step
```sql
fields step, duration_ms
| filter ispresent(step) and ispresent(duration_ms)
| stats avg(duration_ms) as avg_ms, max(duration_ms) as max_ms, count(*) as n by step
| sort avg_ms desc
```

## 4) Spot “bad input” events (PayloadTooLarge)
```sql
fields @timestamp, @message
| filter @message like /PayloadTooLarge/
| sort @timestamp desc
| limit 50
```

