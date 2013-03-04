
if [ -f "/etc/DIR_COLORS" ] && dircolors --version &>/dev/null; then
    eval `dircolors -b /etc/DIR_COLORS`
fi
