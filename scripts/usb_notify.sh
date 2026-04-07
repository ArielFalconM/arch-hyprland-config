#!/bin/bash
# Evita el spam de notificaciones usando un timer (debounce)
last_trigger=0

stdbuf -oL udisksctl monitor | while read -r line; do
    now=$(date +%s)
    
    # Notifica solo una vez cada 2 segundos para el mismo dispositivo
    if echo "$line" | grep -q "Added" && [ $((now - last_trigger)) -gt 2 ]; then
        notify-send -u normal -i "drive-removable-media-symbolic" "Hardware" "Nuevo dispositivo detectado"
        last_trigger=$now
    elif echo "$line" | grep -q "Removed" && [ $((now - last_trigger)) -gt 2 ]; then
        notify-send -u normal -i "drive-removable-media-symbolic" "Hardware" "Dispositivo extraído"
        last_trigger=$now
    fi
done
