#!/bin/bash

# Usamos la RAM para evitar el lag de escritura en disco
STATE_FILE="/dev/shm/waybar_vol_ticks"
THRESHOLD=8 # Ajusta este número para la "pesadez" (30-50 suele ser ideal)

# Inicializar si no existe
[ ! -f "$STATE_FILE" ] && echo 0 > "$STATE_FILE"

# Leer y actualizar el contador de forma rápida
TICKS=$(cat "$STATE_FILE")
if [ "$1" == "up" ]; then ((TICKS++)); else ((TICKS--)); fi

# Si no llegamos al umbral, solo guardamos y salimos (operación ultra rápida)
if [ "$TICKS" -lt "$THRESHOLD" ] && [ "$TICKS" -gt -"$THRESHOLD" ]; then
    echo "$TICKS" > "$STATE_FILE"
    exit 0
fi

# Si llegamos aquí, es hora de cambiar el volumen. 
# Reseteamos el contador inmediatamente para evitar que otros procesos disparen
echo 0 > "$STATE_FILE"

# Obtenemos el volumen actual como un entero (0-100)
CUR_VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100 + 0.5)}')

if [ "$1" == "up" ]; then
    # Lógica: Ir al siguiente múltiplo de 5 superior
    NEW_VOL=$(( (CUR_VOL / 5 + 1) * 5 ))
    [ "$NEW_VOL" -gt 100 ] && NEW_VOL=100
else
    # Lógica: Ir al siguiente múltiplo de 5 inferior
    # Restamos 1 antes de dividir para asegurar que baje si ya estamos en un múltiplo
    NEW_VOL=$(( ((CUR_VOL - 1) / 5) * 5 ))
    [ "$NEW_VOL" -lt 0 ] && NEW_VOL=0
fi

# Aplicar el volumen exacto
wpctl set-volume @DEFAULT_AUDIO_SINK@ "$NEW_VOL"%
