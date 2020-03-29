#!/bin/sh

echo "###############################################################################"
echo "# Script Summary:                                                             #"
echo "# Author:                  yu.zuo                                             #"
echo "# Update Date:             2020.03.23                                         #"
echo "# Script version:          1.0.0                                              #"
echo "# Url: https://github.com/AsteriskZuo/ffmpeg_build_scripts                    #"
echo "#                                                                             #"
echo "# Brief introduction:                                                         #"
echo "# This script implements ffmpeg library on iOS platform cross-compilation.    #"
echo "#                                                                             #"
echo "# Prerequisites:                                                              #"
echo "# GNU bash (version 3.2.57 test success on macOS)                             #"
echo "# gas-preprocessor for iOS, which can be download by github                   #"
echo "# yasm for iOS, which can be installed using brew                             #"
echo "# nasm for Android, which can be installed using brew                         #"
echo "# perl 5.18 (version 5.31 test fail) for gas-preprocessor.pl script           #"
echo "# python 2.7 for make_standalone_toolchain.py script                          #"
echo "# pkg-config for iOS and Android, which can be installed using brew           #"
echo "# curl for iOS and Android, which can be installed using brew                 #"
echo "# tar for iOS and Android, which can be installed using brew                  #"
echo "#                                                                             #"
echo "# Reference:                                                                  #"
echo "# Url: http://yasm.tortall.net/                                               #"
echo "# Url: https://developer.android.com/ndk/guides/cmake                         #"
echo "# Url: https://developer.android.com/ndk/guides/abis                          #"
echo "# Url: https://developer.android.com/ndk/guides/other_build_systems           #"
echo "# Url: https://developer.android.com/ndk/guides/standalone_toolchain          #"
echo "# Url: https://gcc.gnu.org/onlinedocs/gcc/index.html                          #"
echo "# Url: https://llvm.org/docs/genindex.html                                    #"
echo "# Url: https://blog.csdn.net/taiyang1987912/article/details/39551385          #"
echo "# Url: https://github.com/libav/gas-preprocessor                              #"
echo "# Url: https://github.com/nldzsz/ffmpeg-build-scripts                         #"
echo "# Url: https://github.com/kewlbear/FFmpeg-iOS-build-script                    #"
echo "###############################################################################"

echo "###############################################################################"
echo "#### Debug setting partition                                              #####"
echo "###############################################################################"

# set: usage: set [--abefhkmnptuvxBCHP] [-o option] [arg ...]
# read -n1 -p "Press any key to continue..."

FFMPEG_ENABLE_LOG_FILE="yes"

echo "FFMPEG_ENABLE_LOG_FILE=$FFMPEG_ENABLE_LOG_FILE"

echo "###############################################################################"
echo "#### Variable declarations partition                                      #####"
echo "###############################################################################"

FFMPEG_NAME="ffmpeg"
FFMPEG_VERSION="4.2.2"
FFMPEG_FULL_NAME=${FFMPEG_NAME}-${FFMPEG_VERSION}

FFMPEG_ROOT_DIR=$(pwd)
FFMPEG_SRC_DIR=${FFMPEG_ROOT_DIR}/${FFMPEG_FULL_NAME}
FFMPEG_SH_DIR=${FFMPEG_ROOT_DIR}
FFMPEG_TMP_DIR=${FFMPEG_ROOT_DIR}/ffmpeg_tmp

FFMPEG_CURRENT_DIR=""

FFMPEG_TMP_OS_TMP_DIR=""
FFMPEG_TMP_OS_OUTPUT_DIR=""
FFMPEG_TMP_OS_LIPO_DIR=""
FFMPEG_TMP_OS_LOG_DIR=""

FFMPEG_CURRENT_TARGET_OS=""
FFMPEG_CURRENT_ARCH=""

FFMPEG_LOG=""

# all build target system platform name
FFMPEG_ALL_TARGET_OS=("iOS" "Android")

# "armv7" "arm64" "i386" "x86_64"
# warning: "i386" is not test
FFMPEG_ALL_ARCH_ON_IOS=("armv7" "arm64" "x86_64")

# "armeabi" "armeabi-v7a" "arm64-v8a" "x86" "x86_64"
# error: "x86" can not compile success, detail "src/libswscale/x86/rgb2rgb_template.c:1666:13: error: inline assembly requires more registers than available"
# warning: "armeabi" is not test
FFMPEG_ALL_ARCH_ON_ANDROID=("armeabi-v7a" "arm64-v8a" "x86_64")

echo "FFMPEG_NAME=$FFMPEG_NAME"
echo "FFMPEG_VERSION=$FFMPEG_VERSION"
echo "FFMPEG_FULL_NAME=$FFMPEG_FULL_NAME"

echo "FFMPEG_ROOT_DIR=$FFMPEG_ROOT_DIR"
echo "FFMPEG_SRC_DIR=$FFMPEG_SRC_DIR"
echo "FFMPEG_SH_DIR=$FFMPEG_SH_DIR"
echo "FFMPEG_TMP_DIR=$FFMPEG_TMP_DIR"

echo "FFMPEG_CURRENT_DIR=$FFMPEG_CURRENT_DIR"

echo "FFMPEG_TMP_OS_TMP_DIR=$FFMPEG_TMP_OS_TMP_DIR"
echo "FFMPEG_TMP_OS_OUTPUT_DIR=$FFMPEG_TMP_OS_OUTPUT_DIR"
echo "FFMPEG_TMP_OS_LIPO_DIR=$FFMPEG_TMP_OS_LIPO_DIR"
echo "FFMPEG_TMP_OS_LOG_DIR=$FFMPEG_TMP_OS_LOG_DIR"

