#!/bin/bash

last_pwr=""
last_conn=""

# Escucha de cambios
dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='/org/bluez/hci0'" 2>/dev/null | while read -r line; do

    # 1. DETECTAR ENCENDIDO/APAGADO DEL ADAPTADOR
    if echo "$line" | grep -q "Powered"; then
        status=$(bluetoothctl show | grep "Powered" | awk '{print $2}')
        if [ "$status" != "$last_pwr" ]; then
            last_pwr="$status"
            if [ "$status" = "yes" ]; then
                msg="Adaptador Encendido"
                icon="bluetooth"
            else
                msg="Adaptador Apagado"
                icon="bluetooth-disabled"
            fi
            notify-send -u normal -i "$icon" -a "Bluetooth System" "Bluetooth" "$msg"
        fi
    fi

    # 2. DETECTAR CONEXIÓN DE DISPOSITIVOS
    if echo "$line" | grep -q "Connected"; then
        sleep 0.5
        if bluetoothctl devices Connected | grep -q "Device"; then
            if [ "$last_conn" != "yes" ]; then
                last_conn="yes"
                # SI HAY ALGO CONECTADO: Icono de Auriculares
                notify-send -u normal -i "audio-headphones" -a "Bluetooth System" "Bluetooth" "Dispositivo Conectado"
            fi
        else
            if [ "$last_conn" != "no" ]; then
                last_conn="no"
                # SI SE DESCONECTÓ: Icono de desconexión
                notify-send -u normal -i "network-wireless-disconnected" -a "Bluetooth System" "Bluetooth" "Dispositivo Desconectado"
            fi
        fi
    fi
done
