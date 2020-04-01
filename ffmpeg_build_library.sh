#!/bin/sh

source ./color_log.sh

log_head_print "###############################################################################"
log_head_print "# Script Summary:                                                             #"
log_head_print "# Author:                  yu.zuo                                             #"
log_head_print "# Update Date:             2020.03.23                                         #"
log_head_print "# Script version:          1.0.0                                              #"
log_head_print "# Url: https://github.com/AsteriskZuo/ffmpeg_build_scripts                    #"
log_head_print "#                                                                             #"
log_head_print "# Brief introduction:                                                         #"
log_head_print "# This script implements ffmpeg library on iOS platform cross-compilation.    #"
log_head_print "#                                                                             #"
log_head_print "# Prerequisites:                                                              #"
log_head_print "# GNU bash (version 3.2.57 test success on macOS)                             #"
log_head_print "# gas-preprocessor for iOS, which can be download by github                   #"
log_head_print "# yasm for iOS, which can be installed using brew                             #"
log_head_print "# nasm for Android, which can be installed using brew                         #"
log_head_print "# perl 5.18 (version 5.30.1 test fail) for gas-preprocessor.pl script         #"
log_head_print "# python 2.7 for make_standalone_toolchain.py script                          #"
log_head_print "# pkg-config for iOS and Android, which can be installed using brew           #"
log_head_print "# curl for iOS and Android, which can be installed using brew                 #"
log_head_print "# tar for iOS and Android, which can be installed using brew                  #"
log_head_print "#                                                                             #"
log_head_print "# Reference:                                                                  #"
log_head_print "# Url: http://yasm.tortall.net/                                               #"
log_head_print "# Url: https://developer.android.com/ndk/guides/cmake                         #"
log_head_print "# Url: https://developer.android.com/ndk/guides/abis                          #"
log_head_print "# Url: https://developer.android.com/ndk/guides/other_build_systems           #"
log_head_print "# Url: https://developer.android.com/ndk/guides/standalone_toolchain          #"
log_head_print "# Url: https://gcc.gnu.org/onlinedocs/gcc/index.html                          #"
log_head_print "# Url: https://llvm.org/docs/genindex.html                                    #"
log_head_print "# Url: https://clang.llvm.org/                                                #"
log_head_print "# Url: https://releases.llvm.org/10.0.0/tools/clang/docs/index.html           #"
log_head_print "# Url: https://github.com/libav/gas-preprocessor                              #"
log_head_print "# Url: https://github.com/nldzsz/ffmpeg-build-scripts                         #"
log_head_print "# Url: https://github.com/kewlbear/FFmpeg-iOS-build-script                    #"
log_head_print "###############################################################################"

log_head_print "###############################################################################"
log_head_print "#### Debug setting partition                                              #####"
log_head_print "###############################################################################"

# set: usage: set [--abefhkmnptuvxBCHP] [-o option] [arg ...]
# read -n1 -p "Press any key to continue..."

FFMPEG_ENABLE_LOG_FILE="yes"

log_var_split_print "FFMPEG_ENABLE_LOG_FILE=$FFMPEG_ENABLE_LOG_FILE"

log_head_print "###############################################################################"
log_head_print "#### Variable declarations partition                                      #####"
log_head_print "###############################################################################"

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

log_var_split_print "FFMPEG_NAME=$FFMPEG_NAME"
log_var_split_print "FFMPEG_VERSION=$FFMPEG_VERSION"
log_var_split_print "FFMPEG_FULL_NAME=$FFMPEG_FULL_NAME"

log_var_split_print "FFMPEG_ROOT_DIR=$FFMPEG_ROOT_DIR"
log_var_split_print "FFMPEG_SRC_DIR=$FFMPEG_SRC_DIR"
log_var_split_print "FFMPEG_SH_DIR=$FFMPEG_SH_DIR"
log_var_split_print "FFMPEG_TMP_DIR=$FFMPEG_TMP_DIR"

log_var_split_print "FFMPEG_CURRENT_DIR=$FFMPEG_CURRENT_DIR"

