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
alias gcm='git commit -m'
alias gcb='git checkout -b'
alias grs='git restore --staged'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias glg='git log --oneline --graph --decorate'

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
alias dlogs='docker logs -f'
alias dclean='docker system prune -f'

#######################################
# Development
#######################################

# Python
alias py='python3'
alias pipu='pip install --user'
alias venv='python3 -m venv .venv && source .venv/bin/activate'
alias serve='python3 -m http.server'

# Node.js
alias ni='npm install'
alias nr='npm run'

# Rust
alias c='cargo'
alias cb='cargo build'
alias ct='cargo test'
alias cr='cargo run'

# Go
alias gob='go build'
alias got='go test'
alias gor='go run'

# .NET
alias dn='dotnet'
alias dnb='dotnet build'
alias dnt='dotnet test'
alias dnr='dotnet run'

# Haskell
alias cab='cabal'
alias cabb='cabal build'
alias cabt='cabal test'

#######################################
# Quality of Life
#######################################

alias reload='exec bash'
alias path='echo -e ${PATH//:/\\n}'