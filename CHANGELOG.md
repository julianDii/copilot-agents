# Changelog

All notable changes to this project are documented here.
Format: [Semantic Versioning](https://semver.org) — `MAJOR.MINOR.PATCH`

- **MAJOR** — breaking change to agent behaviour, instruction contract, or sync script interface
- **MINOR** — new agent, new fixture set, new instruction section, new script feature
- **PATCH** — bug fix, wording improvement, snapshot update, non-breaking tweak

---

## [2.0.0] — 2026-02-22

### Added
- `evals/` directory — fixtures, rubric, and snapshot baseline for all three agents
  - 4 general fixtures (`bare_except`, `eval_usage`, `no_issues`, `missing_timeout`)
  - 6 Django fixtures (`n_plus_one`, `idor_view`, `migration_not_null`, `signal_business_logic`, `debug_settings`, `csrf_exempt`)
  - 6 React/TS fixtures (`stale_closure`, `xss_risk`, `missing_abort`, `unstable_key`, `unsafe_assertion`, `no_issues`)
  - 17 baseline snapshots — all fixtures scored 7–8/8
- Dual-IDE agent generation — `sync-agents.sh` now produces JetBrains + VS Code variants on deploy
- Tools Reference section in README — full table of valid tool names for both IDEs
- `Providing context for review` section in README
- PROMPTS.md — ready-to-use prompts for all agents and all 9 instruction sections
- `EVALS.md` VERSION tracking + Snapshot + Last score columns

### Changed
- All three agents revised against community standards (`awesome-copilot`, `cursor.directory`)
  - `code-review`: restructured (scope first, bold lenses, Never block, severity calibration)
  - `django-review`: added settings/config (Blocker), migration safety, signals, Celery, rate limiting, ❌/✅ examples
  - `react-ts-review`: added Server/Client boundary, `useEffect` anti-pattern, ErrorBoundary, `strictNullChecks`, controlled inputs, ❌/✅ examples
- `tools: []` → `tools: ['read_file', 'semantic_search', 'grep_search', 'file_search', 'list_dir', 'get_errors']` on all agents
- Inline `# Docs:` URL comments removed from agent bodies (model can't fetch them — noise)
- References tables moved from agent files to `PROMPTS.md`
- `sync-agents.sh` usage clarified: `evals/` explicitly not copied to target projects

### Fixed
- Markdown linter warning: numbered list continuity in `code-review.agent.md`
- Stale `tools: [codebase]` reference in README (VS Code-only name, invalid in JetBrains)

---

## [1.2.0] — 2026-02-15

### Added
- `react-ts-review.agent.md` — React + TypeScript specialist review agent
- `django-review.agent.md` — Django/DRF specialist review agent
- `PROMPTS.md` — initial prompt guide
- `.gitignore`

### Changed
- `sync-agents.sh` — added per-repo deployment mode with backup guards

---

## [1.1.0] — 2026-02-10

### Added
- `code-review.agent.md` — general code review agent
- `scripts/sync-agents.sh` — deploy script with `--global` mode
- `.vscode/settings.json` — wires instructions for VS Code

---

## [1.0.0] — 2026-02-01

### Added
- `instructions/global-copilot-instructions.md` — 9-section global instruction file
- `README.md` — setup and usage documentation
- `VERSION`

