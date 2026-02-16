# Handout — Fishbone (for “Why didn’t it scale?”)
# 5.W Scaling Incident Diagnostic: The Fishbone Method

**Objective:** Transition from "guessing" about failures to evidenced-based Root Cause Analysis (RCA).

## The Diagnostic Mindset
In production, you don't have time to read every line of Python. You need to know if you should **add more workers** (Scale Out), **give workers more power** (Scale Up), or **fix a slow dependency**. The Fishbone tells you which lever to pull.

## The Scaling Failure Classes
We categorise scaling pain into four "bottleneck classes":
1. **Limits / Throttling:** You hit a hard safety cap set by the cloud provider (The "Throttles" metric).
2. **Resources:** The worker ran out of physical memory or CPU (The "Exhausted Engine").
3. **Dependencies:** An external API or database is slow, causing a massive backlog.
4. **Data / Input:** The specific payload (e.g., a massive image) broke the scaling logic.

## Rules of Engagement
* **Evidence First:** You are forbidden from adding a cause to a "bone" unless you can point to a specific metric or log entry.
* **One Safe Action:** Identify the immediate step to restore service, not just the long-term code fix.
## Effect (head of the fish)
**Pipeline slow / failing during traffic spike**

## Bones (main categories)
1) **Limits**
- reserved concurrency too low
- quotas
- rate limits

2) **Resources**
- memory too low
- CPU too low
- cold start overhead

3) **Dependencies**
- external API slow
- downstream service throttling
- network latency

4) **Data / Input**
- payload too big
- schema mismatch
- unexpected distribution shift

## How to use (fast)
- Put one piece of evidence on the fish first (metric/log/event)
- Only then add causes under the matching bone
- Pick one “first action” that is safe and reversible
