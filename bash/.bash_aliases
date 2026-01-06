#######################################
# Safer defaults
#######################################

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

#######################################
# Git
#######################################

alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gca='git commit --amend'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

#######################################
# Navigation
#######################################

alias ll='ls -alF'
alias la='ls -A'
alias l='la -CF'

#######################################
# Docker
#######################################

alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias di='docker images'

#######################################
# Development
#######################################

alias py='python3'
alias pipu='pip install --user'
alias serve='python3 -m http.server'

#######################################
# Quality of Life
#######################################

alias reload='exec bash'
alias path='echo -e ${PATH//:/\\n}'