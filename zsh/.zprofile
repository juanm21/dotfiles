
eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# Add .NET Core SDK tools
export PATH="$PATH:/Users/juanm/.dotnet/tools"

# Hermes Agent — ensure ~/.local/bin is on PATH
export PATH="$HOME/.local/bin:$PATH"
