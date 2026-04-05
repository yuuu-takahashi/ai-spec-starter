#!/usr/bin/env bash
# PostToolUse フック: Edit/Write の直後に実行される。
# CI 設定ファイルまたは Docker 関連ファイルの編集時のみチェックし、結果を JSON または stderr で返す。
# 対象外のファイルの場合は何もせず exit 0。

set -euo pipefail

# stdin から hook 入力 JSON を読む
INPUT_JSON="$(cat)"
FILE_PATH=""
if command -v jq &>/dev/null; then
  FILE_PATH="$(echo "$INPUT_JSON" | jq -r '.tool_input.file_path // .tool_input.path // ""')"
fi

if [[ -z "${FILE_PATH:-}" || "$FILE_PATH" == "null" ]]; then
  exit 0
fi

NORMALIZED="${FILE_PATH//\\/\/}"
BASENAME="$(basename "$FILE_PATH")"
KIND=""

# --- CI ファイル判定 ---
if [[ "$NORMALIZED" == *".github/workflows"* ]]; then
  KIND="ci-github"
elif [[ "$BASENAME" == ".gitlab-ci.yml" ]]; then
  KIND="ci-gitlab"
elif [[ "$NORMALIZED" == *".circleci/config.yml"* ]] || [[ "$BASENAME" == "config.yml" && "$NORMALIZED" == *".circleci"* ]]; then
  KIND="ci-circle"
elif [[ "$BASENAME" == "bitbucket-pipelines.yml" ]]; then
  KIND="ci-bitbucket"
elif [[ "$BASENAME" == "azure-pipelines.yml" ]] || [[ "$NORMALIZED" == *"azure-pipelines"* ]]; then
  KIND="ci-azure"
# --- Docker ファイル判定 ---
elif [[ "$BASENAME" == "Dockerfile" ]]; then
  KIND="docker-dockerfile"
elif [[ "$BASENAME" == ".dockerignore" ]]; then
  KIND="docker-dockerignore"
elif [[ "$BASENAME" == "docker-compose.yml" || "$BASENAME" == "docker-compose.yaml" || "$BASENAME" == "compose.yml" ]]; then
  KIND="docker-compose"
fi

if [[ -z "$KIND" ]]; then
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
cd "$PROJECT_DIR"

REAL_PATH="$FILE_PATH"
[[ "$REAL_PATH" != /* ]] && REAL_PATH="$PROJECT_DIR/$REAL_PATH"
if [[ ! -f "$REAL_PATH" ]]; then
  exit 0
fi

run_output=""
exit_code=0

case "$KIND" in
  ci-github)
    if command -v actionlint &>/dev/null; then
      run_output="$(actionlint "$REAL_PATH" 2>&1)" || exit_code=$?
      if [[ $exit_code -ne 0 && -n "$run_output" ]]; then
        echo "$run_output" >&2
        exit 2
      fi
    else
      run_output="GitHub Actions ワークフローが編集されました。actionlint をインストールすると編集直後に自動チェックされます。手動では my:review-config スキルを参照してください。"
    fi
    ;;
  ci-gitlab|ci-circle|ci-bitbucket|ci-azure)
    run_output="CI 設定ファイル（${KIND#ci-}）が編集されました。必要に応じて my:review-config スキルまたは各 CI の公式ドキュメントで構文・ベストプラクティスを確認してください。"
    ;;
  docker-dockerfile)
    if command -v hadolint &>/dev/null; then
      run_output="$(hadolint "$REAL_PATH" 2>&1)" || exit_code=$?
      if [[ $exit_code -ne 0 && -n "$run_output" ]]; then
        echo "$run_output" >&2
        exit 2
      fi
    else
      run_output="Dockerfile が編集されました。Hadolint をインストールすると編集直後に自動チェックされます。手動では my:review-config スキルを参照してください。"
    fi
    ;;
  docker-compose)
    if command -v docker &>/dev/null; then
      if ! docker compose -f "$REAL_PATH" config --quiet 2>/dev/null; then
        docker compose -f "$REAL_PATH" config 2>&1 | head -50 >&2
        exit 2
      fi
    else
      run_output="docker-compose 系ファイルが編集されました。手動では my:review-config スキルまたは docker compose config で構文確認してください。"
    fi
    ;;
  docker-dockerignore)
    run_output=".dockerignore が編集されました。必要に応じて my:review-config スキルを参照してください。"
    ;;
  *)
    exit 0
    ;;
esac

if [[ $exit_code -eq 0 && -n "$run_output" ]]; then
  if command -v jq &>/dev/null; then
    echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PostToolUse\",\"additionalContext\":$(echo "$run_output" | jq -Rs .)}}"
  else
    echo "$run_output"
  fi
fi
exit 0