log_var_split_print "FFMPEG_TMP_OS_TMP_DIR=$FFMPEG_TMP_OS_TMP_DIR"
log_var_split_print "FFMPEG_TMP_OS_OUTPUT_DIR=$FFMPEG_TMP_OS_OUTPUT_DIR"
log_var_split_print "FFMPEG_TMP_OS_LIPO_DIR=$FFMPEG_TMP_OS_LIPO_DIR"
log_var_split_print "FFMPEG_TMP_OS_LOG_DIR=$FFMPEG_TMP_OS_LOG_DIR"

log_var_split_print "FFMPEG_CURRENT_TARGET_OS=$FFMPEG_CURRENT_TARGET_OS"
log_var_split_print "FFMPEG_CURRENT_ARCH=$FFMPEG_CURRENT_ARCH"

log_var_split_print "FFMPEG_LOG=$FFMPEG_LOG"

log_var_split_print "FFMPEG_ALL_TARGET_OS=${FFMPEG_ALL_TARGET_OS[@]}"
log_var_split_print "FFMPEG_ALL_ARCH_ON_IOS=${FFMPEG_ALL_ARCH_ON_IOS[@]}"
log_var_split_print "FFMPEG_ALL_ARCH_ON_ANDROID=${FFMPEG_ALL_ARCH_ON_ANDROID[@]}"

log_head_print "###############################################################################"
log_head_print "#### Variable declarations partition on iOS                               #####"
log_head_print "###############################################################################"

IOS_DEPLOYMENT_MIN_TARGET="8.0"

log_var_split_print "IOS_DEPLOYMENT_MIN_TARGET=$IOS_DEPLOYMENT_MIN_TARGET"

log_head_print "###############################################################################"
log_head_print "#### Variable declarations partition on Android                           #####"
log_head_print "###############################################################################"

ANDROID_NDK_DIR="/Users/zuoyu/Library/Android/sdk/ndk-bundle"
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

log_var_split_print "ANDROID_NDK_DIR=$ANDROID_NDK_DIR"
log_var_split_print "ANDROID_HOST_TAG=$ANDROID_HOST_TAG"
log_var_split_print "ANDROID_TOOLCHAIN_DIR=$ANDROID_TOOLCHAIN_DIR"
log_var_split_print "ANDROID_MARCHS=${ANDROID_MARCHS[@]}"
log_var_split_print "ANDROID_ABIS=${ANDROID_ABIS[@]}"
log_var_split_print "ANDROID_ABI_TRIPLES=${ANDROID_ABI_TRIPLES[@]}"

log_var_split_print "ANDROID_API=$ANDROID_API"
log_var_split_print "ANDROID_ENABLE_STANDALONE_TOOLCHAIN=$ANDROID_ENABLE_STANDALONE_TOOLCHAIN"

log_var_split_print "ANDROID_CURRENT_MARCH=$ANDROID_CURRENT_MARCH"
log_var_split_print "ANDROID_CURRENT_ABI=$ANDROID_CURRENT_ABI"
log_var_split_print "ANDROID_CURRENT_TRIPLE=$ANDROID_CURRENT_TRIPLE"
log_var_split_print "ANDROID_CURRENT_TOOLCHAIN_DIR=$ANDROID_CURRENT_TOOLCHAIN_DIR"

log_head_print "###############################################################################"
log_head_print "#### Function implementation partition                                    #####"
log_head_print "###############################################################################"

function ffmpeg_test() {
    # special test function by man test commandline
    # $ man test
    echo "ffmpeg_test start..."
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
    echo "ffmpeg_test end..."
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
    log_info_print "ffmpeg_clean start..."
    if test -d $FFMPEG_TMP_DIR; then
        rm -rf $FFMPEG_TMP_DIR
    fi
    log_info_print "ffmpeg_clean end..."
}

function ffmpeg_mkdir() {
    # make directory
    log_info_print "ffmpeg_mkdir start..."
    if test ! -d $FFMPEG_TMP_DIR; then
        mkdir -p $FFMPEG_TMP_DIR
    fi
    log_info_print "ffmpeg_mkdir end..."
}

