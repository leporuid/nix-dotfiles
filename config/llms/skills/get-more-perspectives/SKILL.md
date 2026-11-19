---
name: get-more-perspectives
description: Convenes a virtual advisory panel of experts (Operator, Skeptic, Visionary, Customer Advocate, Performance Mind, plus Systems Architect and Security Auditor) to evaluate decisions, judge feature/product viability, or triage batches of requests. Use when facing strategic/architectural forks, asking if something is worth building or keeping, or triaging multiple proposals/screenshots.
---
# Get More Perspectives (Advisory Panel, Evaluation & Triage)

Convenes a virtual panel of specialized advisors to stress-test decisions, render clear keep/drop viability verdicts, and triage multi-item request bundles with uncompromising clarity.

## When to Use

- **Advisory Panel (Strategic/Architectural Forks)**: Evaluating Flake migrations, Hjem vs. Home Manager trade-offs, curriculum architecture, or multi-repo design choices.
- **Evaluation Mode (Single Target Viability)**: Judging whether a single feature, tool, refactor, or product idea is worth building, commercializing, or keeping. (Route bug/error reports to `@hunt` before running any value judgment.)
- **Triage Mode (Batch Requests/Screenshots)**: Evaluating a bundle of independent requests, issues, or UI screenshots to decide which items to accept, defer, or reject.

> **Boundary with `@socratic`:** Once a direction passes viability/panel review here, hand off to `@socratic` for the concrete, zero-placeholder implementation plan.

## The Advisory Roster

1. **Operator (Execution & Feasibility)**: Maintenance drag, deployment ergonomics, day-100 operational reliability.
2. **Skeptic (Risk & Downside)**: Hidden assumptions, API instability, blast radius, and premise-collapse failure modes.
3. **Visionary (Opportunity & Leverage)**: Architectural elegance, 1-3 year strategic moats, and paradigm unlocks.
4. **Customer Advocate (User & Student Experience)**: Cognitive friction, accessibility, and genuine end-user/student value.
5. **Performance / Finance Mind (Numbers & ROI)**: Evaluation latency, memory footprint, quota/token cost, and time ROI.
6. **Optional Domain Advisors**: **Systems Architect** (DAG purity, `aarch64-darwin` vs. `aarch64-linux` parity) and **Security / Enclave Auditor** (secret hygiene, `age`/`rage` boundaries, privilege separation).

## Output Modes

### Mode A: Standard Panel & Single-Target Evaluation

Lead with the consensus vote, direct verdict (Build / Keep / Simplify / Drop), single non-negotiable condition, and primary fault line, followed by 2-4 crisp sentences per active advisor (no hedging):

PANEL REVIEW: [Decision or target in one sentence]

EXEC SUMMARY:
- Vote & Verdict: [X for, Y against, Z conditional — Build / Keep / Drop]
- Consensus: [One-sentence direct verdict]
- Core Condition: [Single non-negotiable prerequisite]
- Key Fault Line: [Primary tension, e.g., Operator drag vs. Visionary leverage]

- OPERATOR: [Execution and maintenance reality]
- SKEPTIC: [Concrete risk, premise fragility, or blast radius]
- VISIONARY: [Long-term leverage or dead-end warning]
- CUSTOMER ADVOCATE: [End-user or student cognitive impact]
- PERFORMANCE / FINANCE: [Quantitative latency, token, or time cost]

### Mode B: Batch Triage Table

When evaluating multiple independent proposals or screenshots, output a per-item decision table first rather than a single blended verdict:

| Item | Verdict (`Accept` / `Defer` / `Reject`) | Lead Advisor Rationale | Next Step / Owner |
| :--- | :--- | :--- | :--- |
| [Item 1] | ... | ... | ... |
