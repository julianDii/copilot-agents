# Contributing to copilot-agents

Thank you for your interest in contributing! This is a collection of GitHub Copilot agent configurations and global instructions for the full SDLC.

---

## Ways to Contribute

- **New agents** — specialist `.agent.md` files for additional domains (e.g. `terraform-review`, `security-review`)
- **New instructions** — additional global instruction files covering new SDLC phases
- **Eval fixtures & snapshots** — expand the test suite with new edge cases
- **Bug fixes** — CI, script, or documentation issues
- **Documentation** — README, PROMPTS.md, or inline improvements

---

## Getting Started

```bash
git clone https://github.com/julianDii/copilot-agents.git
cd copilot-agents
```

No runtime dependencies — all content is Markdown and shell scripts.

---

## Branch Naming

Follow the Conventional Commits branch pattern:

```text
<type>/<short-description>
```

Examples: `feat/terraform-agent`, `fix/sync-script-backup`, `docs/contributing-guide`

---

## Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

```text
<type>(<scope>): <short summary>
```

Types: `feat` | `fix` | `chore` | `docs` | `test` | `refactor` | `perf` | `ci`

Example: `feat(agents): add terraform-review agent`

---

## Pull Request Checklist

Before opening a PR, ensure:

- [ ] Branch is off `main` and up to date
- [ ] Commit messages follow Conventional Commits
- [ ] `VERSION` is bumped if any agent or instruction file changed
- [ ] `CHANGELOG.md` has an entry for your change
- [ ] Markdown passes lint: `npx markdownlint-cli@0.39.0 "**/*.md" --ignore node_modules --ignore ".github/copilot-instructions.md" --ignore "evals/snapshots/**" --config .markdownlint.json`
- [ ] New agents include: `description`, `tools`, and at least one eval fixture + snapshot
- [ ] CI passes (lint, snapshots, agents, version checks)

---

## Adding a New Agent

1. Create `agents/<name>.agent.md` with valid frontmatter:

   ```yaml
   ---
   description: <one-line description of when Copilot should use this agent>
   tools:
     - codebase
     - <other tools>
   ---
   ```

2. Add at least one fixture under `evals/fixtures/<domain>/`
3. Add the corresponding baseline snapshot under `evals/snapshots/`
4. Run `./scripts/sync-agents.sh --dry-run` to verify sync behaviour
5. Bump `VERSION` and add a `CHANGELOG.md` entry

---

## Lint

```bash
npx markdownlint-cli@0.39.0 "**/*.md" \
  --ignore node_modules \
  --ignore ".github/copilot-instructions.md" \
  --ignore "evals/snapshots/**" \
  --config .markdownlint.json
```

---

## Code of Conduct

All contributors are expected to follow our [Code of Conduct](CODE_OF_CONDUCT.md).

---

## Questions?

Open a [GitHub Discussion](https://github.com/julianDii/copilot-agents/discussions) or file an issue.
