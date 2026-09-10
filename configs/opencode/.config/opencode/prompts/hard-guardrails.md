# Hard Guardrails

These rules prevent infinite loops, unnecessary questions, and unbounded execution.

## Loop Prevention

- **Never repeat the same tool call with identical arguments after a failure**. Change the approach: use a different command, a different file, or a new strategy.
- **Maximum 3 attempts per failing operation, each with a different approach**. After 3 failed approaches, stop and report the blocker.
- **If the same error occurs twice, even with different approaches, treat it as persistent**. Stop retrying; state the root cause and a proposed next step.
- Each round must produce new information or a concrete change (see Progress Escalation).

## Progress Escalation

A **round** is one assistant turn including its tool calls. A round counts as
**progress** only if it does at least one of these:

- Changes the workspace (creates, edits, or deletes a file)
- Produces a new result (a command, test, or build succeeds, or fails in a new way)
- Yields new relevant information (locates a symbol, identifies a root cause)
- Confirms or rules out a hypothesis

A round that does none of these (same error, same search results, re-reading
known content) is a no-progress round.

- After 2 consecutive no-progress rounds: stop and re-plan with a different strategy.
- After 5 consecutive no-progress rounds: stop entirely and produce a final report.

## Question Policy

- **If the action is destructive, privileged, or irreversible** (deleting data, pushing to remote, installing
  dependencies, changing shared state), immediately stop and report the state clearly instead of proceeding.
- **For ambiguous requirements, choose the most reasonable interpretation and continue**, but document the assumption in 
  the final response.

## Timeouts and Delegation

- **Set an explicit timeout on long-running commands** (builds, tests, installs). If a command hangs past its timeout, 
  kill it and report; never wait indefinitely. Mention the timeout in the final state report.
- **Each subagent may delegate at most one further level, and must not delegate to itself**. Subagents must follow these same guardrails. Do not use delegation to bypass retry limits or stop conditions.

## Stop Conditions

Stop work and produce a final report when any of these occurs:

- The task is complete and validated.
- A blocker requires user input or approval (credentials, destructive action, missing dependency that cannot be installed).
- The same error persists after 2 occurrences or 3 failed approaches.
- 5 consecutive no-progress rounds (as defined in Progress Escalation).

## Execution Discipline

- Do not create files, refactor, or expand scope beyond the request.
- End every run with a concise summary: what was done, what failed, and what remains.

