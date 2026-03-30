#!/bin/bash
# PostToolUseFailure hook: エラーをJSONL形式でログに記録
# stdin から JSON を受け取り、必要な情報を抽出して追記する

INPUT=$(cat)
LOG_FILE="$(dirname "$0")/../error-log.jsonl"

# ログファイルがなければ作成
if [ ! -f "$LOG_FILE" ]; then
  touch "$LOG_FILE"
fi

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
TOOL_INPUT=$(echo "$INPUT" | jq -c '.tool_input // {}')
ERROR=$(echo "$INPUT" | jq -r '.error // "no error message"')

# 中断（ユーザーキャンセル）は記録しない
IS_INTERRUPT=$(echo "$INPUT" | jq -r '.is_interrupt // false')
if [ "$IS_INTERRUPT" = "true" ]; then
  exit 0
fi

# 短いIDを生成（タイムスタンプベース）
ID=$(date +%s | shasum | head -c 8)

# タイムスタンプ・ステータス付きでJSONL形式に追記
jq -n \
  --arg id "$ID" \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg tool "$TOOL_NAME" \
  --argjson input "$TOOL_INPUT" \
  --arg error "$ERROR" \
  '{id: $id, timestamp: $ts, tool: $tool, tool_input: $input, error: $error, status: "open"}' >> "$LOG_FILE"

exit 0
