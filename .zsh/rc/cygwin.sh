
function _wrap_exe_if_exists() {
    if [ -n "$1" ]; then
        wrap_exe "$1"
    fi
}

function _wrap_exe_bg_if_exists() {
    if [ -n "$1" ]; then
        wrap_exe "$1" '&'
    fi
}

if [[ "`uname`" =~ "CYGWIN" ]]; then
    _wrap_exe_if_exists /cygdrive/c/Program*/VideoLAN/VLC/vlc.exe(N)
    _wrap_exe_bg_if_exists /cygdrive/c/Program*/Sublime\ Text\ 2/sublime_text.exe(N)
    alias st=sublime_text

    ulimit -c 0
fi
