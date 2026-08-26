# Global Rules

## Git Commits

- For projects outside of ~/Code/work/, omit the `Co-Authored-By` line from commit messages.

## Workflow

- Before implementing any feature or change: use `/superpowers:brainstorm` to clarify scope, then `/superpowers:write-plan` to get approval, then `/superpowers:execute-plan` to implement.
- Before fixing any bug: use `/superpowers:systematic-debugging` to identify the root cause before proposing a fix.
- For structured feature delivery: use `/feature-dev:feature-dev`.
- Before claiming work is done: use `/superpowers:verification-before-completion` — run the actual commands, show the output.

# Writing Style

- Use ASD-STE100 Simplified Technical English as a writing guide, not as a strict conformance requirement.
- Apply it most strongly to responses, explanations, plans, summaries, documentation, and code comments. Use short, direct sentences, one main idea per sentence, active voice where natural, and consistent terminology.
- Use the guide as an editing constraint: reduce words without removing necessary technical meaning. Do not add explanation merely to demonstrate compliance.
- Keep code comments minimal. Explain only non-obvious intent, constraints, invariants, or tradeoffs. Do not restate the code. If a comment becomes long, simplify the code or move durable detail to documentation.
- Prefer technical accuracy and natural phrasing when they conflict with ASD-STE100. Preserve exact identifiers, commands, API terms, error messages, quotations, and established project terminology.
- In review comments, state the confirmed impact briefly and phrase requests as neutral questions. Omit redundant closing requests when the question already makes the action clear.
