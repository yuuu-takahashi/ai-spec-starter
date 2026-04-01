#!/usr/bin/env bash
# Claude Code ステータスライン
# https://docs.claude.com/en/docs/claude-code/statusline
#
# - stdin の rate_limits は「最初の API 応答後」に載ることが多い → 不足時は OAuth usage API で補完（起動直後から枠を表示）
# - jq の // は数値 0 を偽として扱うため、実数値は type=="number" で判定
# - 複数行: 1行目モデル、2行目メトリクス

input=$(cat)

# -----------------------------
# utils
# -----------------------------

int_pct() {
  local v="${1%%.*}"
  [[ "$v" =~ ^[0-9]+$ ]] || return 1
  (( v > 100 )) && v=100
  (( v < 0 )) && v=0
  echo "$v"
}

make_bar() {
  local pct=$1 width=${2:-8}
  pct=$(int_pct "$pct") || {
    printf '%*s' "$width" '' | tr ' ' '░'
    return
  }

  local filled=$(( (pct * width + 50) / 100 ))
  (( pct > 0 && filled < 1 )) && filled=1
  (( filled > width )) && filled=$width

  printf "%${filled}s" | tr ' ' '▓'
  printf "%$((width - filled))s" | tr ' ' '░'
}

fmt_epoch() {
  local e="$1"
  [ -z "$e" ] && return
  case "$(uname -s)" in
    Darwin) date -r "$e" '+%m/%d %H:%M' ;;
    *) date -d "@$e" '+%m/%d %H:%M' ;;
  esac
}

# -----------------------------
# context %
# -----------------------------

get_ctx_pct() {
  echo "$input" | jq -r '
    def input_only:
      (.input_tokens // 0)
      + (.cache_creation_input_tokens // 0)
      + (.cache_read_input_tokens // 0);

    if (.context_window.used_percentage | type) == "number"
      then .context_window.used_percentage | floor
    elif (.context_window.remaining_percentage | type) == "number"
      then (100 - .context_window.remaining_percentage) | floor
    elif (.context_window.current_usage | type) == "object"
      and (.context_window.context_window_size | type) == "number"
      and (.context_window.context_window_size > 0)
      then ((.context_window.current_usage | input_only)
            / .context_window.context_window_size * 100 | floor)
    else 0 end
  '
}

# -----------------------------
# stdin rate limits
# -----------------------------

get_limits_from_input() {
  echo "$input" | jq -c '
    def pct(w):
      if w == null then null
      elif (w.used_percentage | type) == "number"
        then w.used_percentage | floor
      elif (w.utilization | type) == "number"
        then (if w.utilization <= 1
              then (w.utilization * 100)
              else w.utilization end | floor)
      else null end;

    def epoch(w):
      if (w.resets_at | type) == "number"
        then w.resets_at | floor
      else null end;

    (.rate_limits // {}) as $r |
    {
      fh_pct: pct($r.five_hour),
      fh_epoch: epoch($r.five_hour),
      wk_pct: pct($r.seven_day),
      wk_epoch: epoch($r.seven_day)
    }
  '
}

# -----------------------------
# OAuth fallback
# -----------------------------

fetch_usage_api() {
  local token
  token=$(jq -r '.claudeAiOauth.accessToken // empty' ~/.claude/.credentials.json)
  [ -z "$token" ] && return 1

  curl -sS --max-time 4 "https://api.anthropic.com/api/oauth/usage" \
    -H "Authorization: Bearer ${token}" \
    -H "anthropic-beta: oauth-2025-04-20"
}

fill_from_usage_api() {
  local json="$1"

  fh_pct=${fh_pct:-$(echo "$json" | jq -r '.five_hour.utilization * 100 | floor // empty')}
  wk_pct=${wk_pct:-$(echo "$json" | jq -r '.seven_day.utilization * 100 | floor // empty')}
}

# -----------------------------
# main
# -----------------------------

model=$(echo "$input" | jq -r '.model.display_name // "?"')
((${#model} > 18)) && model="${model:0:18}~"

ctx=$(get_ctx_pct)

limits=$(get_limits_from_input)

fh_pct=$(echo "$limits" | jq -r '.fh_pct // empty')
fh_epoch=$(echo "$limits" | jq -r '.fh_epoch // empty')
wk_pct=$(echo "$limits" | jq -r '.wk_pct // empty')
wk_epoch=$(echo "$limits" | jq -r '.wk_epoch // empty')

# fallback
if [ -z "$fh_pct" ] || [ -z "$wk_pct" ]; then
  usage=$(fetch_usage_api)
  [ -n "$usage" ] && fill_from_usage_api "$usage"
fi

# -----------------------------
# render
# -----------------------------

line1="$model"
line2="ctx $(make_bar "$ctx") ${ctx}%"

if [ -n "$fh_pct" ]; then
  line2="$line2 | $(make_bar "$fh_pct") ${fh_pct}% $(fmt_epoch "$fh_epoch")"
fi

if [ -n "$wk_pct" ]; then
  line2="$line2 | $(make_bar "$wk_pct") ${wk_pct}% $(fmt_epoch "$wk_epoch")"
fi

[ -z "$fh_pct" ] && [ -z "$wk_pct" ] && line2="$line2 | lim:--"

printf '%s\n%s\n' "$line1" "$line2"