export EDITOR="emacs -nw"

if which code &>/dev/null; then
    if [[ -n $WAYLAND_DISPLAY ]]; then
        # workaround for Electron rendering incorrectly in Wayland
        alias code='code --enable-features=Vulkan'
        export VISUAL="code --enable-features=Vulkan -w"
    else
        export VISUAL="code -w"
    fi
fi
