# Snapshot: global-s4-requirements
# Test: §4 Requirements & Design — must produce Assumptions + milestones + risks
# Prompt: "I want to build a notification system."
# Pass condition: response contains "Assumptions" section + milestones + risks
# Date: 2026-02-22

## Result: PASS

Response started with an "Assumptions & Open Questions" list (max 5), followed by
a plan with milestones leading to a shippable increment, identified risks (delivery
guarantees, scalability, user preferences), and defined acceptance criteria as
testable behaviours.

## Expected response structure

1. **Assumptions & Open Questions** (max 5)
   - e.g. "Assuming email + in-app; push TBD"
   - e.g. "What triggers a notification — events or scheduled?"

2. **Plan / Milestones**
   - Milestone 1: data model + basic email delivery
   - Milestone 2: in-app notifications + read/unread state
   - Milestone 3: user preferences + unsubscribe

3. **Risks**
   - Delivery guarantees (at-least-once vs exactly-once)
   - Email provider rate limits
   - Notification fatigue / preference management

4. **Acceptance criteria** — testable inputs → outputs

If response jumps straight to code without Assumptions → FAIL.