function ffmpeg_prerequisites_ios() {
    log_info_print "ffmpeg_prerequisites_ios start..."

    if [ ! $(which perl) ]; then
        log_warning_print 'Perl not found. Trying to install...'
        brew install 'perl@5.18' || (log_error_print "Perl install fail." && exit 1)
    fi

    if [ ! $(which yasm) ]; then
        log_warning_print 'Yasm not found. Trying to install...'
        brew install yasm || (log_error_print "Yasm install fail." && exit 1)
    fi

    if [ ! $(which gas-preprocessor.pl) ]; then
        log_warning_print 'gas-preprocessor.pl not found. Trying to install...'
        log_debug_print "download url: https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl"
        curl -L https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl -o /usr/local/bin/gas-preprocessor.pl || (log_error_print "download fail." && exit 1)
        chmod +x /usr/local/bin/gas-preprocessor.pl || (log_error_print "gas-preprocessor.pl install fail." && exit 1)
    fi

    log_info_print "ffmpeg_prerequisites_ios end..."
}

function ffmpeg_prerequisites_android() {
    log_info_print "ffmpeg_prerequisites_android start..."

    if [ ! -d ${ANDROID_NDK_DIR} ]; then
        log_error_print "Please set android ndk dir." && exit 1
    fi

    if [ 19 -lt $ANDROID_API -a $ANDROID_API -le $ANDROID_MAX_API ]; then
        a=1
    else
        log_error_print "ANDROID_API=$ANDROID_API is not support." && exit 1
    fi

    if [ ! $(which nasm) ]; then
        log_warning_print "Nasm not found. Trying to install..."
        brew install nasm || (log_error_print "Nasm install fail." && exit 1)
    fi

    # python 2.7.x
    if [ ! $(which python) ]; then
        log_warning_print "Python not found. Trying to install..."
        brew install python || (log_error_print "Python 2.7.x install fail." && exit 1)
    fi

    if [ "yes" = $ANDROID_ENABLE_STANDALONE_TOOLCHAIN ]; then

        ANDROID_TOOLCHAIN_DIR=$FFMPEG_ROOT_DIR/ffmpeg_android
        log_var_split_print "ANDROID_TOOLCHAIN_DIR=$ANDROID_TOOLCHAIN_DIR"

        if [ ! -d ${ANDROID_TOOLCHAIN_DIR} ]; then
            mkdir -p $ANDROID_TOOLCHAIN_DIR
        fi

        for MARCH in ${ANDROID_MARCHS[@]}; do
            log_var_split_print "MARCH=$MARCH"
            if [ ! -d ${ANDROID_TOOLCHAIN_DIR}/${MARCH} ]; then
                python ${ANDROID_NDK_DIR}/build/tools/make_standalone_toolchain.py \
                    --arch ${MARCH} \
                    --api ${ANDROID_API} \
                    --stl libc++ \
                    --install-dir=${ANDROID_TOOLCHAIN_DIR}/${MARCH} || (log_error_print "Android toolchain install fail." && exit 1)
            fi
        done

        for MARCH in ${ANDROID_MARCHS[@]}; do
            export PATH=$PATH:${ANDROID_TOOLCHAIN_DIR}/${MARCH}/bin
        done

    fi

    log_info_print "ffmpeg_prerequisites_android end..."
}

function ffmpeg_download_src() {
    log_info_print "ffmpeg_download_src start..."

    if [ ! -r $FFMPEG_FULL_NAME ]; then
        log_warning_print 'FFmpeg source file not found. Trying to download...'
        log_debug_print "download url: http://www.ffmpeg.org/releases/$FFMPEG_FULL_NAME.tar.bz2"
        curl http://www.ffmpeg.org/releases/${FFMPEG_FULL_NAME}.tar.bz2 >${FFMPEG_FULL_NAME}.tar.bz2 || (log_error_print "ffmpeg src download fail." && exit 1)
        tar -x -f ${FFMPEG_FULL_NAME}.tar.bz2 || (log_error_print "ffmpeg src uncompress fail." && exit 1)
    fi

    log_info_print "ffmpeg_download_src end..."
}

