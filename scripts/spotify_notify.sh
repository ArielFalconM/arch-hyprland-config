#!/bin/bash

last=""
# Monitoreamos cambios en Spotify usando un separador único (|)
playerctl --player=spotify metadata --format '{{title}}|{{artist}}' --follow | while read -r line; do
    if [ -n "$line" ] && [ "$line" != "$last" ]; then
        last="$line"
        # Separamos la info: f1 es título (canción), f2 es artista
        title=$(echo "$line" | cut -d'|' -f1)
        artist=$(echo "$line" | cut -d'|' -f2)

        # Extraemos la URL de la carátula
        img_url=$(playerctl --player=spotify metadata mpris:artUrl)

        # Descargamos la imagen para que notify-send la procese
        curl -s "$img_url" -o /tmp/spotify_cover.png

        # Enviamos: canción como título, artista como cuerpo
        notify-send -u normal -i /tmp/spotify_cover.png "$title" "$artist"
    fi
done
