_uname="$(test -x /usr/bin/uname && echo /usr/bin/uname || echo /bin/uname)"

if [ "$($_uname)" = "Darwin" -a -d "/usr/local/bin" ]; then
    export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
fi

if [[ "$($_uname)" =~ "CYGWIN" ]]; then
    export PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
fi
