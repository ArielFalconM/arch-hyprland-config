#!/bin/bash

# Estado almacenado en memoria compartida (RAM) para reducir latencia
STATE_FILE="/dev/shm/waybar_vol_ticks"
THRESHOLD=8

# Inicialización del archivo de estado
[ ! -f "$STATE_FILE" ] && echo 0 > "$STATE_FILE"

# Leer y actualizar el contador
TICKS=$(cat "$STATE_FILE")
if [ "$1" == "up" ]; then ((TICKS++)); else ((TICKS--)); fi

# Salir si no se alcanza el umbral de activación
if (( TICKS < THRESHOLD && TICKS > -THRESHOLD )); then
    echo "$TICKS" > "$STATE_FILE"
    exit 0
fi

# Resetear el contador al alcanzar el umbral
echo 0 > "$STATE_FILE"

# Obtener el volumen actual como un valor entero (0-100)
CUR_VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100 + 0.5)}')

# Calcular el nuevo volumen ajustando al múltiplo de 5 más cercano
if [ "$1" == "up" ]; then
    NEW_VOL=$(( (CUR_VOL / 5 + 1) * 5 ))
    [ "$NEW_VOL" -gt 100 ] && NEW_VOL=100
else
    NEW_VOL=$(( ((CUR_VOL - 1) / 5) * 5 ))
    [ "$NEW_VOL" -lt 0 ] && NEW_VOL=0
fi

# Aplicar el nivel de volumen
wpctl set-volume @DEFAULT_AUDIO_SINK@ "$NEW_VOL"%