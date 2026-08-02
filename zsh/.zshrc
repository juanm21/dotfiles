# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

fpath=(/usr/share/zsh/$ZSH_VERSION/functions $fpath)

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k" #"agnoster"

zstyle ':omz:update' mode reminder  # just remind me to update when it's time
zstyle ':omz:update' frequency 15

plugins=(git)

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='hx'
fi

export PATH=$PATH:/usr/local/bin
export DOTNET_ROOT=/usr/local/share/dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
export PATH=$PATH:$HOME/.local/tools/netcoredbg

alias python="python3"
alias pip="pip3"
alias check_ssl='~/DEV/RevisarCertificadoSSL/ConsoleApp/bin/Release/net10.0/osx-arm64/publish/ConsoleApp'

# nvm (instalado con brew)
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/juanm/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

alias g4='echo "g4_26_xl - g4_26_m - g4_26_xxs"'
alias g4_26_xl='llama-cli -m /Users/juanm/IA/Models/gemma-4-26B-A4B-it-UD-Q8_K_XL.gguf'
alias g4_26_m='llama-cli -m /Users/juanm/IA/Models/gemma-4-26B-A4B-it-UD-Q4_K_M.gguf'
alias g4_26_xxs='llama-cli -m /Users/juanm/IA/Models/gemma-4-26B-A4B-it-UD-IQ2_XXS.gguf'

alias nvim_tutor='nvim --clean -c Tutor'

# Alias para Bat (reemplazo de cat)
alias cat="bat"

# Alias para Eza (reemplazo de ls)
alias ls="eza"
alias ll="eza -lh"
alias la="eza -lah"
alias tree="eza --tree"

alias e="eza"
alias ea="e -la --header"
alias eg="e -l --git --git-repos --header"

alias gco="git branch | fzf --preview 'git show --color=always {-1}' \
                 --bind 'enter:become(git checkout {-1})' \
                 --height 40% --layout reverse"

export FZF_DEFAULT_OPTS=$'--info=right
  --highlight-line
  --header-first
  --color=fg:#c9d1d9,bg:#0d1117,hl:#79c0ff,fg+:#c9d1d9,bg+:#161b22
  --color=hl+:#a5d6ff,info:#8b949e,prompt:#58a6ff,pointer:#f85149
  --color=marker:#ff7b72,spinner:#3fb950,header:#79c0ff,border:#30363d
  --color=label:#8b949e,gutter:#161b22,footer:#8b949e'
                 
source <(fzf --zsh)


# Hermes Agent — ensure ~/.local/bin is on PATH
export PATH="$HOME/.local/bin:$PATH"

# Zoxide (reemplazo inteligente de cd)
eval "$(zoxide init zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Completion for azure-cli
autoload bashcompinit && bashcompinit
source $(brew --prefix)/etc/bash_completion.d/az

precmd() {
    print -rn -- $'\e[1 q'
}

echo -ne '\e[1 q'
