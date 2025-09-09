#!/usr/bin/env bash
set -euo pipefail

STYLE="${HOME}/.config/swayosd/style.css"
STEP=0.02      # 2% increments
WARMUP_MS=4000 # ignore startup churn
DEBOUNCE_MS=150

# --- Ensure server is running ---
pgrep -x swayosd-server >/dev/null 2>&1 || { swayosd-server -s "$STYLE" & sleep 0.1; }

# --- Helper: round volume to nearest STEP ---
round_volume() {
  awk -v v="$1" -v s="$STEP" 'BEGIN {printf "%.2f", (int((v/s)+0.5))*s}'
}

# --- Helper: get current volume/mute ---
get_sink_state() {
  local raw vol mute
  raw="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
  vol="$(printf '%s' "$raw" | awk '{print $2}')"
  mute="$(printf '%s' "$raw" | grep -q 'MUTED' && echo MUTED || echo UNMUTED)"
  printf '%s %s\n' "$vol" "$mute"
}

# --- Initial snapshot ---
read -r prev_vol prev_mute <<<"$(get_sink_state)"
prev_ts=0
start_ms=$(date +%s%3N)

# --- Listen for sink changes ---
pactl subscribe | stdbuf -oL awk '/Event '\''change'\'' on sink/ {print}' | while read -r _; do
  now=$(date +%s%3N)

  # Warmup
  if (( now - start_ms < WARMUP_MS )); then
    continue
  fi

  # Debounce
  if (( now - prev_ts < DEBOUNCE_MS )); then
    continue
  fi

  # Current state
  read -r cur_vol cur_mute <<<"$(get_sink_state)"

  # Check mute toggle
  if [[ "$cur_mute" != "$prev_mute" ]]; then
    prev_mute="$cur_mute"
    prev_ts=$now
    swayosd-client --output-volume 0
    continue
  fi

  # Snap volume to nearest step
  rounded="$(round_volume "$cur_vol")"

  if [[ "$rounded" != "$cur_vol" ]]; then
    wpctl set-volume @DEFAULT_AUDIO_SINK@ "$rounded"
  fi

  if [[ "$rounded" != "$prev_vol" ]]; then
    prev_vol="$rounded"
    prev_ts=$now
    swayosd-client --output-volume 0
  fi
done