echo "FFMPEG_CURRENT_TARGET_OS=$FFMPEG_CURRENT_TARGET_OS"
echo "FFMPEG_CURRENT_ARCH=$FFMPEG_CURRENT_ARCH"

echo "FFMPEG_LOG=$FFMPEG_LOG"

echo "FFMPEG_ALL_TARGET_OS=${FFMPEG_ALL_TARGET_OS[@]}"
echo "FFMPEG_ALL_ARCH_ON_IOS=${FFMPEG_ALL_ARCH_ON_IOS[@]}"
echo "FFMPEG_ALL_ARCH_ON_ANDROID=${FFMPEG_ALL_ARCH_ON_ANDROID[@]}"

echo "###############################################################################"
echo "#### Variable declarations partition on Android                           #####"
echo "###############################################################################"

ANDROID_NDK_DIR="/Users/asteriskzuo/Library/Android/sdk/ndk-bundle"
ANDROID_HOST_TAG="darwin-x86_64"
ANDROID_TOOLCHAIN_DIR="$ANDROID_NDK_DIR/toolchains/llvm/prebuilt/$ANDROID_HOST_TAG"
ANDROID_MARCHS=("arm" "arm64" "x86" "x86_64")
ANDROID_ABIS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")

# Note: For 32-bit ARM, the compiler is prefixed with armv7a-linux-androideabi, but the binutils tools are prefixed
# with arm-linux-androideabi. For other architectures, the prefixes are the same for all tools.
ANDROID_ABI_TRIPLES=("armv7a-linux-androideabi" "aarch64-linux-android" "i686-linux-android" "x86_64-linux-android")

# <=19 use standalone toolchain which need manual compile by make_standalone_toolchain.py
# >19 use prebuilt toolchain from ndk-bundle
# >=21 support 64 bit arm
# >=23 support neon which supports ARM Advanced SIMD, commonly known as Neon, an optional instruction set extension for ARMv7 and ARMv8.
# Android 2.1(7) 5.0(21) 6.0(23) 10.0(29)
# suggest: use version 23 or later
# suggest: use Android prebuilt version toolchain
ANDROID_API=23
ANDROID_MIN_API=7
ANDROID_MAX_API=29
ANDROID_ENABLE_STANDALONE_TOOLCHAIN="no"

ANDROID_CURRENT_MARCH=""
ANDROID_CURRENT_ABI=""
ANDROID_CURRENT_TRIPLE=""
ANDROID_CURRENT_TOOLCHAIN_DIR=""

echo "ANDROID_NDK_DIR=$ANDROID_NDK_DIR"
echo "ANDROID_HOST_TAG=$ANDROID_HOST_TAG"
echo "ANDROID_TOOLCHAIN_DIR=$ANDROID_TOOLCHAIN_DIR"
echo "ANDROID_MARCHS=${ANDROID_MARCHS[@]}"
echo "ANDROID_ABIS=${ANDROID_ABIS[@]}"
echo "ANDROID_ABI_TRIPLES=${ANDROID_ABI_TRIPLES[@]}"

echo "ANDROID_API=$ANDROID_API"
echo "ANDROID_ENABLE_STANDALONE_TOOLCHAIN=$ANDROID_ENABLE_STANDALONE_TOOLCHAIN"

echo "ANDROID_CURRENT_MARCH=$ANDROID_CURRENT_MARCH"
echo "ANDROID_CURRENT_ABI=$ANDROID_CURRENT_ABI"
echo "ANDROID_CURRENT_TRIPLE=$ANDROID_CURRENT_TRIPLE"
echo "ANDROID_CURRENT_TOOLCHAIN_DIR=$ANDROID_CURRENT_TOOLCHAIN_DIR"

echo "###############################################################################"
echo "#### Function implementation partition                                    #####"
echo "###############################################################################"

function ffmpeg_test() {
    # special test function by man test commandline
    # $ man test
    if test 1 -eq 1; then
        echo "1 -eq 1"
    elif test 1 -eq 2; then
        echo "1 -eq 2"
    fi

    if test "str1" = "str2"; then
        echo "str1" = "str2"
    elif test "str1" != "str2"; then
        echo "str1" != "str2"
    fi

    if test -b ".gitignore"; then
        echo -b ".gitignore"
    elif test -c ".gitignore"; then
        echo -c ".gitignore"
    elif test -e ".gitignore"; then
        echo -e ".gitignore"
    else
        echo ! -b ".gitignore"
    fi

    if test -d "dir"; then
        echo -d "dir"
    else
        echo ! -d "dir"
    fi

    if test ! -d "dir2"; then
        echo ! -d "dir2"
    else
        echo -d "dir2"
    fi

    if [ ! -d "dir3" ]; then
        echo ! -d "dir3"
    else
        echo -d "dir3"
    fi

    a=18
    b=19
    c=17
    echo "a=$a b=$b c=$c"
    if [ $a -lt $b ]; then
        echo "a < b is true"
    else
        echo "a < b is false"
    fi

    if [ $a -lt $b -a $b -lt $c ]; then
        echo "a < b and b < c is true "
    else
        echo "a < b and b < c is false "
    fi

    # ANDROID_API=19
    # ANDROID_API=30
    # ANDROID_API=""
    # ANDROID_API="lla "
    # if [ $ANDROID_API -le 19 ]; then
    #     echo "ANDROID_API=$ANDROID_API is not support."
    #     exit 1
    # elif [ $ANDROID_MAX_API -lt $ANDROID_API ]; then
    #     echo "ANDROID_API=$ANDROID_API is not support."
    #     exit 1
    # else
    #     echo "ANDROID_API=$ANDROID_API is error."
    #     exit 1
    # fi
}

