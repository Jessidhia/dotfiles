if [[ "$OSTYPE" = darwin* ]]; then
    export PKG_CONFIG_LIBDIR="/usr/local/lib/pkgconfig:/opt/X11/lib/pkgconfig:/usr/lib/pkgconfig"
#    export SSL_CERT_FILE="/usr/local/etc/openssl/ca-bundle.crt"
fi
