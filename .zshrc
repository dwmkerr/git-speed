# ========================================
#                   Git
# ========================================
alias gds="git diff --staged"
alias grpo="git remote prune origin"
alias gr="git reset"

# clone repository and directly cd into it
# todo: remove .git if present in url
gclone() {
  git clone "$1" && cd "$(basename "$1")"
}

# squash all commits into one
gsquash-all() {
  git reset $(git commit-tree HEAD^{tree} -m \"${1:-Init}\")
}

# ========================================
#              NPM Aliases
# ========================================
alias ns="npm start"
alias nt="npm test"
alias ntc="npm run test:coverage"
alias ntd="npm run test:debug"
alias nr="npm run"

# ========================================
#            Directory Aliases
# ========================================
alias gh="cd /Users/$USER/Desktop/github"

# ========================================
#              Other Aliases
# ========================================
alias \?="alias | grep "
alias size="du -sh"
alias diskspace="df -BG"

# check what process is running on a given port
pidportfunction() {
  lsof -n -i4TCP:$1 | grep LISTEN
}
alias pidport=pidportfunction
