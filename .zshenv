
if [ "$(/usr/bin/uname)" = "Darwin" -a -d "/usr/local/bin" ]; then
    export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
fi
