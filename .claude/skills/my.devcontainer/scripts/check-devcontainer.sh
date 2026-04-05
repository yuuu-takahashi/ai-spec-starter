#!/usr/bin/env bash
set -euo pipefail

# Usage: check-devcontainer.sh [workspace-folder]
# Default workspace is the current directory (after cd, same as ".")
WORKDIR="${1:-.}"
cd "$WORKDIR" || {
  echo "ERROR: cannot cd to workspace: $WORKDIR"
  exit 1
}

echo "==> Workspace: $(pwd)"

echo "==> Check .devcontainer exists"
if [[ ! -d ".devcontainer" ]]; then
  echo "ERROR: .devcontainer directory not found in $WORKDIR"
  exit 1
fi

echo "==> Check devcontainer CLI"
if ! command -v devcontainer >/dev/null 2>&1; then
  if [[ "${DC_SKIP_CLI_INSTALL:-}" == "1" ]]; then
    echo "ERROR: devcontainer CLI not found (DC_SKIP_CLI_INSTALL=1 — auto-install skipped)"
    echo "Install: npm install -g @devcontainers/cli"
    exit 1
  fi
  if command -v npm >/dev/null 2>&1; then
    echo "==> Installing @devcontainers/cli globally (npm install -g)"
    npm install -g @devcontainers/cli
  else
    echo "ERROR: devcontainer CLI not found and npm is not available"
    echo "Install Node.js, then: npm install -g @devcontainers/cli"
    exit 1
  fi
  if ! command -v devcontainer >/dev/null 2>&1; then
    echo "ERROR: devcontainer still not on PATH after npm install -g"
    echo "Add npm's global bin directory to PATH, or open a new terminal."
    exit 1
  fi
fi

echo "==> Build devcontainer"
devcontainer build --workspace-folder .

echo "==> Up devcontainer"
devcontainer up --workspace-folder .

echo "==> Basic exec check"
devcontainer exec --workspace-folder . bash -lc 'pwd && whoami && ls' || {
  echo "WARN: bash exec failed; retrying with sh -lc"
  devcontainer exec --workspace-folder . sh -lc 'pwd && whoami && ls'
}

echo "==> Node check"
devcontainer exec --workspace-folder . bash -lc 'node -v 2>/dev/null || true; npm -v 2>/dev/null || true; yarn -v 2>/dev/null || true; pnpm -v 2>/dev/null || true' || true

echo "==> Ruby check"
devcontainer exec --workspace-folder . bash -lc 'ruby -v 2>/dev/null || true; bundle -v 2>/dev/null || true' || true

# --- gh CLI & authentication ---
echo "==> gh CLI check"
if devcontainer exec --workspace-folder . bash -lc 'command -v gh >/dev/null 2>&1'; then
  echo "  gh found: $(devcontainer exec --workspace-folder . bash -lc 'gh --version 2>/dev/null | head -1')"
  echo "==> gh auth check"
  if devcontainer exec --workspace-folder . bash -lc 'gh auth status 2>&1'; then
    echo "  gh auth: OK"
  else
    echo "  WARN: gh is installed but not authenticated (gh auth status failed)"
    echo "  Check credential mounts, GH_TOKEN env, or gh auth login inside the container"
  fi
else
  echo "  WARN: gh CLI not found in container"
fi

# --- claude CLI ---
echo "==> claude CLI check"
if devcontainer exec --workspace-folder . bash -lc 'command -v claude >/dev/null 2>&1'; then
  echo "  claude found: $(devcontainer exec --workspace-folder . bash -lc 'claude --version 2>/dev/null | head -1' || echo '(version unknown)')"
else
  echo "  WARN: claude CLI not found in container"
fi

# --- Lifecycle commands (postCreateCommand / postStartCommand) ---
echo "==> Lifecycle command verification"
# Parse postCreateCommand and postStartCommand from devcontainer.json
DEVCONTAINER_JSON=".devcontainer/devcontainer.json"
if [[ -f "$DEVCONTAINER_JSON" ]]; then
  # Extract commands using jq (installed in container; also available on most hosts)
  # Strip comments from JSON-with-comments before parsing
  POST_CREATE=$(sed 's|//.*$||' "$DEVCONTAINER_JSON" | jq -r '.postCreateCommand // empty' 2>/dev/null || true)
  POST_START=$(sed 's|//.*$||' "$DEVCONTAINER_JSON" | jq -r '.postStartCommand // empty' 2>/dev/null || true)

  if [[ -n "$POST_CREATE" ]]; then
    echo "==> Re-run postCreateCommand: $POST_CREATE"
    if devcontainer exec --workspace-folder . bash -lc "$POST_CREATE"; then
      echo "  postCreateCommand: OK"
    else
      echo "  ERROR: postCreateCommand failed (exit $?)"
      echo "  Command was: $POST_CREATE"
    fi
  else
    echo "  (no postCreateCommand found)"
  fi

  if [[ -n "$POST_START" ]]; then
    echo "==> Re-run postStartCommand: $POST_START"
    if devcontainer exec --workspace-folder . bash -lc "$POST_START"; then
      echo "  postStartCommand: OK"
    else
      echo "  ERROR: postStartCommand failed (exit $?)"
      echo "  Command was: $POST_START"
    fi
  else
    echo "  (no postStartCommand found)"
  fi
else
  echo "  WARN: $DEVCONTAINER_JSON not found, skipping lifecycle command check"
fi

echo "==> Done"
