
if ! [ -e "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    pushd "$HOME"
    git submodule update --init
    sh bin/update-subrepos.sh
    popd
fi
