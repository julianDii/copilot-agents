# Security Policy

## Supported Versions

This repository contains Markdown configuration files and shell scripts — there is no versioned runtime. The latest commit on `main` is always the supported version.

| Version | Supported |
|---------|-----------|
| `main` (latest) | ✅ |
| Older branches | ❌ |

## Scope

This project distributes:

- GitHub Copilot agent instruction files (`.agent.md`, `.md`)
- A shell sync script (`sync-agents.sh`)
- Eval fixtures and snapshots

**In scope for security reports:**

- Shell script vulnerabilities (e.g. command injection, unsafe file operations, privilege escalation)
- Instructions that could cause Copilot to leak secrets, PII, or produce insecure code patterns
- Supply-chain issues (e.g. pinned tool versions with known CVEs in CI)

**Out of scope:**

- Vulnerabilities in GitHub Copilot itself — report those to [GitHub Security](https://github.com/github/feedback/discussions)
- Markdown content that is intentionally illustrative of bad patterns (eval fixtures)

## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

1. Go to the [Security Advisories](https://github.com/julianDii/copilot-agents/security/advisories/new) page and open a private advisory.
2. Include:
   - A clear description of the vulnerability
   - Steps to reproduce or a proof-of-concept
   - Potential impact
   - Suggested fix (if known)

You will receive an acknowledgement within **72 hours** and a resolution timeline within **7 days** for confirmed issues.

## Disclosure Policy

- Maintainers will confirm receipt and validate the report within 72 hours.
- A fix will be developed privately and released with a `CHANGELOG.md` entry.
- Credit will be given in the changelog and release notes unless you prefer to remain anonymous.
- Public disclosure will be coordinated with the reporter.
