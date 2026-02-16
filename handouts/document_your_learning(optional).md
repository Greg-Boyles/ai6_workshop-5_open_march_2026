# Workshop 5.W: Orchestrating Complex ML Pipelines
## (OPTIONAL) Evidence Record: Scaling & Root Cause Analysis

**Apprentice Name:** ___________________
**Date:** ___________________

---

### 1. The Scenario (Context)
*Briefly describe the "Flash Sale" scenario and the architecture we deployed (Step Functions + Lambda).*

> **Context:** We deployed a serverless inference pipeline to handle a simulated traffic spike. The goal was to maintain stability under 10x load.

---

### 2. Monitoring & Stability (S10)
*Paste a screenshot of your CloudWatch Dashboard showing the "Scaling Wall" (the moment metrics turned red).*

**Observation:**
- **Metric Observed:** (e.g., `ThrottledEvents` count or `DurationP95`)
- **What it indicated:** (e.g., The system hit a hard concurrency limit of 5, causing 40% of requests to fail immediately.)

---

### 3. Impartial Decision Making (S26)
*Describe how you used the "Fishbone" framework to classify the root cause without guessing.*

**The Evidence-Based Approach:**
- I reviewed the logs and found: _________________________________________________
- I reviewed the metrics and found: ______________________________________________

**Root Cause Classification:**
- [ ] **THROTTLED** (Hard Limit)
- [ ] **EXHAUSTED** (Resource Saturation)
- [ ] **TIMED OUT** (Dependency Latency)
- [ ] **BAD INPUT** (Data Schema)

*Why did you rule out the other options?*
> I ruled out "Exhausted" because memory usage was stable at 45MB. I ruled out "Timed Out" because the duration was short (hits rejected instantly).

---

### 4. Scalability & Re-engineering (S19, S9)
*Describe the fix you applied to ensure capacity met operating requirements.*

**The Fix:**
- I modified the **Reserved Concurrency** parameter from `___` to `___`.

**The Result:**
*Paste a second screenshot of the CloudWatch Dashboard showing the "Green" state after the fix.*

**Justification:**
> By increasing the concurrency limit, I aligned the system's capacity with the burst requirement (S19), allowing the queue to drain without hitting the hard throttle limit.

---

### 5. Professional Responsibility (B2, B5)
*Reflect on the trade-offs of your decision.*

- **Sustainability & Cost (B2):** Increasing concurrency increases the potential cost if the lambda runs indefinitely. To mitigate this, I would suggest adding a billing alarm or a maximum burst limit.
- **Uncertainty (B5):** In a real incident, I would also check downstream dependencies (like a database) to ensure my "Fix" didn't just move the bottleneck further down the chain.

---

## Evidence checklist (quick mark)

Aim to collect:
1) Step Functions execution screenshot (happy path).  
2) Step Functions execution screenshot showing failure at Embed (TooManyRequests) under burst.  
3) CloudWatch dashboard screenshot showing throttles/duration under burst (before fix).  
4) CloudWatch dashboard screenshot showing improved throttles/duration (after fix).  
5) Completed RCA Tree + Fishbone (photo/scan is fine).  
6) A one-paragraph incident report (or the template completed).

---

### Instructor / Peer Verification
**Verified by:** ___________________
**Feedback:**
