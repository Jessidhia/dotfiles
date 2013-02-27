#! /usr/bin/env zsh

clone_or_pull () {
    git_src="$1"
    clone_dst="$2"
    module_name="$3"

    if ! [ -d "$clone_dst" ]; then
        mkdir -p "$(dirname "$clone_dst")"
        git clone "$git_src" "$clone_dst"

        if [ -n "$module_name" ]; then
            in_module_path="$(echo "$2" | sed "s!.*$module_name/!!")"
            echo "$in_module_path" >> "$HOME/.git/modules/$module_name/info/exclude"
        fi
    else
        pushd "$clone_dst"
        git pull
        popd
    fi
}

clone_or_pull git://github.com/sstephenson/ruby-build.git            "$HOME/.rbenv/plugins/ruby-build"
clone_or_pull git://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting" ".oh-my-zsh"
