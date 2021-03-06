# options
develop=
release=
RELEASE_DIR="spidermonkey-android"

usage(){
cat << EOF
usage: $0 [options]

Build SpiderMonkey using Android NDK

OPTIONS:
-d	Build for development
-r  Build for release. specify RELEASE_DIR.
-h	this help

EOF
}

while getopts "drh" OPTION; do
case "$OPTION" in
d)
develop=1
;;
r)
release=1
;;
h)
usage
exit 0
;;
esac
done

set -x

host_os=`uname -s | tr "[:upper:]" "[:lower:]"`

../configure --with-android-ndk=$HOME/bin/android-ndk \
             --with-android-sdk=$HOME/bin/android-sdk \
             --with-android-version=9 \
             --enable-application=mobile/android \
             --with-android-gnu-compiler-version=4.6 \
             --enable-android-libstdcxx \
             --target=arm-linux-androideabi \
             --disable-shared-js \
             --disable-tests \
             --enable-strip \
             --enable-install-strip \
             --enable-debug \
             --disable-ion \
             --disable-jm \
             --disable-tm

# make
make -j15

if [[ $develop ]]; then
    rm -rf ../../../include
    rm -rf ../../../lib

    ln -s -f "$PWD"/dist/include ../../..
    ln -s -f "$PWD"/dist/lib ../../..
fi

if [[ $release ]]; then
# copy specific files from dist
    rm -r "$RELEASE_DIR/include"
    rm -r "$RELEASE_DIR/lib"
    mkdir -p "$RELEASE_DIR/include"
    cp -RL dist/include/* "$RELEASE_DIR/include/"
    mkdir -p "$RELEASE_DIR/lib"
    cp -L dist/lib/libjs_static.a "$RELEASE_DIR/lib/libjs_static.a"

# strip unneeded symbols
    $HOME/bin/android-ndk/toolchains/arm-linux-androideabi-4.6/prebuilt/${host_os}-x86/bin/arm-linux-androideabi-strip \
        --strip-unneeded "$RELEASE_DIR/lib/libjs_static.a"
fi
