#!/bin/bash

last_notified=100
last_status=$(cat /sys/class/power_supply/BAT0/status)

while true; do
    BAT_STAT=$(cat /sys/class/power_supply/BAT0/status)
    BAT_PERC=$(cat /sys/class/power_supply/BAT0/capacity)

    # 1. SI SE CONECTA
    if [ "$BAT_STAT" = "Charging" ] && [ "$last_status" != "Charging" ]; then
        notify-send -u normal -i "battery-level-100-plugged-in-symbolic" "Cargador" "Conectado ($BAT_PERC%)"
        last_notified=100 
    fi

    # 2. SI SE DESCONECTA
    if [ "$BAT_STAT" != "Charging" ] && [ "$last_status" = "Charging" ]; then
        notify-send -u normal -i "battery-caution-symbolic" "Cargador" "Desconectado ($BAT_PERC%)"
    fi

    # 3. UMBRALES DE DESCARGA
    if [ "$BAT_STAT" != "Charging" ]; then
        for level in 20 15 10 5; do
            if [ "$BAT_PERC" -le "$level" ] && [ "$last_notified" -gt "$level" ]; then
                urgency="normal"
                icon="battery-low-symbolic"
                [ "$level" -le 15 ] && urgency="critical" && icon="battery-empty-symbolic"
                
                notify-send -u "$urgency" -i "$icon" "Batería Baja" "Nivel: $BAT_PERC%"
                last_notified=$level
                break
            fi
        done
    fi

    last_status="$BAT_STAT"
    sleep 1  # <--- CAMBIADO DE 5 A 1 PARA RESPUESTA INSTANTÁNEA
done
