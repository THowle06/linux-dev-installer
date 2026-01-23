#######################################
# Safer defaults
#######################################

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'

#######################################
# Git
#######################################

alias g='git'
alias gs='git status'
alias gss='git status -s'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gca='git commit --amend'
alias gcm='git commit -m'
alias gcb='git checkout -b'
alias grs='git restore --staged'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gl='git pull'
alias gd='git diff'
alias gds='git diff --staged'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gco='git checkout'
alias glg='git log --oneline --graph --decorate'
alias glga='git log --oneline --graph --decorate --all'
alias gst='git stash'
alias gstp='git stash pop'

#######################################
# Navigation
#######################################

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ll='ls -alF'
alias la='ls -A'
alias l='la -CF'
alias tree='tree -C'

#######################################
# Docker
#######################################

alias d='docker'
alias dc='docker compose'
alias dcu='docker compose up'
alias dcd='docker compose down'
alias dcb='docker compose build'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs -f'
alias dclean='docker system prune -f'
alias dcleanall='docker system prune -af --volumes'

#######################################
# Development
#######################################

# Python
alias py='python3'
alias pipu='pip install --user'
alias venv='python3 -m venv .venv && source .venv/bin/activate'
alias activate='source .venv/bin/activate'
alias serve='python3 -m http.server'

# Node.js
alias ni='npm install'
alias nid='npm install --save-dev'
alias nr='npm run'
alias nrs='npm run start'
alias nrt='npm run test'
alias nrb='npm run build'

# Rust
alias c='cargo'
alias cb='cargo build'
alias cbr='cargo build --release'
alias ct='cargo test'
alias cr='cargo run'
alias cc='cargo check'
alias ccl='cargo clippy'

# Go
alias gob='go build'
alias got='go test'
alias gor='go run'
alias gom='go mod'
alias gomt='go mod tidy'

# .NET
alias dn='dotnet'
alias dnb='dotnet build'
alias dnt='dotnet test'
alias dnr='dotnet run'
alias dnw='dotnet watch run'

# Haskell
alias cab='cabal'
alias cabb='cabal build'
alias cabt='cabal test'
alias cabr='cabal run'

#######################################
# System & Monitoring
#######################################

alias ports='netstat -tulanp'
alias disk='df -h'
alias mem='free -h'
alias cpu='lscpu'

#######################################
# Quality of Life
#######################################

alias reload='exec bash'
alias path='echo -e ${PATH//:/\\n}'
alias h='history'
alias hg='history | grep'
alias update='sudo apt update && sudo apt upgrade -y'
alias cls='clear'