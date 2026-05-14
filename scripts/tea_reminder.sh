#!/bin/bash
#Recordatorio de beber té utilizando APIs y Ley de Enfriamiento de Newton

# Constantes:
TEMP_INICIAL=80
TEMP_LIMITE=40
INTERVALO_MIN=3
PID_FILE="/tmp/te-reminder.pid"
STOP_FILE="/tmp/te-reminder.stop"
ICON="$HOME/.local/share/icons/te.svg"

# Eleccion de recipiente.
echo "¿Qué recipiente estás usando?"
echo "  1) Taza de cristal"
echo "  2) Taza de cerámica"
read -rp "Opción [1-2]: " opcion

case "$opcion" in
  1) RECIPIENTE="cristal";  K=0.018 ;;
  2) RECIPIENTE="ceramica"; K=0.012 ;;
  *) echo "Opción inválida, usando cristal por defecto."; RECIPIENTE="cristal"; K=0.018 ;;
esac

echo "→ Recipiente: $RECIPIENTE (k=$K)"

#Funciones

get_temp_ambiente() {
  #Obteniendo ubicacion aproximada utilizando ipapi para luego conocer la temperatura ambiente.
  local ip_data
  ip_data=$(curl -sf --max-time 5 "https://ipapi.co/json/") || {
    echo "20" #En caso de error asume temperatura.
    return
  }
  local lat lon
  lat=$(echo "$ip_data" | grep -o '"latitude": *[0-9.-]*' | grep -o '[0-9.-]*')
  lon=$(echo "$ip_data" | grep -o '"longitude": *[0-9.-]*' | grep -o '[0-9.-]*')

  if [[ -z "$lat" || -z "$lon" ]]; then
    echo "20"
    return
  fi

  # Consulta de temperatura con wttr.in a partir de la ubicacion aproximada.
  local temp
  temp=$(curl -sf --max-time 5 "https://wttr.in/${lat},${lon}?format=%t" \
    | grep -o '[+-]*[0-9]*' | head -1)

  if [[ -z "$temp" ]]; then
    echo "20"
  else
    echo "$temp"
  fi
}

# Ecuacion: T(t) = T_amb + (T0 - T_amb) * e^(-k*t)
calcular_temp_actual() {
  local t=$1     # minutos transcurridos
  local t_amb=$2
  awk "BEGIN { printf \"%.2f\", $t_amb + ($TEMP_INICIAL - $t_amb) * exp(-$K * $t) }"
}

# Minutos restantes para llegar al TEMP_LIMITE
calcular_tiempo_total() {
  local t_amb=$1
  awk "BEGIN { printf \"%.0f\", -log(($TEMP_LIMITE - $t_amb) / ($TEMP_INICIAL - $t_amb)) / $K }"
}

enviar_notificacion() {
  local titulo="$1"
  local cuerpo="$2"
  local urgencia="${3:-normal}"

  # notify-send con acción "Terminé el té" que crea el archivo de stop
  notify-send \
    --urgency="$urgencia" \
    --app-name="Té" \
    --icon="$ICON" \
    --action="stop=Terminé el té 🍵" \
    "$titulo" "$cuerpo" | grep -q "stop" && touch "$STOP_FILE"
}

cleanup() {
  rm -f "$PID_FILE" "$STOP_FILE"
  exit 0
}

# ─── Main ────────────────────────────────────────────────────────────────────

# Checkeo para evitar instancias duplicadas
if [[ -f "$PID_FILE" ]]; then
  old_pid=$(cat "$PID_FILE")
  if kill -0 "$old_pid" 2>/dev/null; then
    echo "Ya hay un recordatorio de té activo (PID $old_pid)."
    exit 1
  fi
fi

echo $$ > "$PID_FILE"
rm -f "$STOP_FILE"
trap cleanup SIGTERM SIGINT

# Obtener temperatura ambiente
echo "→ Obteniendo temperatura ambiente..."
TEMP_AMB=$(get_temp_ambiente)
TIEMPO_TOTAL=$(calcular_tiempo_total "$TEMP_AMB")
echo "→ Temperatura ambiente: ${TEMP_AMB}°C"
echo "→ El té se enfriará en ~${TIEMPO_TOTAL} minutos. ¡Que lo disfrutes!"


# Loop principal
MINUTOS=0
while true; do
  sleep $(( INTERVALO_MIN * 60 )) &
  SLEEP_PID=$!

  # Escuchar el archivo de stop mientras duerme
  while kill -0 "$SLEEP_PID" 2>/dev/null; do
    if [[ -f "$STOP_FILE" ]]; then
      kill "$SLEEP_PID" 2>/dev/null
      notify-send --urgency=low --app-name="Té" --icon="$ICON" "Buen provecho" "¡Recordatorio detenido!"
      cleanup
    fi
    sleep 2
  done

  MINUTOS=$(( MINUTOS + INTERVALO_MIN ))
  TEMP_ACTUAL=$(calcular_temp_actual "$MINUTOS" "$TEMP_AMB")
  TEMP_INT=$(printf "%.0f" "$TEMP_ACTUAL")

  # ¿Ya se enfrió?
  if (( TEMP_INT <= TEMP_LIMITE )); then
    notify-send \
      --urgency=critical \
      --app-name="Té" \
      --icon="$ICON" \
      "Té frío ❄️" "El te se ha enfriado."
    cleanup
  fi

  # Notificación de recordatorio con botón de stop
  enviar_notificacion "Té" "~$(( TIEMPO_TOTAL - MINUTOS )) min" "normal" &
done