function ffmpeg_prerequisites_common() {
    log_info_print "ffmpeg_prerequisites_common start..."

    if [ ! $(which curl) ]; then
        log_error_print "Curl not found." && exit 1
    fi

    if [ ! $(which tar) ]; then
        log_error_print "Pkg-config not found." && exit 1
    fi

    if [ ! $(which brew) ]; then
        # Changed brew setting in .brew_install
        log_warning_print 'Homebrew not found. Trying to install...'
        log_debug_print "Brew install url: https://raw.githubusercontent.com/Homebrew/install/master/install"
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" || (log_error_print "brew install fail." && exit 1)
    fi

    if [ ! $(which pkg-config) ]; then
        log_warning_print "Pkg-config not found. Trying to install..."
        brew install pkg-config || (log_error_print "Pkg-config install fail." && exit 1)
    fi

    log_info_print "ffmpeg_prerequisites_common end..."
}

function ffmpeg_prerequisites() {
    # download dependence softwares
    # update prerequisite variable
    log_info_print "ffmpeg_prerequisites start..."

    ffmpeg_download_src
    ffmpeg_prerequisites_common
    ffmpeg_prerequisites_ios
    ffmpeg_prerequisites_android

    log_info_print "ffmpeg_prerequisites end..."
}

function ffmpeg_lipo_iOS() {
    log_info_print "ffmpeg_lipo_iOS start..."
    log_info_print "ffmpeg_lipo_iOS param_count=" $# "param_content=" $@

    local FROM_LIBRARY_DIR=${FFMPEG_TMP_OS_OUTPUT_DIR}
    local TO_LIBRARY_DIR=${FFMPEG_TMP_OS_LIPO_DIR}

    log_var_split_print "FROM_LIBRARY_DIR=$FROM_LIBRARY_DIR"
    log_var_split_print "TO_LIBRARY_DIR=$TO_LIBRARY_DIR"

    local LIBRARY_LIST=$(find ${FROM_LIBRARY_DIR}/${FFMPEG_ALL_ARCH_ON_IOS[0]} -name "*.a" | sed "s/^.*\///g")

    log_var_split_print "LIBRARY_LIST=${LIBRARY_LIST[@]}"

    for LIBRARY_FILE in ${LIBRARY_LIST[@]}; do
        log_var_split_print "LIBRARY_FILE=$LIBRARY_FILE"
        lipo -create $(find $FROM_LIBRARY_DIR -name $LIBRARY_FILE) -output $TO_LIBRARY_DIR/$LIBRARY_FILE || (log_error_print "lipo fail." && exit 1)
    done

    log_info_print "ffmpeg_lipo_iOS end..."
}

