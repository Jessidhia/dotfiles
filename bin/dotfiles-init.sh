
if ! [ -d "$HOME/.rbenv/plugins/ruby-build" ]; then
    mkdir -p "$HOME/.rbenv/plugins"
    git clone git://github.com/sstephenson/ruby-build.git "$HOME/.rbenv/plugins/ruby-build"
fi

if ! [ -d "$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting" ]; then
    git clone git://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting"
fi