function ffmpeg_for_test() {
    for num in 1 2 3 4 5; do
        for char in "a" "b" "c" "d" "e"; do
            echo $num $char
        done
    done
}

function ffmpeg_params_test_internal() {
    echo "ffmpeg_params_test_internal start..."
    echo "ffmpeg_params_test_internal params count: " $#
    echo "ffmpeg_params_test_internal params : " $* "|" $$ "|" $! "|" $@ "|" $- "|" $?

    for ((i = 1; i <= $#; i++)); do
        echo "params["$i"]="$i
    done

    for param in $*; do
        echo "ffmpeg_params_test_internal param="$param
    done

    echo "ffmpeg_params_test_internal end..."
}

function ffmpeg_params_test() {
    echo "ffmpeg_params_test start..."
    ffmpeg_params_test_internal 2 3 4 5 6
    echo "ffmpeg_params_test end..."
}

function ffmpeg_output_log_control() {
    if [ "yes" != $FFMPEG_ENABLE_LOG_FILE ]; then
        FFMPEG_LOG=""
    fi
}

function ffmpeg_output_log_control_test() {
    rm -rf "test.log"
    ls -la >"test.log" 2>&1
    la -la >>"test.log" 2>&1
}

function ffmpeg_clean() {
    # clean tmp and output dir
    echo "ffmpeg_clean start..."
    if test -d $FFMPEG_TMP_DIR; then
        rm -rf $FFMPEG_TMP_DIR
    fi
    echo "ffmpeg_clean end..."
}

function ffmpeg_mkdir() {
    # make directory
    echo "ffmpeg_mkdir start..."
    if test ! -d $FFMPEG_TMP_DIR; then
        mkdir -p $FFMPEG_TMP_DIR
    fi
    echo "ffmpeg_mkdir end..."
}

function ffmpeg_prerequisites_ios() {
    echo "ffmpeg_prerequisites_ios start..."

    if [ ! $(which yasm) ]; then
        echo 'Yasm not found'
        if [ ! $(which brew) ]; then
            echo 'Homebrew not found. Trying to install...'
            echo "download url: https://raw.githubusercontent.com/Homebrew/install/master/install"
            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" ||
                exit 1
        fi
        echo 'Trying to install Yasm...'
        brew install yasm || exit 1
    fi

    if [ ! $(which gas-preprocessor.pl) ]; then
        echo 'gas-preprocessor.pl not found. Trying to install...'
        echo "download url: https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl"
        (curl -L https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl \
            -o /usr/local/bin/gas-preprocessor.pl &&
            chmod +x /usr/local/bin/gas-preprocessor.pl) ||
            exit 1
    fi

    echo "ffmpeg_prerequisites_ios end..."
}

function ffmpeg_prerequisites_android() {
    echo "ffmpeg_prerequisites_android start..."

    if [ "yes" = $ANDROID_ENABLE_STANDALONE_TOOLCHAIN ]; then

        ANDROID_TOOLCHAIN_DIR=$FFMPEG_ROOT_DIR/ffmpeg_android
        echo "ANDROID_TOOLCHAIN_DIR=$ANDROID_TOOLCHAIN_DIR"

        if [ ! -d ${ANDROID_TOOLCHAIN_DIR} ]; then
            mkdir -p $ANDROID_TOOLCHAIN_DIR
        fi

        for MARCH in ${ANDROID_MARCHS[@]}; do
            echo "MARCH=$MARCH"
            if [ ! -d ${ANDROID_TOOLCHAIN_DIR}/${MARCH} ]; then
                python ${ANDROID_NDK_DIR}/build/tools/make_standalone_toolchain.py \
                    --arch ${MARCH} \
                    --api ${ANDROID_API} \
                    --stl libc++ \
                    --install-dir=${ANDROID_TOOLCHAIN_DIR}/${MARCH} || exit 1
            fi
        done

        for MARCH in ${ANDROID_MARCHS[@]}; do
            export PATH=$PATH:${ANDROID_TOOLCHAIN_DIR}/${MARCH}/bin
        done

    fi

    echo "ffmpeg_prerequisites_android end..."
}

function ffmpeg_download_src() {
    echo "ffmpeg_download_src start..."

    if [ ! -r $FFMPEG_FULL_NAME ]; then
        echo 'FFmpeg source file not found. Trying to download...'
        echo "download url: http://www.ffmpeg.org/releases/$FFMPEG_FULL_NAME.tar.bz2"
        curl http://www.ffmpeg.org/releases/${FFMPEG_FULL_NAME}.tar.bz2 >${FFMPEG_FULL_NAME}.tar.bz2 || exit 1
        tar -x -f ${FFMPEG_FULL_NAME}.tar.bz2 || exit 1
    fi

    echo "ffmpeg_download_src end..."
}

function ffmpeg_prerequisites() {
    # download dependence softwares
    # update prerequisite variable
    echo "ffmpeg_prerequisites start..."

    ffmpeg_download_src
    ffmpeg_prerequisites_ios
    ffmpeg_prerequisites_android

    echo "ffmpeg_prerequisites end..."
}

function ffmpeg_lipo_iOS() {
    echo "ffmpeg_lipo_iOS start..."
    echo "ffmpeg_lipo_iOS param_count=" $# "param_content=" $@

    FROM_LIBRARY_DIR=${FFMPEG_TMP_OS_OUTPUT_DIR}
    TO_LIBRARY_DIR=${FFMPEG_TMP_OS_LIPO_DIR}

    echo "FROM_LIBRARY_DIR=$FROM_LIBRARY_DIR"
    echo "TO_LIBRARY_DIR=$TO_LIBRARY_DIR"

    LIBRARY_LIST=$(find ${FROM_LIBRARY_DIR}/${FFMPEG_ALL_ARCH_ON_IOS[0]} -name "*.a" | sed "s/^.*\///g")

    echo "LIBRARY_LIST=${LIBRARY_LIST[@]}"

    for LIBRARY_FILE in ${LIBRARY_LIST[@]}; do
        echo "LIBRARY_FILE=$LIBRARY_FILE"
        lipo -create $(find $FROM_LIBRARY_DIR -name $LIBRARY_FILE) -output $TO_LIBRARY_DIR/$LIBRARY_FILE || exit 1
    done

    echo "ffmpeg_lipo_iOS end..."
}

function ffmpeg_build_iOS() {
    echo "ffmpeg_build_iOS start..."
    echo "ffmpeg_build_iOS params_count="$# "params_content="$@

    DEPLOYMENT_MIN_TARGET="8.0"
    DEVICE_TYPE=""

    CFLAGS="-arch ${FFMPEG_CURRENT_ARCH} -std=c11"
    CXXFLAGS=${CFLAGS}
    LDFLAGS=${CFLAGS}
    AS=""
    CC=""

    TMP_DIR="${FFMPEG_TMP_OS_TMP_DIR}/${FFMPEG_CURRENT_ARCH}"
    OUTPUT_DIR="${FFMPEG_TMP_OS_OUTPUT_DIR}/${FFMPEG_CURRENT_ARCH}"
    PLATFORM_TRAIT=""

    CONFIGURE_PARAMS_PREFIX=${OUTPUT_DIR}
    CONFIGURE_PARAMS_SYSROOT=""
    CONFIGURE_PARAMS_TARGET_OS="darwin"
    CONFIGURE_PARAMS_AR=$(which ar)
    CONFIGURE_PARAMS_AS=$(which as)
    CONFIGURE_PARAMS_CC=$(which cc)
    CONFIGURE_PARAMS_CXX=$(which c++)
    CONFIGURE_PARAMS_LD=$(which ld)
    CONFIGURE_PARAMS_PKG_CONFIG=$(which pkg-config)

    if [ "armv7" = ${FFMPEG_CURRENT_ARCH} ]; then
        DEVICE_TYPE="iPhoneOS"
        CFLAGS="$CFLAGS -mios-version-min=$DEPLOYMENT_MIN_TARGET -fembed-bitcode"
        DEVICE_TYPE=$(echo ${DEVICE_TYPE} | tr '[:upper:]' '[:lower:]')
        CC="xcrun -sdk ${DEVICE_TYPE} clang"
        AS="gas-preprocessor.pl -- $CC"
    elif [ "arm64" = ${FFMPEG_CURRENT_ARCH} ]; then
        DEVICE_TYPE="iPhoneOS"
        CFLAGS="$CFLAGS -mios-version-min=$DEPLOYMENT_MIN_TARGET -fembed-bitcode"
        DEVICE_TYPE=$(echo ${DEVICE_TYPE} | tr '[:upper:]' '[:lower:]')
        CC="xcrun -sdk ${DEVICE_TYPE} clang"
        AS="gas-preprocessor.pl -arch aarch64 -- $CC"
    elif [ "i386" = ${FFMPEG_CURRENT_ARCH} ]; then
        DEVICE_TYPE="iPhoneSimulator"
        CFLAGS="${CFLAGS} -mios-simulator-version-min=$DEPLOYMENT_MIN_TARGET"
        DEVICE_TYPE=$(echo ${DEVICE_TYPE} | tr '[:upper:]' '[:lower:]')
        CC="xcrun -sdk ${DEVICE_TYPE} clang"
        AS="gas-preprocessor.pl -- $CC"
        PLATFORM_TRAIT=${PLATFORM_TRAIT}" --disable-programs"
    elif [ "x86_64" = ${FFMPEG_CURRENT_ARCH} ]; then
        DEVICE_TYPE="iPhoneSimulator"
        CFLAGS="${CFLAGS} -mios-simulator-version-min=$DEPLOYMENT_MIN_TARGET"
        DEVICE_TYPE=$(echo ${DEVICE_TYPE} | tr '[:upper:]' '[:lower:]')
        CC="xcrun -sdk ${DEVICE_TYPE} clang"
        AS="gas-preprocessor.pl -- $CC"
        PLATFORM_TRAIT=${PLATFORM_TRAIT}" --disable-programs"
    fi

    DEVICE_TYPE=$(echo ${DEVICE_TYPE} | tr '[:upper:]' '[:lower:]')
    # CONFIGURE_PARAMS_AR=$(xcrun -sdk ${DEVICE_TYPE} -f ar)
    CONFIGURE_PARAMS_AR="ar"
    CONFIGURE_PARAMS_AS=${AS}
    CONFIGURE_PARAMS_CC=${CC}
    # CONFIGURE_PARAMS_CXX=$(xcrun -sdk ${DEVICE_TYPE} -f clang++)
    CONFIGURE_PARAMS_CXX="clang++"
    CONFIGURE_PARAMS_LD=$(xcrun -sdk ${DEVICE_TYPE} -f ld)
    # CONFIGURE_PARAMS_LD="ld"
    CONFIGURE_PARAMS_SYSROOT=$(xcrun -sdk ${DEVICE_TYPE} --show-sdk-path)

    echo "DEPLOYMENT_MIN_TARGET=${DEPLOYMENT_MIN_TARGET}"
    echo "DEVICE_TYPE=${DEVICE_TYPE}"

    echo "CFLAGS=${CFLAGS}"
    echo "CXXFLAGS=${CXXFLAGS}"
    echo "LDFLAGS=${LDFLAGS}"
    echo "AS=${AS}"
    echo "CC=${CC}"

    echo "TMP_DIR=$TMP_DIR"
    echo "OUTPUT_DIR=$OUTPUT_DIR"
    echo "PLATFORM_TRAIT=$PLATFORM_TRAIT"

    echo "CONFIGURE_PARAMS_PREFIX=${CONFIGURE_PARAMS_PREFIX}"
    echo "CONFIGURE_PARAMS_SYSROOT=${CONFIGURE_PARAMS_SYSROOT}"
    echo "CONFIGURE_PARAMS_TARGET_OS=${CONFIGURE_PARAMS_TARGET_OS}"
    echo "CONFIGURE_PARAMS_AR=${CONFIGURE_PARAMS_AR}"
    echo "CONFIGURE_PARAMS_AS=${CONFIGURE_PARAMS_AS}"
    echo "CONFIGURE_PARAMS_CC=${CONFIGURE_PARAMS_CC}"
    echo "CONFIGURE_PARAMS_CXX=${CONFIGURE_PARAMS_CXX}"
    echo "CONFIGURE_PARAMS_LD=${CONFIGURE_PARAMS_LD}"
    echo "CONFIGURE_PARAMS_PKG_CONFIG=${CONFIGURE_PARAMS_PKG_CONFIG}"

    # Toolchain options:
    # CONFIGURE_PARAMS="--enable-cross-compile"
    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --sysroot=${CONFIGURE_PARAMS_SYSROOT}"
    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --target-os=${CONFIGURE_PARAMS_TARGET_OS}"
    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --arch=${FFMPEG_CURRENT_ARCH}"
    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --ar=${CONFIGURE_PARAMS_AR}"
    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --as=${CONFIGURE_PARAMS_AS}"
    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --cc=${CONFIGURE_PARAMS_CC}"
    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --ld=${CONFIGURE_PARAMS_LD}"
    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --pkg-config=${CONFIGURE_PARAMS_PKG_CONFIG}"
    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --enable-pic"
    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --extra-cflags=${CFLAGS}"
    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --extra-ldflags=${LDFLAGS}"

    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --prefix=${CONFIGURE_PARAMS_PREFIX}"

    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --disable-debug"
    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --disable-programs"
    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --disable-doc"

    # echo "CONFIGURE_PARAMS=${CONFIGURE_PARAMS}"

    # sh -x "./configure" ${CONFIGURE_PARAMS}

    CONFIGURE_FILE="${FFMPEG_SRC_DIR}/configure"
    echo "CONFIGURE_FILE=$CONFIGURE_FILE"

    pushd .

    cd ${TMP_DIR}

    sh $CONFIGURE_FILE \
        --prefix="${CONFIGURE_PARAMS_PREFIX}" \
        --enable-cross-compile \
        --target-os="${CONFIGURE_PARAMS_TARGET_OS}" \
        --arch="${FFMPEG_CURRENT_ARCH}" \
        --as="${CONFIGURE_PARAMS_AS}" \
        --cc="${CONFIGURE_PARAMS_CC}" \
        --enable-pic \
        --extra-cflags="${CFLAGS}" \
        --extra-ldflags="${LDFLAGS}" \
        ${PLATFORM_TRAIT} \
        --disable-debug \
        --disable-doc || exit 1

    # sh $CONFIGURE_FILE \
    #     "--prefix=${CONFIGURE_PARAMS_PREFIX}" \
    #     "--enable-cross-compile" \
    #     "--sysroot=${CONFIGURE_PARAMS_SYSROOT}" \
    #     "--target-os=${CONFIGURE_PARAMS_TARGET_OS}" \
    #     "--arch=${FFMPEG_CURRENT_ARCH}" \
    #     "--ar=${CONFIGURE_PARAMS_AR}" \
    #     "--as=${CONFIGURE_PARAMS_AS}" \
    #     "--cc=${CONFIGURE_PARAMS_CC}" \
    #     "--ld=${CONFIGURE_PARAMS_LD}" \
    #     "--pkg-config=${CONFIGURE_PARAMS_PKG_CONFIG}" \
    #     "--enable-pic" \
    #     "--extra-cflags=${CFLAGS}" \
    #     "--extra-ldflags=${LDFLAGS}" \
    #     "--disable-debug" \
    #     "--disable-programs" \
    #     "--disable-doc" ||
    #     exit 1

    make clean >${FFMPEG_LOG} || exit 1
    make -j4 install >>${FFMPEG_LOG} || exit 1

    popd

    echo "ffmpeg_build_iOS end..."
}

function ffmpeg_build_Android() {
    echo "ffmpeg_build_Android start..."
    echo "ffmpeg_build_Android params_count="$# "params_content="$@

    CURRENT_ARCH_FLAGS=""
    CURRENT_ARCH_LINK=""

    # ARCH_LIST from configure in ffmpeg src
    CURRENT_ARCH=""
    CURRENT_TRIPLE_armv7a=""
    CURRENT_CPU=""

    PKG_CONFIG="$(which pkg-config)"
    PLATFORM_TRAIT=""

    # ANDROID_MARCHS=("arm" "arm64" "x86" "x86_64")
    # ANDROID_ABIS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")
    # ANDROID_ABI_TRIPLES=("armv7a-linux-androideabi" "aarch64-linux-android" "i686-linux-android" "x86_64-linux-android")
    # ARCHS=("arm" "aarch64" "x86" "x86_64")

    if [ "armeabi" = ${FFMPEG_CURRENT_ARCH} ]; then
        CURRENT_ARCH_FLAGS="-mthumb"
        ANDROID_CURRENT_TRIPLE=${ANDROID_ABI_TRIPLES[0]}
        CURRENT_TRIPLE_armv7a="arm-linux-androideabi"
        ANDROID_CURRENT_ABI=${ANDROID_ABIS[0]}
        ANDROID_CURRENT_MARCH=${ANDROID_MARCHS[0]}
        CURRENT_ARCH="arm"
    elif [ "armeabi-v7a" = ${FFMPEG_CURRENT_ARCH} ]; then
        if [ 19 -lt $ANDROID_API -a $ANDROID_API -lt 23 ]; then
            CURRENT_ARCH_FLAGS="-march=armv7-a -mfloat-abi=softfp -mthumb -mfpu=vfpv3-d16"
        elif [ 23 -le $ANDROID_API ]; then
            CURRENT_ARCH_FLAGS="-march=armv7-a -mfloat-abi=softfp -mthumb -mfpu=neon"
        fi
        CURRENT_ARCH_LINK="-march=armv7-a -Wl,--fix-cortex-a8"
        ANDROID_CURRENT_TRIPLE=${ANDROID_ABI_TRIPLES[0]}
        CURRENT_TRIPLE_armv7a="arm-linux-androideabi"
        ANDROID_CURRENT_ABI=${ANDROID_ABIS[0]}
        ANDROID_CURRENT_MARCH=${ANDROID_MARCHS[0]}
        CURRENT_CPU="cortex-a8"
        CURRENT_ARCH="arm"
        PLATFORM_TRAIT=${PLATFORM_TRAIT}" --enable-neon"
    elif [ "arm64-v8a" = ${FFMPEG_CURRENT_ARCH} ]; then
        ANDROID_CURRENT_TRIPLE=${ANDROID_ABI_TRIPLES[1]}
        CURRENT_TRIPLE_armv7a=$ANDROID_CURRENT_TRIPLE
        ANDROID_CURRENT_ABI=${ANDROID_ABIS[1]}
        ANDROID_CURRENT_MARCH=${ANDROID_MARCHS[1]}
        CURRENT_ARCH="aarch64"
        PLATFORM_TRAIT=${PLATFORM_TRAIT}" --enable-neon"
    elif [ "x86" = ${FFMPEG_CURRENT_ARCH} ]; then
        CURRENT_ARCH_FLAGS="-march=i686 -mtune=intel -msse3 -mfpmath=sse -m32"
        ANDROID_CURRENT_TRIPLE=${ANDROID_ABI_TRIPLES[2]}
        CURRENT_TRIPLE_armv7a=$ANDROID_CURRENT_TRIPLE
        ANDROID_CURRENT_ABI=${ANDROID_ABIS[2]}
        ANDROID_CURRENT_MARCH=${ANDROID_MARCHS[2]}
        CURRENT_ARCH="x86"
        PLATFORM_TRAIT=${PLATFORM_TRAIT}" --enable-x86asm --disable-programs"
    elif [ "x86_64" = ${FFMPEG_CURRENT_ARCH} ]; then
        CURRENT_ARCH_FLAGS="-march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=intel"
        ANDROID_CURRENT_TRIPLE=${ANDROID_ABI_TRIPLES[3]}
        CURRENT_TRIPLE_armv7a=$ANDROID_CURRENT_TRIPLE
        ANDROID_CURRENT_ABI=${ANDROID_ABIS[3]}
        ANDROID_CURRENT_MARCH=${ANDROID_MARCHS[3]}
        CURRENT_ARCH="x86_64"
        PLATFORM_TRAIT=${PLATFORM_TRAIT}" --disable-programs"
    else
        echo "FFMPEG_CURRENT_ARCH=$FFMPEG_CURRENT_ARCH is error."
        exit 1
    fi

    if [ "yes" = $ANDROID_ENABLE_STANDALONE_TOOLCHAIN ]; then
        ANDROID_CURRENT_TOOLCHAIN_DIR=${ANDROID_TOOLCHAIN_DIR}/${ANDROID_CURRENT_MARCH}
    else
        ANDROID_CURRENT_TOOLCHAIN_DIR=${ANDROID_TOOLCHAIN_DIR}
    fi

    export AR=${ANDROID_CURRENT_TOOLCHAIN_DIR}/bin/${CURRENT_TRIPLE_armv7a}-ar
    export AS=${ANDROID_CURRENT_TOOLCHAIN_DIR}/bin/${CURRENT_TRIPLE_armv7a}-as
    export LD=${ANDROID_CURRENT_TOOLCHAIN_DIR}/bin/${CURRENT_TRIPLE_armv7a}-ld
    export STRIP=${ANDROID_CURRENT_TOOLCHAIN_DIR}/bin/${CURRENT_TRIPLE_armv7a}-strip
    export NM=${ANDROID_CURRENT_TOOLCHAIN_DIR}/bin/${CURRENT_TRIPLE_armv7a}-nm

    if [ "yes" = $ANDROID_ENABLE_STANDALONE_TOOLCHAIN ]; then
        export CC=${ANDROID_CURRENT_TOOLCHAIN_DIR}/bin/${CURRENT_TRIPLE_armv7a}-gcc
        export CXX=${ANDROID_CURRENT_TOOLCHAIN_DIR}/bin/${CURRENT_TRIPLE_armv7a}-g++
    else
        export CC=${ANDROID_CURRENT_TOOLCHAIN_DIR}/bin/${ANDROID_CURRENT_TRIPLE}${ANDROID_API}-clang
        export CXX=${ANDROID_CURRENT_TOOLCHAIN_DIR}/bin/${ANDROID_CURRENT_TRIPLE}${ANDROID_API}-clang++
    fi

    if [ $ANDROID_API -lt 19 ]; then
        export CFLAGS="${CURRENT_ARCH_FLAGS} -std=c11 -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing"
        export CXXFLAGS="${CFLAGS} -std=c++11 -frtti -fexceptions"
        export LDFLAGS="${CURRENT_ARCH_LINK}"
    else

        if [ "armeabi" = ${FFMPEG_CURRENT_ARCH} ]; then
            export CFLAGS="${CURRENT_ARCH_FLAGS} -std=c11 -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing"
        elif [ "armeabi-v7a" = ${FFMPEG_CURRENT_ARCH} ]; then
            export CFLAGS="${CURRENT_ARCH_FLAGS} -mcpu=${CURRENT_CPU} -std=c11 -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -DANDROID -DNDEBUG -D__ANDROID_API__=$ANDROID_API"
        elif [ "arm64-v8a" = ${FFMPEG_CURRENT_ARCH} ]; then
            export CFLAGS="${CURRENT_ARCH_FLAGS} -std=c11 -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -DANDROID -DNDEBUG -D__ANDROID_API__=$ANDROID_API"
        elif [ "x86" = ${FFMPEG_CURRENT_ARCH} ]; then
            export CFLAGS="${CURRENT_ARCH_FLAGS} -std=c11 -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing"
        elif [ "x86_64" = ${FFMPEG_CURRENT_ARCH} ]; then
            export CFLAGS="${CURRENT_ARCH_FLAGS} -std=c11 -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing"
        fi

        export CXXFLAGS="-std=c++11 -frtti -fexceptions"
        export LDFLAGS="${CURRENT_ARCH_LINK}"
        export RANLIB=${ANDROID_CURRENT_TOOLCHAIN_DIR}/bin/${CURRENT_TRIPLE_armv7a}-ranlib
    fi

    TMP_DIR="${FFMPEG_TMP_OS_TMP_DIR}/${FFMPEG_CURRENT_ARCH}"
    OUTPUT_DIR="${FFMPEG_TMP_OS_OUTPUT_DIR}/${FFMPEG_CURRENT_ARCH}"

    CONFIGURE_PARAMS_PREFIX=${OUTPUT_DIR}
    CONFIGURE_PARAMS_TARGET_OS="android"
    CONFIGURE_PARAMS_SYSROOT=""

    echo "CURRENT_ARCH_FLAGS=$CURRENT_ARCH_FLAGS"
    echo "CURRENT_ARCH_LINK=$CURRENT_ARCH_LINK"

    echo "ANDROID_CURRENT_TRIPLE=$ANDROID_CURRENT_TRIPLE"
    echo "ANDROID_CURRENT_ABI=$ANDROID_CURRENT_ABI"
    echo "ANDROID_CURRENT_MARCH=$ANDROID_CURRENT_MARCH"

    echo "CURRENT_ARCH=$CURRENT_ARCH"
    echo "CURRENT_TRIPLE_armv7a=$CURRENT_TRIPLE_armv7a"
    echo "CURRENT_CPU=$CURRENT_CPU"

    echo "export AR=$AR"
    echo "export AS=$AS"
    echo "export CC=$CC"
    echo "export CXX=$CXX"
    echo "export LD=$LD"
    echo "export STRIP=$STRIP"
    echo "export CFLAGS=$CFLAGS"
    echo "export CXXFLAGS=$CXXFLAGS"
    echo "export LDFLAGS=$LDFLAGS"
    echo "export RANLIB=$RANLIB"
    echo "export NM=$NM"

    echo "TMP_DIR=$TMP_DIR"
    echo "OUTPUT_DIR=$OUTPUT_DIR"
    echo "CONFIGURE_PARAMS_PREFIX=$CONFIGURE_PARAMS_PREFIX"

    echo "CONFIGURE_PARAMS_TARGET_OS=$CONFIGURE_PARAMS_TARGET_OS"
    echo "CONFIGURE_PARAMS_SYSROOT=$CONFIGURE_PARAMS_SYSROOT"

    echo "PKG_CONFIG=$PKG_CONFIG"
    echo "PLATFORM_TRAIT=${PLATFORM_TRAIT}"

    CONFIGURE_FILE="${FFMPEG_SRC_DIR}/configure"
    echo "CONFIGURE_FILE=$CONFIGURE_FILE"

    pushd .

    cd ${TMP_DIR}

    sh $CONFIGURE_FILE \
        --prefix="${CONFIGURE_PARAMS_PREFIX}" \
        --enable-cross-compile \
        --target-os=android \
        --arch="${CURRENT_ARCH}" \
        --cc="${CC}" \
        --cxx="${CXX}" \
        --disable-debug \
        --enable-shared \
        --enable-thumb \
        --enable-pic \
        ${PLATFORM_TRAIT} \
        --pkg-config="${PKG_CONFIG}" \
        --extra-cflags="${CFLAGS}" \
        --extra-cxxflags="${CXXFLAGS}" \
        --extra-ldflags="${LDFLAGS}" || exit 1

    # sh $CONFIGURE_FILE \
    #     --prefix="${CONFIGURE_PARAMS_PREFIX}" \
    #     --enable-cross-compile \
    #     --target-os=android \
    #     --arch=arm \
    #     --cc="${CC}" \
    #     --cxx="${CXX}" \
    #     --disable-debug \
    #     --enable-shared \
    #     --enable-neon \
    #     --enable-thumb \
    #     --enable-pic \
    #     --pkg-config="/usr/local/bin/pkg-config" \
    #     --extra-cflags="-march=armv7-a -mcpu=cortex-a8 -mfpu=vfpv3-d16 -mfloat-abi=softfp -mthumb -mfpu=neon -O3 -Wall -pipe -std=c11 -ffast-math -fstrict-aliasing -Werror=strict-aliasing -Wa,--noexecstack -DANDROID -DNDEBUG " \
    #     --extra-cxxflags="${CXXFLAGS}" \
    #     --extra-ldflags="-Wl,--fix-cortex-a8" || exit 1

    make clean >${FFMPEG_LOG} || exit 1
    make -j4 install >>${FFMPEG_LOG} || exit 1

    popd

    echo "ffmpeg_build_Android end..."
}

function ffmpeg_build_all() {
    echo "ffmpeg_build_all start..."

    for ((i = 0; i < ${#FFMPEG_ALL_TARGET_OS[@]}; i++)); do

        FFMPEG_CURRENT_TARGET_OS=${FFMPEG_ALL_TARGET_OS[i]}
        FFMPEG_TMP_OS_LOG_DIR="${FFMPEG_TMP_DIR}/${FFMPEG_CURRENT_TARGET_OS}/log"
        FFMPEG_TMP_OS_OUTPUT_DIR="${FFMPEG_TMP_DIR}/${FFMPEG_CURRENT_TARGET_OS}/output"
        FFMPEG_TMP_OS_TMP_DIR="${FFMPEG_TMP_DIR}/${FFMPEG_CURRENT_TARGET_OS}/tmp"
        FFMPEG_TMP_OS_LIPO_DIR="${FFMPEG_TMP_DIR}/${FFMPEG_CURRENT_TARGET_OS}/lipo"

        echo "FFMPEG_CURRENT_TARGET_OS=${FFMPEG_CURRENT_TARGET_OS}"
        echo "FFMPEG_TMP_OS_LOG_DIR=${FFMPEG_TMP_OS_LOG_DIR}"
        echo "FFMPEG_TMP_OS_OUTPUT_DIR=${FFMPEG_TMP_OS_OUTPUT_DIR}"
        echo "FFMPEG_TMP_OS_TMP_DIR=${FFMPEG_TMP_OS_TMP_DIR}"
        echo "FFMPEG_TMP_OS_LIPO_DIR=${FFMPEG_TMP_OS_LIPO_DIR}"

        mkdir -p ${FFMPEG_TMP_OS_LOG_DIR}
        mkdir -p ${FFMPEG_TMP_OS_OUTPUT_DIR}
        mkdir -p ${FFMPEG_TMP_OS_TMP_DIR}
        mkdir -p ${FFMPEG_TMP_OS_LIPO_DIR}

        if [ "iOS" = $FFMPEG_CURRENT_TARGET_OS ]; then
            echo "ffmpeg_build_all iOS start..."

            for ((j = 0; j < ${#FFMPEG_ALL_ARCH_ON_IOS[@]}; j++)); do

                FFMPEG_CURRENT_ARCH=${FFMPEG_ALL_ARCH_ON_IOS[j]}
                FFMPEG_LOG="${FFMPEG_TMP_OS_LOG_DIR}/${FFMPEG_CURRENT_TARGET_OS}_${FFMPEG_CURRENT_ARCH}.log"

                ffmpeg_output_log_control

                echo "FFMPEG_CURRENT_ARCH=${FFMPEG_CURRENT_ARCH}"
                echo "FFMPEG_LOG=$FFMPEG_LOG"

                mkdir -p "${FFMPEG_TMP_OS_TMP_DIR}/${FFMPEG_CURRENT_ARCH}"
                mkdir -p "${FFMPEG_TMP_OS_OUTPUT_DIR}/${FFMPEG_CURRENT_ARCH}"

                # ffmpeg_build_iOS ${FFMPEG_CURRENT_TARGET_OS} ${FFMPEG_CURRENT_ARCH}

            done

            # ffmpeg_lipo_iOS ${FFMPEG_CURRENT_TARGET_OS}

            echo "ffmpeg_build_all iOS end..."
        elif [ "Android" = $FFMPEG_CURRENT_TARGET_OS ]; then
            echo "ffmpeg_build_all Android start..."

            if [ $ANDROID_API -le 19 ]; then
                echo "ANDROID_API=$ANDROID_API is not support."
                exit 1
            elif [ $ANDROID_MAX_API -lt $ANDROID_API ]; then
                echo "ANDROID_API=$ANDROID_API is not support."
                exit 1
            else
                echo "ANDROID_API is OK"
            fi

            for ((j = 0; j < ${#FFMPEG_ALL_ARCH_ON_ANDROID[@]}; j++)); do

                FFMPEG_CURRENT_ARCH=${FFMPEG_ALL_ARCH_ON_ANDROID[j]}
                FFMPEG_LOG="${FFMPEG_TMP_OS_LOG_DIR}/${FFMPEG_CURRENT_TARGET_OS}_${FFMPEG_CURRENT_ARCH}.log"

                ffmpeg_output_log_control

                echo "FFMPEG_CURRENT_ARCH=${FFMPEG_CURRENT_ARCH}"
                echo "FFMPEG_LOG=$FFMPEG_LOG"

                mkdir -p "${FFMPEG_TMP_OS_TMP_DIR}/${FFMPEG_CURRENT_ARCH}"
                mkdir -p "${FFMPEG_TMP_OS_OUTPUT_DIR}/${FFMPEG_CURRENT_ARCH}"

                ffmpeg_build_Android ${FFMPEG_CURRENT_TARGET_OS} ${FFMPEG_CURRENT_ARCH}

            done

            echo "ffmpeg_build_all Android end..."
        fi

    done

    echo "ffmpeg_build_all end..."
}

echo "###############################################################################"
echo "#### Process control partition                                            #####"
echo "###############################################################################"

ffmpeg_clean
ffmpeg_mkdir
ffmpeg_prerequisites
ffmpeg_build_all

# function ffmpeg_break() {

# }

read -n1 -p "Press any key to continue..."
