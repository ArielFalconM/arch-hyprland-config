#!/bin/bash

# Escucha cambios de propiedades en el adaptador bluetooth
dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='/org/bluez/hci0'" | while read -r line; do
    
    # 1. DETECTAR ENCENDIDO/APAGADO DEL ADAPTADOR
    if echo "$line" | grep -q "Powered"; then
        status=$(bluetoothctl show | grep "Powered" | awk '{print $2}')
        if [ "$status" = "yes" ]; then
            msg="Adaptador Encendido"
            icon="bluetooth"  # <--- Icono Logo Bluetooth Azul
        else
            msg="Adaptador Apagado"
            icon="bluetooth-disabled" # <--- Icono Bluetooth Gris/Tachado
        fi
        notify-send -u normal -i "$icon" -a "Bluetooth System" "Bluetooth" "$msg"
    fi

    # 2. DETECTAR CONEXIÓN DE DISPOSITIVOS
    if echo "$line" | grep -q "Connected"; then
        sleep 0.5 # Esperar a que conecte bien
        if bluetoothctl devices Connected | grep -q "Device"; then
            # SI HAY ALGO CONECTADO: Icono de Auriculares
            notify-send -u normal -i "audio-headphones" -a "Bluetooth System" "Bluetooth" "Dispositivo Conectado"
        else
            # SI SE DESCONECTÓ: Icono de desconexión
            notify-send -u normal -i "network-wireless-disconnected" -a "Bluetooth System" "Bluetooth" "Dispositivo Desconectado"
        fi
    fi
done