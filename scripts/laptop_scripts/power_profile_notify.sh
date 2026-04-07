#!/bin/bash
# Ubicación: ~/.local/bin/power_profile_notify.sh

# Limpiamos la salida inicial con xargs para quitar espacios
last_profile=$(powerprofilesctl get | xargs)

while true; do
    current_profile=$(powerprofilesctl get | xargs)
    if [ "$current_profile" != "$last_profile" ]; then
        case "$current_profile" in
            "performance") icon="power-profile-performance-symbolic" ;;
            "power-saver") icon="power-profile-power-saver-symbolic" ;;
            "balanced") icon="power-profile-balanced-symbolic" ;;
        esac

        notify-send -u normal -i "$icon" "Modo de Energía" "Cambiado a: $current_profile"
        last_profile="$current_profile"
    fi
    sleep 0.5 # Bajamos a medio segundo para mayor respuesta
done
