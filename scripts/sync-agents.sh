#!/usr/bin/env bash
# sync-agents.sh
# Single source of truth: instructions/global-copilot-instructions.md
# Agent source:           .github/agents/*.agent.md  (JetBrains tool names)
#
# --global            → deploys instructions to ~/.config/github-copilot/intellij/  (JetBrains, all projects)
#                       also updates .github/copilot-instructions.md (per-repo fallback)
# <path>              → installs instructions + agents into a specific project repo
#                       generates both JetBrains and VS Code variants of each agent
# --dry-run           → preview what would be copied/overwritten without touching anything
#                       combine with --global or <path>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
AGENTS_SRC="${REPO_ROOT}/.github/agents"
SOURCE="${REPO_ROOT}/instructions/global-copilot-instructions.md"

# ── Argument parsing ───────────────────────────────────────────────────────────
ARG=""
DRY_RUN=false
for a in "$@"; do
  case "$a" in
    --dry-run) DRY_RUN=true ;;
    *) ARG="$a" ;;
  esac
done

log()     { echo "[sync-agents] $*"; }
err()     { echo "[sync-agents] ERROR: $*" >&2; exit 1; }
drylog()  { echo "[sync-agents] (dry-run) $*"; }

# Safe wrappers — no-op when DRY_RUN=true
safe_mkdir() {
  if $DRY_RUN; then drylog "mkdir -p $1"; else mkdir -p "$1"; fi
}
safe_cp() {
  local src="$1" dest="$2" label="${3:-}"
  if $DRY_RUN; then
    if [[ -f "${dest}" ]]; then
      if diff -q "${src}" "${dest}" &>/dev/null; then
        drylog "no change   → ${dest}"
      else
        drylog "overwrite   → ${dest}${label:+  ($label)}"
      fi
    else
      drylog "create      → ${dest}"
    fi
  else
    cp "${src}" "${dest}"
  fi
}
safe_sed_cp() {
  local src="$1" dest="$2"
  if $DRY_RUN; then
    drylog "create      → ${dest}  (VS Code variant)"
  else
    make_vscode_variant "${src}" "${dest}"
  fi
}

# ── Rewrite tools: line from JetBrains → VS Code format ───────────────────────
make_vscode_variant() {
  local src="$1"
  local dest="$2"
  sed \
    -e "s/tools: \[.*'read_file'.*'list_dir'.*'get_errors'.*\]/tools: [codebase, problems]/" \
    -e "s/tools: \[.*'read_file'.*'list_dir'.*\]/tools: [codebase]/" \
    -e "s/tools: \[.*'run_in_terminal'.*\]/tools: [codebase, problems, terminal]/" \
    "${src}" > "${dest}"
}

usage() {
  cat <<EOF
Usage:
  $0 --global [--dry-run]          Deploy instructions globally (JetBrains) + update .github/ in this repo
                                    Source: instructions/global-copilot-instructions.md
                                    → ~/.config/github-copilot/intellij/global-copilot-instructions.md
                                    → .github/copilot-instructions.md

  $0 <target-repo-root> [--dry-run] Install instructions + agents into another project
                                    → <target>/.github/copilot-instructions.md
                                    → <target>/.github/agents/<name>.agent.md          (JetBrains)
                                    → <target>/.github/agents/<name>.vscode.agent.md   (VS Code)
                                    Note: evals/ is NOT copied — it is a QA tool for this repo only.

  --dry-run                         Preview what would be copied/overwritten. No files are modified.

Examples:
  $0 --global
  $0 --global --dry-run
  $0 ~/IdeaProjects/my-django-app
  $0 ~/IdeaProjects/my-django-app --dry-run
EOF
  exit 1
}

[[ -z "${ARG}" ]] && usage
[[ -f "${SOURCE}" ]] || err "Source file not found: ${SOURCE}"

$DRY_RUN && log "Dry-run mode — no files will be modified."

