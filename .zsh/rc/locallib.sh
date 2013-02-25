
if [ -d "$HOME/perl5/lib" -a -z "$PERL_LOCAL_LIB_ROOT" ]; then
    export PERL_LOCAL_LIB_ROOT="$HOME/perl5"
    mkdir -p "$PERL_LOCAL_LIB_ROOT/man/man1" "$PERL_LOCAL_LIB_ROOT/man/man3" "$PERL_LOCAL_LIB_ROOT/bin"
    export PATH="$PERL_LOCAL_LIB_ROOT/bin:$PATH"

    export PERL_MB_OPT="--install_base $PERL_LOCAL_LIB_ROOT"

    export PERL_MM_OPT="INSTALL_BASE=$PERL_LOCAL_LIB_ROOT LIB=$PERL_LOCAL_LIB_ROOT/lib"
    export PERL_MM_OPT="$PERL_MM_OPT INSTALLSITEMAN1DIR=$PERL_LOCAL_LIB_ROOT/man/man1"
    export PERL_MM_OPT="$PERL_MM_OPT INSTALLSITEMAN3DIR=$PERL_LOCAL_LIB_ROOT/man/man3"
    
    export PERL5LIB="$PERL_LOCAL_LIB_ROOT/lib/perl5/$(perl -MConfig -e'print $Config{archname}'):$PERL_LOCAL_LIB_ROOT/lib/perl5"
    
    export MANPATH="$MANPATH:$PERL_LOCAL_LIB_ROOT/man"

    #export PERL_MM_USE_DEFAULT=1
fi
