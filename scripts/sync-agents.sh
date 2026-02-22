#!/usr/bin/env bash
# sync-agents.sh
# Single source of truth: instructions/global-copilot-instructions.md
# Agent source:           .github/agents/*.agent.md  (JetBrains tool names)
#
# --global  → deploys instructions to ~/.config/github-copilot/intellij/  (JetBrains, all projects)
#           → also updates .github/copilot-instructions.md    (per-repo fallback)
# <path>    → installs instructions + agents into a specific project repo
#             Generates both JetBrains and VS Code variants of each agent

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
AGENTS_SRC="${REPO_ROOT}/.github/agents"
SOURCE="${REPO_ROOT}/instructions/global-copilot-instructions.md"
ARG="${1:-}"

log() { echo "[sync-agents] $*"; }
err() { echo "[sync-agents] ERROR: $*" >&2; exit 1; }

# ── Rewrite tools: line from JetBrains → VS Code format ───────────────────────
# JetBrains: tools: ['read_file', 'semantic_search', 'grep_search', 'file_search', 'list_dir', 'get_errors']
# VS Code:   tools: [codebase, problems]
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
  $0 --global              Deploy instructions globally (JetBrains) + update .github/ in this repo
                           Source: instructions/global-copilot-instructions.md
                           → ~/.config/github-copilot/intellij/global-copilot-instructions.md
                           → .github/copilot-instructions.md

  $0 <target-repo-root>    Install instructions + agents into another project
                           → <target>/.github/copilot-instructions.md
                           → <target>/.github/agents/<name>.agent.md          (JetBrains)
                           → <target>/.github/agents/<name>.vscode.agent.md   (VS Code)
                           Note: evals/ is NOT copied — it is a QA tool for this repo only.

Examples:
  $0 --global
  $0 ~/IdeaProjects/my-django-app
EOF
  exit 1
}

[[ -z "${ARG}" ]] && usage
[[ -f "${SOURCE}" ]] || err "Source file not found: ${SOURCE}"

# ── Global mode ────────────────────────────────────────────────────────────────
if [[ "${ARG}" == "--global" ]]; then
  JETBRAINS_DIR="${HOME}/.config/github-copilot/intellij"
  GLOBAL_DEST="${JETBRAINS_DIR}/global-copilot-instructions.md"
  mkdir -p "${JETBRAINS_DIR}"

  if [[ -f "${GLOBAL_DEST}" ]] && ! diff -q "${SOURCE}" "${GLOBAL_DEST}" &>/dev/null; then
    BACKUP="${GLOBAL_DEST}.backup-$(date +%Y%m%d%H%M%S)"
    log "⚠ Existing global instructions differ from source."
    log "  Backing up existing file → ${BACKUP}"
    cp "${GLOBAL_DEST}" "${BACKUP}"
    log ""
    log "  If you had custom content in the old file, merge it into:"
    log "  ${SOURCE}"
    log "  then re-run this script."
    log ""
  fi

  cp "${SOURCE}" "${GLOBAL_DEST}"
  log "✔ JetBrains global → ${GLOBAL_DEST}"

  REPO_DEST="${REPO_ROOT}/.github/copilot-instructions.md"
  mkdir -p "${REPO_ROOT}/.github"
  if [[ -f "${REPO_DEST}" ]] && ! diff -q "${SOURCE}" "${REPO_DEST}" &>/dev/null; then
    BACKUP="${REPO_DEST}.backup-$(date +%Y%m%d%H%M%S)"
    log "⚠ Existing .github/copilot-instructions.md differs from source — backing up → ${BACKUP}"
    cp "${REPO_DEST}" "${BACKUP}"
  fi
  cp "${SOURCE}" "${REPO_DEST}"
  log "✔ Per-repo fallback → ${REPO_DEST}"

  log "Done. Restart your JetBrains IDE to pick up any changes."
  exit 0
fi

# ── Per-repo mode ──────────────────────────────────────────────────────────────
TARGET_DIR="${ARG}"
[[ -d "${AGENTS_SRC}" ]] || err "Agents directory not found: ${AGENTS_SRC}"

PERREPO_DEST="${TARGET_DIR}/.github/copilot-instructions.md"
mkdir -p "${TARGET_DIR}/.github"
if [[ -f "${PERREPO_DEST}" ]] && ! diff -q "${SOURCE}" "${PERREPO_DEST}" &>/dev/null; then
  BACKUP="${PERREPO_DEST}.backup-$(date +%Y%m%d%H%M%S)"
  log "⚠ Existing .github/copilot-instructions.md in target differs — backing up → ${BACKUP}"
  cp "${PERREPO_DEST}" "${BACKUP}"
fi
cp "${SOURCE}" "${PERREPO_DEST}"
log "✔ Copied .github/copilot-instructions.md → ${TARGET_DIR}/.github/"

TARGET_AGENTS_DIR="${TARGET_DIR}/.github/agents"
mkdir -p "${TARGET_AGENTS_DIR}"
count=0
for agent_file in "${AGENTS_SRC}"/*.agent.md; do
  [[ -f "${agent_file}" ]] || continue
  filename="$(basename "${agent_file}")"
  [[ "${filename}" == "example.agent.md" ]] && continue

  # JetBrains variant (source as-is)
  cp "${agent_file}" "${TARGET_AGENTS_DIR}/${filename}"
  log "✔ JetBrains → .github/agents/${filename}"

  # VS Code variant (rewritten tools: line)
  base="${filename%.agent.md}"
  vscode_filename="${base}.vscode.agent.md"
  make_vscode_variant "${agent_file}" "${TARGET_AGENTS_DIR}/${vscode_filename}"
  log "✔ VS Code  → .github/agents/${vscode_filename}"

  ((count++))
done

[[ ${count} -eq 0 ]] && log "No *.agent.md files found." || log "Done. ${count} agent(s) synced (JetBrains + VS Code variants) to '${TARGET_DIR}'."
