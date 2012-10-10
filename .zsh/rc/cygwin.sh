
function _wrap_exe_if_exists() {
    exe_path="$(find "$@" | head -n1)"
    if [ -n "$exe_path" ]; then
        wrap_exe "$exe_path"
    fi
}

function _wrap_exe_bg_if_exists() {
    exe_path="$(find "$@" | head -n1)"
    if [ -n "$exe_path" ]; then
        wrap_exe "$exe_path" '&'
    fi
}

if [[ "`uname`" =~ "CYGWIN" ]]; then
    _wrap_exe_if_exists /cygdrive/c/Program*/VideoLAN/VLC/vlc.exe
    _wrap_exe_bg_if_exists /cygdrive/c/Program*/Sublime\ Text\ 2/sublime_text.exe
    alias st=sublime_text
fi
