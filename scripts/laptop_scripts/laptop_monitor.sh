#!/usr/bin/env bash

handle_monitors() {
    LAPTOP_MON=$(hyprctl monitors all -j | jq -r '.[] | select(.name | startswith("eDP")) | .name' | head -n 1)
    
    if [ -z "$LAPTOP_MON" ]; then
        return
    fi

    MONITOR_COUNT=$(hyprctl monitors all -j | jq '. | length')

    if [ "$MONITOR_COUNT" -gt 1 ]; then
        hyprctl keyword monitor "$LAPTOP_MON, disable"
        
        # Si la función fue llamada con el argumento "init" (durante el arranque)
        if [ "$1" == "init" ]; then
            # se fuerza la vista al Workspace 1
            sleep 0.2
            hyprctl dispatch workspace 1
        fi
    else
        hyprctl keyword monitor "$LAPTOP_MON, preferred, auto, 1.25"
    fi
}

#Aviso de que es el arranque
handle_monitors "init"

# Bucle de escucha
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    if [[ "$line" == "monitoradded>>"* ]] || [[ "$line" == "monitorremoved>>"* ]]; then
        handle_monitors "event"
    fi
done