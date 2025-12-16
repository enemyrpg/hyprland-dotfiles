#!/usr/bin/env bash
set -euo pipefail

STYLE="${HOME}/.config/swayosd/style.css"

# --- Single instance guard ---
if pgrep -f "$0" | grep -v "$$" >/dev/null 2>&1; then
  exit 0
fi

# --- Restart swayosd-server to ensure correct CSS ---
pkill -f swayosd-server 2>/dev/null || true
swayosd-server -s "$STYLE" & disown
sleep 0.1

# --- Helpers ---
to_pct() {
  awk -v v="$1" 'BEGIN{
    if(v<0)v=0;
    if(v>1)v=1;
    printf "%d", int(v*100+0.5)
  }'
}

get_sink_state() {
  # Outputs: "<volume 0..1> <MUTED|UNMUTED>"
  local raw vol mute
  raw="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
  vol="$(awk '{print $2}' <<<"$raw")"
  mute="$(grep -q 'MUTED' <<<"$raw" && echo MUTED || echo UNMUTED)"
  printf '%s %s\n' "$vol" "$mute"
}

icon_for() {
  local vol="$1" mute="$2" pct
  pct="$(to_pct "$vol")"

  if [[ "$mute" == "MUTED" || "$pct" -eq 0 ]]; then
    echo "audio-volume-muted-symbolic"
  elif (( pct < 34 )); then
    echo "audio-volume-low-symbolic"
  elif (( pct < 67 )); then
    echo "audio-volume-medium-symbolic"
  else
    echo "audio-volume-high-symbolic"
  fi
}

show_osd() {
  local vol="$1" mute="$2" pct icon
  pct="$(to_pct "$vol")"
  icon="$(icon_for "$vol" "$mute")"

  swayosd-client \
    --custom-icon "$icon" \
    --custom-progress "$vol" \
    --custom-progress-text "$pct" \
    2>/dev/null || true
}

# --- Initial state ---
read -r prev_vol prev_mute <<<"$(get_sink_state)"

# --- Listen for volume changes ---
pactl subscribe | stdbuf -oL grep --line-buffered -i "sink" | while read -r _; do
  read -r vol mute <<<"$(get_sink_state)"

  # Only show if something actually changed
  if [[ "$vol" != "$prev_vol" || "$mute" != "$prev_mute" ]]; then
    prev_vol="$vol"
    prev_mute="$mute"
    show_osd "$vol" "$mute"
  fi
done