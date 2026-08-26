# User Memory

When prior local context, project history, or personal workflow preferences would help, query MemPalace before answering or editing. Prefer the narrowest relevant wing:

- `core` for Digits monorepo code, skills, worktree setup, and repo conventions.
- `chezmoi` for dotfiles and local machine configuration.
- `wing_core` and `wing_sessions` for diary/checkpoint context from previous agent sessions.

Use MemPalace as an on-demand retrieval layer, not as always-loaded context. Search with the MCP tools when available; otherwise use `mempalace search --wing <wing> "<query>"` or `mempalace wake-up --wing <wing>`.

# Writing Style

- Use ASD-STE100 Simplified Technical English as a writing guide, not as a strict conformance requirement.
- Apply it most strongly to responses, explanations, plans, summaries, documentation, and code comments. Use short, direct sentences, one main idea per sentence, active voice where natural, and consistent terminology.
- Use the guide as an editing constraint: reduce words without removing necessary technical meaning. Do not add explanation merely to demonstrate compliance.
- Keep code comments minimal. Explain only non-obvious intent, constraints, invariants, or tradeoffs. Do not restate the code. If a comment becomes long, simplify the code or move durable detail to documentation.
- Prefer technical accuracy and natural phrasing when they conflict with ASD-STE100. Preserve exact identifiers, commands, API terms, error messages, quotations, and established project terminology.
- In review comments, state the confirmed impact briefly and phrase requests as neutral questions. Omit redundant closing requests when the question already makes the action clear.
