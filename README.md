# Agent Zero Trust

Security controls for AI agents that hold even when the model is fooled.

A system prompt that says "never reveal pricing" can be talked around. Agent Zero Trust (AZT) moves those limits out of the model and into the systems the agent uses: an identity check before the agent starts, a proxy that checks every request, and the data platform's own access rules. This repository holds the specification, the conformance tests, and implementations for different platforms.

Background: [Your AI Agent's System Prompt Is Not a Security Control](https://medium.com/@dappilig/your-ai-agents-system-prompt-is-not-a-security-control-f60bc8769712)

## The problem

More and more agents run with no person reviewing each action. A sensor reading, a queue message, or a schedule starts them. Many are given a broad service account and told in the prompt what not to do.

Two risks make that unsafe:

- **Prompt injection** (OWASP LLM01:2025). Any text the agent reads can override its instructions.
- **Excessive agency** (OWASP LLM06:2025). An agent with broad credentials can act beyond what anyone approved, and with nobody watching, the action runs before anyone notices.

## The pattern

AZT applies the zero trust split in NIST SP 800-207, between a policy decision point and a policy enforcement point, to AI agents.

![Every agent request passes an enforcement layer outside the model](docs/architecture.png)

1. **Gateway (decides).** Confirms which agent is running, screens the trigger, and issues a short lived token listing what this one task may do: which models, which data, which actions.
2. **Sidecar (enforces).** A proxy beside each agent checks every request against the token at three layers:
   - **Data:** the data store applies row and column rules keyed to the task, so restricted values never reach the model.
   - **Model:** the agent may call only the models its task allows.
   - **Action:** writes and tool calls are checked, and actions above a set impact go to a person for approval.
3. **Audit.** One correlation ID links the trigger, the token, the data read, the model call, and the action.

Some platforms provide parts of this natively. Snowflake, for example, knows when an agent is acting and lets policies check that directly, so enforcement happens inside the database. Each implementation folder explains how the pattern maps to that platform.

## Implementations

| Platform | Folder | Status |
| --- | --- | --- |
| Snowflake (Cortex Agents) | [snowflake](snowflake/) | Available: setup, 18 tests, cleanup |
| PostgreSQL, Open Policy Agent, sidecar proxy | postgres (planned) | In progress |

## Specification

[SPEC.md](SPEC.md) defines the controls any implementation must meet. Each control has a requirement, the reason for it, the OWASP risk it addresses, and a test.

Draft control list:

| ID | Control | Layer |
| --- | --- | --- |
| AZT-G1 | Verify the agent's identity before it starts | Gateway |
| AZT-G2 | Screen trigger input for injection attempts | Gateway |
| AZT-G3 | Issue a short lived token scoped to one task | Gateway |
| AZT-D1 | Give each agent its own least privilege identity | Data |
| AZT-D2 | Mask every copy of a sensitive value, not only the main one | Data |
| AZT-D3 | Enforce row scope inside the data store | Data |
| AZT-D4 | Redact restricted text before it is indexed for search | Data |
| AZT-D5 | Limit the objects the agent can query through a scoped semantic layer | Data |
| AZT-M1 | Allow only approved models for each agent or task | Model |
| AZT-M2 | Screen model inputs and outputs | Model |
| AZT-A1 | Route agent writes through a controlled procedure, never directly | Action |
| AZT-A2 | Require approval above a set impact threshold | Action |
| AZT-A3 | Take sensitive values such as prices from the system, not from the agent | Action |
| AZT-A4 | Cap the privileges of any session where an agent is active | Action |
| AZT-L1 | Record agent activity separately from human activity | Audit |
| AZT-L2 | Trace every action back to its trigger and the data it read | Audit |

## Conformance tests

The tests in each implementation try to break the controls: prompt injection, reading a price through a second table, querying out of scope, calling a blocked model, writing directly, and passing an expired or altered token. Each test names the control ID it checks, so you can run the suite against your own deployment and see which controls hold.

## How this maps to the OWASP Top 10 for LLM Applications 2025

| Risk | AZT controls |
| --- | --- |
| LLM01 Prompt Injection | G2, D1, D5, M2 |
| LLM02 Sensitive Information Disclosure | D2, D3 |
| LLM05 Improper Output Handling | A1, A3 |
| LLM06 Excessive Agency | G3, A1, A2, A4 |
| LLM08 Vector and Embedding Weaknesses | D4 |
| LLM10 Unbounded Consumption | A4, plus rate limits in the sidecar |

## What this does not solve

- It limits what an agent can reach. It does not stop an agent from misusing data it is allowed to see.
- It does not fix wrong answers inside the agent's scope.
- Approval thresholds need tuning for each business.
- A sidecar adds a network hop to each call. Measure it against your model latency.

## Roadmap

- v0.1: specification draft, Snowflake implementation, PostgreSQL implementation with gateway and sidecar
- v0.2: Kubernetes deployment, outside review of the specification
- Later: more platforms, published test results

## Contributing

Issues and pull requests are welcome, especially:
- ways around a control,
- implementations for other platforms,
- new test scenarios.

If you run the tests against your own setup, please open an issue with what you found, even if everything passed.

## License

Apache License 2.0. See [LICENSE](LICENSE).

## Author

Gopinadha Dappili