function ffmpeg_build_iOS() {
    log_info_print "ffmpeg_build_iOS start..."
    log_info_print "ffmpeg_build_iOS params_count="$# "params_content="$@

    local DEVICE_TYPE=""
    local TMP_DIR="${FFMPEG_TMP_OS_TMP_DIR}/${FFMPEG_CURRENT_ARCH}"
    local OUTPUT_DIR="${FFMPEG_TMP_OS_OUTPUT_DIR}/${FFMPEG_CURRENT_ARCH}"
    local PLATFORM_TRAIT=""

    local CONFIGURE_PARAMS_PREFIX=${OUTPUT_DIR}
    local CONFIGURE_PARAMS_SYSROOT=""
    local CONFIGURE_PARAMS_TARGET_OS="darwin"
    local CONFIGURE_PARAMS_AR=$(which ar)
    local CONFIGURE_PARAMS_AS=$(which as)
    local CONFIGURE_PARAMS_CC=$(which cc)
    local CONFIGURE_PARAMS_CXX=$(which c++)
    local CONFIGURE_PARAMS_LD=$(which ld)
    local CONFIGURE_PARAMS_CFLAGS="-arch ${FFMPEG_CURRENT_ARCH} -std=c11"
    local CONFIGURE_PARAMS_CXXFLAGS="${CONFIGURE_PARAMS_CFLAGS} -std=c++11"
    local CONFIGURE_PARAMS_LDFLAGS=${CONFIGURE_PARAMS_CFLAGS}
    local CONFIGURE_PARAMS_PKG_CONFIG=$(which pkg-config)

    if [ "armv7" = ${FFMPEG_CURRENT_ARCH} ]; then
        CONFIGURE_PARAMS_CFLAGS="$CONFIGURE_PARAMS_CFLAGS -mios-version-min=$IOS_DEPLOYMENT_MIN_TARGET -fembed-bitcode"
        DEVICE_TYPE="iPhoneOS"
        DEVICE_TYPE=$(echo ${DEVICE_TYPE} | tr '[:upper:]' '[:lower:]')
        CONFIGURE_PARAMS_CC="xcrun -sdk ${DEVICE_TYPE} clang"
        CONFIGURE_PARAMS_AS="gas-preprocessor.pl -- $CONFIGURE_PARAMS_CC"
    elif [ "arm64" = ${FFMPEG_CURRENT_ARCH} ]; then
        CONFIGURE_PARAMS_CFLAGS="$CONFIGURE_PARAMS_CFLAGS -mios-version-min=$IOS_DEPLOYMENT_MIN_TARGET -fembed-bitcode"
        DEVICE_TYPE="iPhoneOS"
        DEVICE_TYPE=$(echo ${DEVICE_TYPE} | tr '[:upper:]' '[:lower:]')
        CONFIGURE_PARAMS_CC="xcrun -sdk ${DEVICE_TYPE} clang"
        CONFIGURE_PARAMS_AS="gas-preprocessor.pl -arch aarch64 -- $CONFIGURE_PARAMS_CC"
    elif [ "i386" = ${FFMPEG_CURRENT_ARCH} ]; then
        CONFIGURE_PARAMS_CFLAGS="${CONFIGURE_PARAMS_CFLAGS} -mios-simulator-version-min=$IOS_DEPLOYMENT_MIN_TARGET"
        DEVICE_TYPE="iPhoneSimulator"
        DEVICE_TYPE=$(echo ${DEVICE_TYPE} | tr '[:upper:]' '[:lower:]')
        CONFIGURE_PARAMS_CC="xcrun -sdk ${DEVICE_TYPE} clang"
        CONFIGURE_PARAMS_AS="gas-preprocessor.pl -- $CONFIGURE_PARAMS_CC"
        PLATFORM_TRAIT=${PLATFORM_TRAIT}" --disable-programs"
    elif [ "x86_64" = ${FFMPEG_CURRENT_ARCH} ]; then
        CONFIGURE_PARAMS_CFLAGS="${CONFIGURE_PARAMS_CFLAGS} -mios-simulator-version-min=$IOS_DEPLOYMENT_MIN_TARGET"
        DEVICE_TYPE="iPhoneSimulator"
        DEVICE_TYPE=$(echo ${DEVICE_TYPE} | tr '[:upper:]' '[:lower:]')
        CONFIGURE_PARAMS_CC="xcrun -sdk ${DEVICE_TYPE} clang"
        CONFIGURE_PARAMS_AS="gas-preprocessor.pl -- $CONFIGURE_PARAMS_CC"
        PLATFORM_TRAIT=${PLATFORM_TRAIT}" --disable-programs"
    fi

    CONFIGURE_PARAMS_AR="ar"
    CONFIGURE_PARAMS_CXX="$CONFIGURE_PARAMS_CC"
    CONFIGURE_PARAMS_LD="$CONFIGURE_PARAMS_CC"
    CONFIGURE_PARAMS_SYSROOT=$(xcrun -sdk ${DEVICE_TYPE} --show-sdk-path)

    log_var_split_print "DEVICE_TYPE=${DEVICE_TYPE}"
    log_var_split_print "TMP_DIR=$TMP_DIR"
    log_var_split_print "OUTPUT_DIR=$OUTPUT_DIR"
    log_var_split_print "PLATFORM_TRAIT=$PLATFORM_TRAIT"

    log_var_split_print "CONFIGURE_PARAMS_PREFIX=${CONFIGURE_PARAMS_PREFIX}"
    log_var_split_print "CONFIGURE_PARAMS_SYSROOT=${CONFIGURE_PARAMS_SYSROOT}"
    log_var_split_print "CONFIGURE_PARAMS_TARGET_OS=${CONFIGURE_PARAMS_TARGET_OS}"
    log_var_split_print "CONFIGURE_PARAMS_AR=${CONFIGURE_PARAMS_AR}"
    log_var_split_print "CONFIGURE_PARAMS_AS=${CONFIGURE_PARAMS_AS}"
    log_var_split_print "CONFIGURE_PARAMS_CC=${CONFIGURE_PARAMS_CC}"
    log_var_split_print "CONFIGURE_PARAMS_CXX=${CONFIGURE_PARAMS_CXX}"
    log_var_split_print "CONFIGURE_PARAMS_LD=${CONFIGURE_PARAMS_LD}"
    log_var_split_print "CONFIGURE_PARAMS_CFLAGS=${CONFIGURE_PARAMS_CFLAGS}"
    log_var_split_print "CONFIGURE_PARAMS_CXXFLAGS=${CONFIGURE_PARAMS_CXXFLAGS}"
    log_var_split_print "CONFIGURE_PARAMS_LDFLAGS=${CONFIGURE_PARAMS_LDFLAGS}"
    log_var_split_print "CONFIGURE_PARAMS_PKG_CONFIG=${CONFIGURE_PARAMS_PKG_CONFIG}"

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
    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --extra-cflags=${CONFIGURE_PARAMS_CFLAGS}"
    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --extra-CONFIGURE_PARAMS_LDFLAGS=${CONFIGURE_PARAMS_LDFLAGS}"

    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --prefix=${CONFIGURE_PARAMS_PREFIX}"

    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --disable-debug"
    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --disable-programs"
    # CONFIGURE_PARAMS="${CONFIGURE_PARAMS} --disable-doc"

    # echo "CONFIGURE_PARAMS=${CONFIGURE_PARAMS}"

    # sh -x "./configure" ${CONFIGURE_PARAMS}

    local CONFIGURE_FILE="${FFMPEG_SRC_DIR}/configure"
    log_var_split_print "CONFIGURE_FILE=$CONFIGURE_FILE"

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
        --extra-cflags="${CONFIGURE_PARAMS_CFLAGS}" \
        --extra-ldflags="${CONFIGURE_PARAMS_LDFLAGS}" \
        ${PLATFORM_TRAIT} \
        --disable-debug \
        --disable-doc || (log_error_print "configure fail." && exit 1)

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
    #     "--extra-cflags=${CONFIGURE_PARAMS_CFLAGS}" \
    #     "--extra-ldflags=${CONFIGURE_PARAMS_LDFLAGS}" \
    #     "--disable-debug" \
    #     "--disable-programs" \
    #     "--disable-doc" ||
    #     exit 1

    make clean >${FFMPEG_LOG} || (log_error_print "make clean fail." && exit 1)
    make -j4 install >>${FFMPEG_LOG} || (log_error_print "make && install fail." && exit 1)

    popd

    log_info_print "ffmpeg_build_iOS end..."
}

