# Changelog

All notable changes to this project are documented here.
Format: [Semantic Versioning](https://semver.org) — `MAJOR.MINOR.PATCH`

- **MAJOR** — breaking change to agent behaviour, instruction contract, or sync script interface
- **MINOR** — new agent, new fixture set, new instruction section, new script feature
- **PATCH** — bug fix, wording improvement, snapshot update, non-breaking tweak

---

## [2.2.1] — 2026-03-05

### Fixed

- `feature-lifecycle.agent.md` — Enhanced flow metrics table examples to explicitly show
  `(created → RELEASED)` format in metric column headers, preventing confusion with deprecated
  `(created → resolved)` pattern. Added CRITICAL note emphasizing RELEASED vs resolved distinction.
- Lifecycle analyses: Fixed lead time metric in 6 existing analyses (EVT-4230, EVT-4521, EVT-4640,
  EVT-4924, EVT-4984, EVT-5214) to use `created → RELEASED` instead of `created → resolved`.
- Added comprehensive flow metrics table template in output format section with explicit column
  headers and IMPORTANT note for future consistency.

---

## [2.2.0] — 2026-03-05

### Added

- `feature-lifecycle.agent.md` — Feature lifecycle analysis agent: comprehensive flow metrics
  (lead time, cycle time, refinement lag), bottleneck identification, team dynamics, AI impact,
  and post-release adoption via Pendo. Uses Jira, Confluence, and Pendo MCP servers.
- Size-based targets: 10-14 days (small), 14-21 (medium), 21-28 (large) working days.
- Working day calculations excluding weekends and Dec 21-Jan 6 holiday period.
- Historical data from 7 analyzed features (Oct 2025 - Feb 2026).

### Fixed

- Lead time calculation: now uses RELEASED date (from release history) instead of resolutiondate,
  aligning with DORA definition and preventing systematic understatement of time-to-customer.
- Added fallback logic with warning flag when RELEASED date is unavailable.

---

## [2.1.0] — 2026-02-22

### Added

- `git.agent.md` — Git workflow agent: commit messages, branch strategy, rebase/merge, history
  clean-up, conflict resolution, and PR hygiene using Conventional Commits.
- `PROMPTS.md`: git agent section with 8 ready-to-use prompts and Git reference links.
- `README.md`: git agent entry in the Agents table.

---

## [2.0.1] — 2026-02-22

### Fixed

- `PROMPTS.md`: MD001 (h3 under h1 → h2), MD036 (bold labels → proper headings),
  MD031/MD040 (blank lines around fences + `text` language), MD034 (bare URLs → angle-bracket URLs),
  MD012 (trailing blank lines)
- `instructions/global-copilot-instructions.md`: MD032 (blank lines around lists),
  MD031/MD040 (fenced code block language + surrounding blank lines)
- `README.md`: MD040 (diagram blocks tagged as `text`), MD032 (blank line before lists),
  MD012 (trailing blank lines)
- `.markdownlint.json`: restored minimal config — only MD013/MD033/MD041/MD024 disabled
  (rules genuinely inapplicable to this repo's content)
- CI lint job now enforces real standards rather than suppressing rules

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
