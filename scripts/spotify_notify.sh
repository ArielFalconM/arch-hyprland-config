#!/bin/bash

last_metadata=""
last_time=0

# Monitoreo de cambios en Spotify
playerctl --player=spotify metadata --format '{{title}}|{{artist}}' --follow | while read -r line; do
    current_time=$(date +%s%N)

    # Diferencia con la notificación anterior (en milisegundos)
    diff=$(( (current_time - last_time) / 1000000 ))

    if [ -n "$line" ] && [ "$line" != "$last_metadata" ]; then
        # Si la misma canción llega en menos de 800ms, es un duplicado de D-Bus
        if [ $diff -lt 800 ]; then
            continue
        fi

        last_metadata="$line"
        last_time=$current_time

        title=$(echo "$line" | cut -d'|' -f1)
        artist=$(echo "$line" | cut -d'|' -f2)

        # Extraemos la URL de la carátula
        img_url=$(playerctl --player=spotify metadata mpris:artUrl)

        # Descargamos la imagen
        curl -s "$img_url" -o /tmp/spotify_cover.png

        # Enviamos la notificación
        notify-send -u normal -i /tmp/spotify_cover.png "$title" "$artist"
    fi
done