function ffmpeg_build_Android() {
    log_info_print "ffmpeg_build_Android start..."
    log_info_print "ffmpeg_build_Android params_count="$# "params_content="$@

    local CURRENT_ARCH_FLAGS=""
    local CURRENT_ARCH_LINK=""

    # ARCH_LIST from configure in ffmpeg src
    local CURRENT_ARCH=""
    local CURRENT_TRIPLE_armv7a=""
    local CURRENT_CPU=""

    local PKG_CONFIG="$(which pkg-config)"
    local PLATFORM_TRAIT=""

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
        log_error_print "FFMPEG_CURRENT_ARCH=$FFMPEG_CURRENT_ARCH is error." && exit 1
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

    local TMP_DIR="${FFMPEG_TMP_OS_TMP_DIR}/${FFMPEG_CURRENT_ARCH}"
    local OUTPUT_DIR="${FFMPEG_TMP_OS_OUTPUT_DIR}/${FFMPEG_CURRENT_ARCH}"

    local CONFIGURE_PARAMS_PREFIX=${OUTPUT_DIR}
    local CONFIGURE_PARAMS_TARGET_OS="android"
    local CONFIGURE_PARAMS_SYSROOT=""

    log_var_split_print "CURRENT_ARCH_FLAGS=$CURRENT_ARCH_FLAGS"
    log_var_split_print "CURRENT_ARCH_LINK=$CURRENT_ARCH_LINK"

    log_var_split_print "ANDROID_CURRENT_TRIPLE=$ANDROID_CURRENT_TRIPLE"
    log_var_split_print "ANDROID_CURRENT_ABI=$ANDROID_CURRENT_ABI"
    log_var_split_print "ANDROID_CURRENT_MARCH=$ANDROID_CURRENT_MARCH"

    log_var_split_print "CURRENT_ARCH=$CURRENT_ARCH"
    log_var_split_print "CURRENT_TRIPLE_armv7a=$CURRENT_TRIPLE_armv7a"
    log_var_split_print "CURRENT_CPU=$CURRENT_CPU"

    log_var_split_print "export AR=$AR"
    log_var_split_print "export AS=$AS"
    log_var_split_print "export CC=$CC"
    log_var_split_print "export CXX=$CXX"
    log_var_split_print "export LD=$LD"
    log_var_split_print "export STRIP=$STRIP"
    log_var_split_print "export CFLAGS=$CFLAGS"
    log_var_split_print "export CXXFLAGS=$CXXFLAGS"
    log_var_split_print "export LDFLAGS=$LDFLAGS"
    log_var_split_print "export RANLIB=$RANLIB"
    log_var_split_print "export NM=$NM"

    log_var_split_print "TMP_DIR=$TMP_DIR"
    log_var_split_print "OUTPUT_DIR=$OUTPUT_DIR"
    log_var_split_print "CONFIGURE_PARAMS_PREFIX=$CONFIGURE_PARAMS_PREFIX"

    log_var_split_print "CONFIGURE_PARAMS_TARGET_OS=$CONFIGURE_PARAMS_TARGET_OS"
    log_var_split_print "CONFIGURE_PARAMS_SYSROOT=$CONFIGURE_PARAMS_SYSROOT"

    log_var_split_print "PKG_CONFIG=$PKG_CONFIG"
    log_var_split_print "PLATFORM_TRAIT=${PLATFORM_TRAIT}"

    CONFIGURE_FILE="${FFMPEG_SRC_DIR}/configure"
    log_var_split_print "CONFIGURE_FILE=$CONFIGURE_FILE"

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
        --extra-ldflags="${LDFLAGS}" || (log_error_print "configure fail." && exit 1)

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

    make clean >${FFMPEG_LOG} || (log_error_print "make clean fail." && exit 1)
    make -j4 install >>${FFMPEG_LOG} || (log_error_print "make && install fail." && exit 1)

    popd

    log_info_print "ffmpeg_build_Android end..."
}

