#!/bin/bash
# PreToolUse: Bash 実行前の検証（記事サンプルに基づく）
COMMAND=$(jq -r '.tool_input.command' </dev/stdin)

if echo "$COMMAND" | grep -q 'rm -rf'; then
  echo 'Blocked: rm -rf commands are not allowed' >&2
  exit 2
fi

if echo "$COMMAND" | grep -q 'prod'; then
  echo 'Blocked: production access is not allowed' >&2
  exit 2
fi

exit 0
