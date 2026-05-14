#!/bin/bash

ZETTEL_DIR="$HOME/Zettel"

if [ -d "$ZETTEL_DIR" ]; then
    cd "$ZETTEL_DIR" || exit

    git add .

    if ! git diff-index --quiet HEAD --; then
        FECHA=$(date +"%Y-%m-%d %H:%M:%S")

        git commit -m "Auto-sync: $FECHA" > /dev/null

        if ! git push -q; then
            notify-send -u critical "Zettelkasten" "Error al subir los cambios (Push)"
        fi
    fi
else
    notify-send -u critical "Zettelkasten Error" "La carpeta $ZETTEL_DIR no existe."
fi
