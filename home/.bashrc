#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
export EDITOR='nvim'
export VISUAL='code'
alias vi='nvim'
alias vim='nvim'
alias zed="zeditor"

export XDG_DATA_DIRS="$XDG_DATA_DIRS:$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share"
export PS1="\[\e[36m\]╭─\[\e[34m\][\u@\h] \[\e[32m\]\w\n\[\e[36m\]╰─❯ \[\e[0m\]"


# "te"="te 1"=cristal    "te=2"=ceramica
te() {
  local opcion=${1:-1}
  nohup ~/.local/bin/tea_reminder.sh "$opcion" &> /tmp/te-reminder.log &
  sleep 0.5
  if kill -0 $! 2>/dev/null; then
    echo "→ Recordatorio de té iniciado (opción $opcion)"
  else
    echo "→ Ya hay un recordatorio activo."
  fi
}