# ── Global mode ────────────────────────────────────────────────────────────────
if [[ "${ARG}" == "--global" ]]; then
  JETBRAINS_DIR="${HOME}/.config/github-copilot/intellij"
  GLOBAL_DEST="${JETBRAINS_DIR}/global-copilot-instructions.md"
  safe_mkdir "${JETBRAINS_DIR}"

  if [[ -f "${GLOBAL_DEST}" ]] && ! diff -q "${SOURCE}" "${GLOBAL_DEST}" &>/dev/null; then
    BACKUP="${GLOBAL_DEST}.backup-$(date +%Y%m%d%H%M%S)"
    if $DRY_RUN; then
      drylog "⚠ existing global instructions differ — would backup → ${BACKUP}"
    else
      log "⚠ Existing global instructions differ from source."
      log "  Backing up existing file → ${BACKUP}"
      cp "${GLOBAL_DEST}" "${BACKUP}"
      log "  If you had custom content, merge it into:"
      log "  ${SOURCE}"
      log "  then re-run this script."
    fi
  fi

  safe_cp "${SOURCE}" "${GLOBAL_DEST}" "JetBrains global"
  $DRY_RUN || log "✔ JetBrains global → ${GLOBAL_DEST}"

  REPO_DEST="${REPO_ROOT}/.github/copilot-instructions.md"
  safe_mkdir "${REPO_ROOT}/.github"
  if [[ -f "${REPO_DEST}" ]] && ! diff -q "${SOURCE}" "${REPO_DEST}" &>/dev/null; then
    BACKUP="${REPO_DEST}.backup-$(date +%Y%m%d%H%M%S)"
    $DRY_RUN || { log "⚠ Existing .github/copilot-instructions.md differs — backing up → ${BACKUP}"; cp "${REPO_DEST}" "${BACKUP}"; }
    $DRY_RUN && drylog "⚠ existing .github/copilot-instructions.md differs — would backup → ${BACKUP}"
  fi
  safe_cp "${SOURCE}" "${REPO_DEST}" "per-repo fallback"
  $DRY_RUN || log "✔ Per-repo fallback → ${REPO_DEST}"

  if $DRY_RUN; then
    log "Dry-run complete. Run without --dry-run to apply."
  else
    log "Done. Restart your JetBrains IDE to pick up any changes."
  fi
  exit 0
fi

# ── Per-repo mode ──────────────────────────────────────────────────────────────
TARGET_DIR="${ARG}"
[[ -d "${TARGET_DIR}" ]] || err "Target directory not found: ${TARGET_DIR}"
[[ -d "${AGENTS_SRC}" ]] || err "Agents directory not found: ${AGENTS_SRC}"

PERREPO_DEST="${TARGET_DIR}/.github/copilot-instructions.md"
safe_mkdir "${TARGET_DIR}/.github"
if [[ -f "${PERREPO_DEST}" ]] && ! diff -q "${SOURCE}" "${PERREPO_DEST}" &>/dev/null; then
  BACKUP="${PERREPO_DEST}.backup-$(date +%Y%m%d%H%M%S)"
  if $DRY_RUN; then
    drylog "⚠ existing copilot-instructions.md differs — would backup → ${BACKUP}"
  else
    log "⚠ Existing .github/copilot-instructions.md in target differs — backing up → ${BACKUP}"
    cp "${PERREPO_DEST}" "${BACKUP}"
  fi
fi
safe_cp "${SOURCE}" "${PERREPO_DEST}"
$DRY_RUN || log "✔ Copied .github/copilot-instructions.md → ${TARGET_DIR}/.github/"

TARGET_AGENTS_DIR="${TARGET_DIR}/.github/agents"
safe_mkdir "${TARGET_AGENTS_DIR}"
count=0
for agent_file in "${AGENTS_SRC}"/*.agent.md; do
  [[ -f "${agent_file}" ]] || continue
  filename="$(basename "${agent_file}")"
  [[ "${filename}" == "example.agent.md" ]] && continue

  safe_cp "${agent_file}" "${TARGET_AGENTS_DIR}/${filename}"
  $DRY_RUN || log "✔ JetBrains → .github/agents/${filename}"

  base="${filename%.agent.md}"
  vscode_filename="${base}.vscode.agent.md"
  safe_sed_cp "${agent_file}" "${TARGET_AGENTS_DIR}/${vscode_filename}"
  $DRY_RUN || log "✔ VS Code  → .github/agents/${vscode_filename}"

  ((count++))
done

if $DRY_RUN; then
  log "Dry-run complete — ${count} agent(s) would be synced. Run without --dry-run to apply."
else
  [[ ${count} -eq 0 ]] && log "No *.agent.md files found." || log "Done. ${count} agent(s) synced (JetBrains + VS Code variants) to '${TARGET_DIR}'."
fi
