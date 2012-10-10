
if [ "$(/bin/uname)" = "Darwin" -a -d "/usr/local/bin" ]; then
    export PATH="/usr/local/bin:$PATH"
fi
