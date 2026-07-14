#!/bin/bash

WATCH_DIR="$HOME/Zettel/98-Data"

# Archivo temporal para actuar como buffer de agrupación
BUFFER="/tmp/obsidian_img_buffer.txt"


inotifywait -m -e close_write,moved_to --format "%f" "$WATCH_DIR" | while read -r filename; do

    if [[ "${filename,,}" =~ \.(png|jpg|jpeg|webp|gif|svg)$ ]]; then

        echo "![[$filename]]" >> "$BUFFER"

        # Lógica de agrupación (Debounce)
        # Se detiene el temporizador anterior si entra otra imagen
        pkill -P $$ sleep 2>/dev/null

        (
            sleep 2 # Espera para agrupar las transferencias múltiples
            if [ -s "$BUFFER" ]; then
                # Copia del contenido al portapapeles y vaciado el buffer
                wl-copy < "$BUFFER"
                > "$BUFFER"
            fi
        ) &
    fi
done
