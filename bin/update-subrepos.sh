
clone_or_pull () {
    git_src="$1"
    clone_dst="$2"

    if ! [ -d "$clone_dst" ]; then
        mkdir -p "$(dirname "$clone_dst")"
        git clone "$git_src" "$clone_dst"
    else
        pushd "$clone_dst"
        git pull
        popd
    fi
}

clone_or_pull git://github.com/sstephenson/ruby-build.git            "$HOME/.rbenv/plugins/ruby-build"
clone_or_pull git://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting"

