#!/bin/bash

# Estado inicial leyendo el demonio
last_ssid=$(nmcli -t -f NAME,TYPE connection show --active | grep 'wireless' | cut -d: -f1 | head -n 1)

while true; do
    # SSID actual de forma pasiva
    current_ssid=$(nmcli -t -f NAME,TYPE connection show --active | grep 'wireless' | cut -d: -f1 | head -n 1)

    # Caso 1: Se conecta a una red nueva (o cambia de red)
    if [ -n "$current_ssid" ] && [ "$current_ssid" != "$last_ssid" ]; then
        notify-send -u normal -i "network-wireless-connected-symbolic" "Wifi" "Conectado a: $current_ssid"
        last_ssid="$current_ssid"
    fi

    # Caso 2: Se desconecta
    if [ -z "$current_ssid" ] && [ -n "$last_ssid" ]; then
        notify-send -u normal -i "network-wireless-offline-symbolic" "Wifi" "Desconectado"
        last_ssid=""
    fi

    sleep 1
done