function ffmpeg_build_all() {
    log_info_print "ffmpeg_build_all start..."

    for ((i = 0; i < ${#FFMPEG_ALL_TARGET_OS[@]}; i++)); do

        FFMPEG_CURRENT_TARGET_OS=${FFMPEG_ALL_TARGET_OS[i]}
        FFMPEG_TMP_OS_LOG_DIR="${FFMPEG_TMP_DIR}/${FFMPEG_CURRENT_TARGET_OS}/log"
        FFMPEG_TMP_OS_OUTPUT_DIR="${FFMPEG_TMP_DIR}/${FFMPEG_CURRENT_TARGET_OS}/output"
        FFMPEG_TMP_OS_TMP_DIR="${FFMPEG_TMP_DIR}/${FFMPEG_CURRENT_TARGET_OS}/tmp"
        FFMPEG_TMP_OS_LIPO_DIR="${FFMPEG_TMP_DIR}/${FFMPEG_CURRENT_TARGET_OS}/lipo"

        log_var_split_print "FFMPEG_CURRENT_TARGET_OS=${FFMPEG_CURRENT_TARGET_OS}"
        log_var_split_print "FFMPEG_TMP_OS_LOG_DIR=${FFMPEG_TMP_OS_LOG_DIR}"
        log_var_split_print "FFMPEG_TMP_OS_OUTPUT_DIR=${FFMPEG_TMP_OS_OUTPUT_DIR}"
        log_var_split_print "FFMPEG_TMP_OS_TMP_DIR=${FFMPEG_TMP_OS_TMP_DIR}"
        log_var_split_print "FFMPEG_TMP_OS_LIPO_DIR=${FFMPEG_TMP_OS_LIPO_DIR}"

        mkdir -p ${FFMPEG_TMP_OS_LOG_DIR}
        mkdir -p ${FFMPEG_TMP_OS_OUTPUT_DIR}
        mkdir -p ${FFMPEG_TMP_OS_TMP_DIR}
        mkdir -p ${FFMPEG_TMP_OS_LIPO_DIR}

        if [ "iOS" = $FFMPEG_CURRENT_TARGET_OS ]; then
            log_info_print "ffmpeg_build_all iOS start..."

            for ((j = 0; j < ${#FFMPEG_ALL_ARCH_ON_IOS[@]}; j++)); do

                FFMPEG_CURRENT_ARCH=${FFMPEG_ALL_ARCH_ON_IOS[j]}
                FFMPEG_LOG="${FFMPEG_TMP_OS_LOG_DIR}/${FFMPEG_CURRENT_TARGET_OS}_${FFMPEG_CURRENT_ARCH}.log"

                ffmpeg_output_log_control

                log_var_split_print "FFMPEG_CURRENT_ARCH=${FFMPEG_CURRENT_ARCH}"
                log_var_split_print "FFMPEG_LOG=$FFMPEG_LOG"

                mkdir -p "${FFMPEG_TMP_OS_TMP_DIR}/${FFMPEG_CURRENT_ARCH}"
                mkdir -p "${FFMPEG_TMP_OS_OUTPUT_DIR}/${FFMPEG_CURRENT_ARCH}"

                ffmpeg_build_iOS ${FFMPEG_CURRENT_TARGET_OS} ${FFMPEG_CURRENT_ARCH}

            done

            ffmpeg_lipo_iOS ${FFMPEG_CURRENT_TARGET_OS}

            log_info_print "ffmpeg_build_all iOS end..."
        elif [ "Android" = $FFMPEG_CURRENT_TARGET_OS ]; then
            log_info_print "ffmpeg_build_all Android start..."

            for ((j = 0; j < ${#FFMPEG_ALL_ARCH_ON_ANDROID[@]}; j++)); do

                FFMPEG_CURRENT_ARCH=${FFMPEG_ALL_ARCH_ON_ANDROID[j]}
                FFMPEG_LOG="${FFMPEG_TMP_OS_LOG_DIR}/${FFMPEG_CURRENT_TARGET_OS}_${FFMPEG_CURRENT_ARCH}.log"

                ffmpeg_output_log_control

                log_var_split_print "FFMPEG_CURRENT_ARCH=${FFMPEG_CURRENT_ARCH}"
                log_var_split_print "FFMPEG_LOG=$FFMPEG_LOG"

                mkdir -p "${FFMPEG_TMP_OS_TMP_DIR}/${FFMPEG_CURRENT_ARCH}"
                mkdir -p "${FFMPEG_TMP_OS_OUTPUT_DIR}/${FFMPEG_CURRENT_ARCH}"

                ffmpeg_build_Android ${FFMPEG_CURRENT_TARGET_OS} ${FFMPEG_CURRENT_ARCH}

            done

            log_info_print "ffmpeg_build_all Android end..."
        fi

    done

    log_info_print "ffmpeg_build_all end..."
}

log_head_print "###############################################################################"
log_head_print "#### Process control partition                                            #####"
log_head_print "###############################################################################"

ffmpeg_clean
ffmpeg_mkdir
ffmpeg_prerequisites
ffmpeg_build_all

# function ffmpeg_break() {

# }

read -n1 -p "Press any key to continue..."
