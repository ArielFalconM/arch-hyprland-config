#!/bin/bash

ZETTEL_DIR="$HOME/Zettel"

if [ -d "$ZETTEL_DIR" ]; then
    cd "$ZETTEL_DIR" || exit

    if ! git pull -q; then
        notify-send -u critical "Zettelkasten" "Error al actualizar (Pull)"
    fi
else
    notify-send -u critical "Zettelkasten Error" "La carpeta $ZETTEL_DIR no existe."
fi
