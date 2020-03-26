#!/bin/sh

echo "###############################################################################"
echo "# Script Summary                                                              #"
echo "# Author by yu.zuo                                                            #"
echo "# Update on 2020.03.23                                                        #"
echo "# This script implements ffmpeg library on iOS platform cross-compilation.    #"
echo "# url: https://github.com/AsteriskZuo                                         #"
echo "# requst: GNU bash, version 3.2.57(1)-release-(x86_64-apple-darwin18)         #"
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

# all build target arch
FFMPEG_ALL_ARCH_ON_IOS=("armv7" "arm64" "i386" "x86_64")
FFMPEG_ALL_ARCH_ON_ANDROID=("armeabi" "armeabi-v7a" "arm64-v8a" "x86" "x86_64")

# for test
FFMPEG_ALL_ARCH_ON_IOS=("arm64" "x86_64")
FFMPEG_ALL_ARCH_ON_ANDROID=("")

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
echo "#### Function implementation partition                                    #####"
echo "###############################################################################"

function ffmpeg_test() {
    # special test function by man test commandline
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
    if [ "yes" = $FFMPEG_ENABLE_LOG_FILE ]; then
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

function ffmpeg_prerequisites() {
    # download dependence softwares
    # update prerequisite variable
    echo "ffmpeg_prerequisites start..."

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

    if [ ! -r $FFMPEG_FULL_NAME ]; then
        echo 'FFmpeg source file not found. Trying to download...'
        echo "download url: http://www.ffmpeg.org/releases/$FFMPEG_FULL_NAME.tar.bz2"
        curl http://www.ffmpeg.org/releases/${FFMPEG_FULL_NAME}.tar.bz2 >${FFMPEG_FULL_NAME}.tar.bz2 || exit 1
        tar -x -f ${FFMPEG_FULL_NAME}.tar.bz2 || exit 1
    fi

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

    CFLAGS="-arch ${FFMPEG_CURRENT_ARCH}"
    CXXFLAGS=${CFLAGS}
    LDFLAGS=${CFLAGS}
    AS=""
    CC=""

    TMP_DIR="${FFMPEG_TMP_OS_TMP_DIR}/${FFMPEG_CURRENT_ARCH}"
    OUTPUT_DIR="${FFMPEG_TMP_OS_OUTPUT_DIR}/${FFMPEG_CURRENT_ARCH}"

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
    elif [ "x86_64" = ${FFMPEG_CURRENT_ARCH} ]; then
        DEVICE_TYPE="iPhoneSimulator"
        CFLAGS="${CFLAGS} -mios-simulator-version-min=$DEPLOYMENT_MIN_TARGET"
        DEVICE_TYPE=$(echo ${DEVICE_TYPE} | tr '[:upper:]' '[:lower:]')
        CC="xcrun -sdk ${DEVICE_TYPE} clang"
        AS="gas-preprocessor.pl -- $CC"
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
        --disable-debug \
        --disable-programs \
        --disable-doc || exit 1

    # CONFIGURE_CMD="$(sh -x $CONFIGURE_FILE \
    #     --prefix="${CONFIGURE_PARAMS_PREFIX}" \
    #     --enable-cross-compile \
    #     --target-os="${CONFIGURE_PARAMS_TARGET_OS}" \
    #     --arch="${FFMPEG_CURRENT_ARCH}" \
    #     --as="${CONFIGURE_PARAMS_AS}" \
    #     --cc="${CONFIGURE_PARAMS_CC}" \
    #     --enable-pic \
    #     --extra-cflags="${CFLAGS}" \
    #     --extra-ldflags="${LDFLAGS}" \
    #     --disable-debug \
    #     --disable-programs \
    #     --disable-doc)"

    # ${CONFIGURE_CMD} || exit 1

    # read -n1 -p "Press any key to continue..."

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

    make clean || exit 1
    make -j4 install || exit 1

    popd

    echo "ffmpeg_build_iOS end..."
}

function ffmpeg_build_Android() {
    echo "ffmpeg_build_Android start..."
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
            for ((j = 0; j < ${#FFMPEG_ALL_ARCH_ON_IOS[@]}; j++)); do

                FFMPEG_CURRENT_ARCH=${FFMPEG_ALL_ARCH_ON_IOS[j]}
                FFMPEG_LOG="${FFMPEG_TMP_OS_LOG_DIR}/${FFMPEG_CURRENT_TARGET_OS}_${FFMPEG_CURRENT_ARCH}.log"

                ffmpeg_output_log_control

                echo "FFMPEG_CURRENT_ARCH=${FFMPEG_CURRENT_ARCH}"
                echo "FFMPEG_LOG=$FFMPEG_LOG"

                mkdir -p "${FFMPEG_TMP_OS_TMP_DIR}/${FFMPEG_CURRENT_ARCH}"
                mkdir -p "${FFMPEG_TMP_OS_OUTPUT_DIR}/${FFMPEG_CURRENT_ARCH}"

                ffmpeg_build_iOS ${FFMPEG_CURRENT_TARGET_OS} ${FFMPEG_CURRENT_ARCH}

            done

            ffmpeg_lipo_iOS ${FFMPEG_CURRENT_TARGET_OS}

        elif [ "Android" = $FFMPEG_CURRENT_TARGET_OS ]; then
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
