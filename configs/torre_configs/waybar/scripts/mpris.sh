#!/usr/bin/env bash
set -u

SCROLL_OFFSET_FILE=/tmp/mpris_scroll_offset
SCROLL_TRACK_FILE=/tmp/mpris_scroll_track
DISPLAY_WIDTH=22
SCROLL_PADDING="   " # Espacio entre el final de la canción y el inicio del loop

fallback_text="DaBoomDaDaMmmDumDaEeMa"
fallback_icon=""

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

player_icon() {
  case "$1" in
  *spotify*) printf '%s' "" ;;
  *brave*) printf '%s' "" ;;
  *mpv*) printf '%s' "" ;;
  *) printf '%s' "" ;;
  esac
}

playing_player=""
paused_player=""
while IFS= read -r p; do
  [ -n "$p" ] || continue
  status="$(playerctl -p "$p" status 2>/dev/null || true)"
  if [ "$status" = "Playing" ]; then
    playing_player="$p"
    break
  fi
  if [ "$status" = "Paused" ] && [ -z "$paused_player" ]; then
    paused_player="$p"
  fi
done < <(playerctl -l 2>/dev/null || true)

target_player="$playing_player"
[ -n "$target_player" ] || target_player="$paused_player"

if [ -z "$target_player" ]; then
  rm -f "$SCROLL_OFFSET_FILE" "$SCROLL_TRACK_FILE"
  printf '{"text":"%s  %s","tooltip":"%s"}\n' \
    "$(json_escape "$fallback_icon")" "$(json_escape "$fallback_text")" "$(json_escape "$fallback_text")"
  exit 0
fi

status="$(playerctl -p "$target_player" status 2>/dev/null || true)"
title="$(playerctl -p "$target_player" metadata xesam:title 2>/dev/null || true)"
artist="$(playerctl -p "$target_player" metadata xesam:artist 2>/dev/null | paste -sd ', ' - || true)"
icon="$(player_icon "$target_player")"

[ -n "$title" ] || {
  rm -f "$SCROLL_OFFSET_FILE" "$SCROLL_TRACK_FILE"
  printf '{"text":"%s  %s","tooltip":"%s"}\n' \
    "$(json_escape "$fallback_icon")" "$(json_escape "$fallback_text")" "$(json_escape "$fallback_text")"
  exit 0
}

if [ -n "$artist" ]; then
  text_content="$title - $artist  "
  tooltip_text="$title - $artist"
else
  text_content="$title"
  tooltip_text="$title"
fi

if [ "$status" = "Paused" ]; then
  prefix="⏸ $icon"
else
  prefix="$icon"
fi

content_len=${#text_content}

if [ "$content_len" -le "$DISPLAY_WIDTH" ]; then
  display_text="$prefix  $text_content"
  printf '0\n' > "$SCROLL_OFFSET_FILE"
  printf '%s\n' "$text_content" > "$SCROLL_TRACK_FILE"
else
  prev_track="$(cat "$SCROLL_TRACK_FILE" 2>/dev/null || printf '')"

  if [ "$text_content" != "$prev_track" ]; then
    offset=0
    printf '%s\n' "$text_content" > "$SCROLL_TRACK_FILE"
  else
    offset="$(cat "$SCROLL_OFFSET_FILE" 2>/dev/null || printf '0')"
    case "$offset" in
      ''|*[!0-9]*) offset=0 ;;
    esac
  fi

  padded="${text_content}${SCROLL_PADDING}"
  padded_len=${#padded}
  doubled="${padded}${padded}"

  scrolling_part="${doubled:$offset:$DISPLAY_WIDTH}"

  display_text="$prefix  $scrolling_part"

  next_offset=$(( (offset + 3) % padded_len ))
  printf '%s\n' "$next_offset" > "$SCROLL_OFFSET_FILE"
fi

# Enviar a Waybar
printf '{"text":"%s","tooltip":"%s"}\n' \
  "$(json_escape "$display_text")" "$(json_escape "$tooltip_text")"
