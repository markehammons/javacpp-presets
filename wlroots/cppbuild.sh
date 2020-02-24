#!/bin/bash
# This file is meant to be included by the parent cppbuild.sh script
if [[ -z "$PLATFORM" ]]; then
    pushd ..
    bash cppbuild.sh "$@" wlroots
    popd
    exit
fi


WLROOTS_VERSION=0.10.0
WAYLAND_VERSION=1.18.0
LIBXML_VERSION=2.9.10
LIBPNG_VERSION=1.6.35
LIBFFI_VERSION=3.3
LIBEXPAT_VERSION=2.2.9
LIBEXPAT_TAG=2_2_9

download https://gitlab.gnome.org/GNOME/libxml2/-/archive/v$LIBXML_VERSION/libxml2-v$LIBXML_VERSION.tar.gz libxml2-v$LIBXML_VERSION.tar.gz
download https://github.com/libffi/libffi/archive/v$LIBFFI_VERSION.zip libffi-v$LIBFFI_VERSION.zip libffi-v$LIBFFI_VERSION
download https://github.com/libexpat/libexpat/releases/download/R_$(echo $LIBEXPAT_TAG | tr . _)/expat-$LIBEXPAT_VERSION.tar.gz expat-$LIBEXPAT_VERSION.tar.gz
download https://github.com/glennrp/libpng/archive/v$LIBPNG_VERSION.zip libpng-v$LIBPNG_VERSION.zip
download https://github.com/swaywm/wlroots/archive/$WLROOTS_VERSION.zip wlroots-$WLROOTS_VERSION.zip
download https://github.com/wayland-project/wayland/archive/$WAYLAND_VERSION.zip wayland-$WAYLAND_VERSION.zip

case $PLATFORM in
    linux-x86_64)
        mkdir $PLATFORM
        cd $PLATFORM
        INSTALL_PATH=`pwd`
        echo "decompressing archives..."
        tar xvf ../libxml2-v$LIBXML_VERSION.tar.gz
        tar xvf ../expat-$LIBEXPAT_VERSION.tar.gz
        unzip ../libffi-v$LIBFFI_VERSION.zip
        unzip ../libpng-v$LIBPNG_VERSION.zip
        unzip ../wayland-$WAYLAND_VERSION.zip
        unzip ../wlroots-$WLROOTS_VERSION.zip


        cd libxml2-v$LIBXML_VERSION
        ./autogen.sh prefix=$INSTALL_PATH --without-python
        make -j $MAKEJ
        make install

        cd $INSTALL_PATH/libffi-$LIBFFI_VERSION
        ./autogen.sh prefix=$INSTALL_PATH
        ./configure --prefix=$INSTALL_PATH
        make -j $MAKEJ
        make install

        cd $INSTALL_PATH/expat-$LIBEXPAT_VERSION
        ./configure --prefix=$INSTALL_PATH
        make -j $MAKEJ
        make install

        cd $INSTALL_PATH/wayland-$WAYLAND_VERSION
        PKG_CONFIG_PATH="$INSTALL_PATH/lib64/pkgconfig:$INSTALL_PATH/lib/pkgconfig" ./autogen.sh prefix=$INSTALL_PATH --disable-documentation
        make -j $MAKEJ
        make install


        ### WLROOTS DEPENDENCIES

        cd $INSTALL_PATH/libpng-$LIBPNG_VERSION
        ./configure --prefix=$INSTALL_PATH
        make -j $MAKEJ
        make install

        cd $INSTALL_PATH/wlroots-$WLROOTS_VERSION
        PKG_CONFIG_PATH=$INSTALL_PATH/lib64/pkgconfig meson build
        PKG_CONFIG_PATH=$INSTALL_PATH/lib64/pkgconfig meson configure --prefix $INSTALL_PATH build
        ninja -j $MAKEJ -C build
        ninja -j $MAKEJ -C build install
        ;;
    *)
        echo "Error: Platform \"$PLATFORM\" is not supported"
        ;;
esac

cd ../..