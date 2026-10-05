#!/bin/sh
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# macOS date(1) uses -r, GNU date uses -d.
format_reset() {
  epoch="$1"
  [ -z "$epoch" ] && return
  if date -r "$epoch" "+%H:%M" >/dev/null 2>&1; then
    date -r "$epoch" "+%H:%M"
  else
    date -d "@$epoch" "+%H:%M" 2>/dev/null
  fi
}

parts=""

[ -n "$model" ] && parts="$model"

[ -n "$used" ] && parts="$parts | ctx:$(printf '%.0f' "$used")%"

if [ -n "$five_pct" ]; then
  five_str="5h:$(printf '%.0f' "$five_pct")%"
  reset_time=$(format_reset "$five_reset")
  [ -n "$reset_time" ] && five_str="$five_str(resets $reset_time)"
  parts="$parts | $five_str"
fi

if [ -n "$week_pct" ]; then
  week_str="7d:$(printf '%.0f' "$week_pct")%"
  reset_time=$(format_reset "$week_reset")
  [ -n "$reset_time" ] && week_str="$week_str(resets $reset_time)"
  parts="$parts | $week_str"
fi

printf "\033[2m%s\033[0m" "$parts"
