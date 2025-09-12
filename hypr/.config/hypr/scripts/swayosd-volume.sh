#!/usr/bin/env bash
set -euo pipefail

STYLE="${HOME}/.config/swayosd/style.css"

# --- Tunables (adjust to taste) ---
STEP=0.02          # enforce 2% increments
POLL_MS=100        # poll every 100 ms for smooth updates
DISPLAY_EPS=0.02   # need >=2% visible change to show OSD (noise filter)
APPLY_EPS=0.003    # apply snap if raw differs by >=0.3% (tight for true 2%)
DEBOUNCE_MS=150    # minimum time between OSD updates (ms)
DISPLAY_MODE="snapped"  # "snapped" shows exact 2% steps; use "raw" to show actual

# --- Single instance guard (by full path) ---
if pgrep -f "$0" | grep -v "$$" >/dev/null 2>&1; then
  exit 0
fi

# --- Always restart swayosd-server to pick up latest CSS ---
pkill -f swayosd-server 2>/dev/null || true
swayosd-server -s "$STYLE" & disown
sleep 0.1

# --- Helpers ---
now_ms()       { date +%s%3N; }
round_vol()    { awk -v v="$1" -v s="$STEP" 'BEGIN{printf "%.2f",(int((v/s)+0.5))*s}'; }
clamp01()      { awk -v v="$1" 'BEGIN{if(v<0)v=0;if(v>1)v=1;printf"%.3f",v}'; }
to_pct()       { awk -v v="$1" 'BEGIN{if(v<0)v=0;if(v>1)v=1;printf "%d",int(v*100+0.5)}'; }
absdiff()      { awk -v a="$1" -v b="$2" 'BEGIN{d=a-b;if(d<0)d=-d;print d}'; }

get_sink_state() {
  # Returns "<float-volume 0..1> <MUTED|UNMUTED>"
  local raw vol mute
  raw="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
  vol="$(printf '%s' "$raw" | awk '{print $2}')"
  mute="$(printf '%s' "$raw" | grep -q 'MUTED' && echo MUTED || echo UNMUTED)"
  printf '%s %s\n' "$vol" "$mute"
}

icon_for() {
  local lvl="$1" mute="$2"
  if [[ "$mute" == "MUTED" || "$(to_pct "$lvl")" -eq 0 ]]; then
    echo "audio-volume-muted-symbolic"
  else
    local p; p="$(to_pct "$lvl")"
    if   (( p < 34 )); then echo "audio-volume-low-symbolic"
    elif (( p < 67 )); then echo "audio-volume-medium-symbolic"
    else                   echo "audio-volume-high-symbolic"
    fi
  fi
}

show_osd() {
  # Show bar + percent + icon without changing volume
  local vol="$1" mute="$2"
  local pct icon
  vol="$(clamp01 "$vol")"
  pct="$(to_pct "$vol")"
  icon="$(icon_for "$vol" "$mute")"
  swayosd-client \
    --custom-icon "$icon" \
    --custom-progress "$vol" \
    --custom-progress-text "$pct" \
    2>/dev/null || true
}

# --- State ---
read -r prev_raw prev_mute <<<"$(get_sink_state)"
prev_disp="$prev_raw"
prev_ts=0

# --- Background poller (smooth + enforcement) ---
(
  while true; do
    sleep "$(awk -v ms="$POLL_MS" 'BEGIN{print ms/1000}')"

    read -r cur_raw cur_mute <<<"$(get_sink_state)"

    # 1) ENFORCE true 2% in PipeWire (write back whenever off by >= APPLY_EPS)
    snapped="$(round_vol "$cur_raw")"
    if awk -v d="$(absdiff "$snapped" "$cur_raw")" -v e="$APPLY_EPS" 'BEGIN{exit !(d>=e)}'; then
      wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "$snapped" 2>/dev/null || true
      cur_raw="$snapped"  # reflect enforced value immediately
    fi

    # 2) Decide what to display: raw or snapped
    if [[ "$DISPLAY_MODE" == "snapped" ]]; then
      disp="$snapped"
    else
      disp="$cur_raw"
    fi

    # 3) Debounce + visible-change threshold for showing OSD
    now="$(now_ms)"
    if (( now - prev_ts < DEBOUNCE_MS )); then
      continue
    fi

    if [[ "$cur_mute" != "$prev_mute" ]] || \
       awk -v d="$(absdiff "$disp" "$prev_disp")" -v e="$DISPLAY_EPS" 'BEGIN{exit !(d>=e)}'
    then
      prev_mute="$cur_mute"
      prev_disp="$disp"
      prev_ts="$now"
      show_osd "$disp" "$cur_mute"
    fi
  done
) & disown

# --- Event listener (snappier reacts to discrete sink changes) ---
pactl subscribe | stdbuf -oL grep --line-buffered -i "sink " | while read -r _; do
  read -r cur_raw cur_mute <<<"$(get_sink_state)"

  snapped="$(round_vol "$cur_raw")"
  if awk -v d="$(absdiff "$snapped" "$cur_raw")" -v e="$APPLY_EPS" 'BEGIN{exit !(d>=e)}'; then
    wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "$snapped" 2>/dev/null || true
    cur_raw="$snapped"
  fi

  if [[ "$DISPLAY_MODE" == "snapped" ]]; then disp="$snapped"; else disp="$cur_raw"; fi

  now="$(now_ms)"
  if (( now - prev_ts < DEBOUNCE_MS )); then
    continue
  fi

  if [[ "$cur_mute" != "$prev_mute" ]] || \
     awk -v d="$(absdiff "$disp" "$prev_disp")" -v e="$DISPLAY_EPS" 'BEGIN{exit !(d>=e)}'
  then
    prev_mute="$cur_mute"
    prev_disp="$disp"
    prev_ts="$now"
    show_osd "$disp" "$cur_mute"
  fi
done