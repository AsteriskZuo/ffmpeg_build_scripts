#!/bin/sh

# source ../color_log.sh
# source ./ffmpeg_global_variable.sh

log_debug_print "load script $0 ..."

echo "###############################################################################" >/dev/null
echo "# Script Summary:                                                             #" >/dev/null
echo "# Author:                  yu.zuo                                             #" >/dev/null
echo "# Create Date:             2020.03.31                                         #" >/dev/null
echo "# Update Date:             2020.03.31                                         #" >/dev/null
echo "# Script version:          1.0.0                                              #" >/dev/null
echo "# Url: https://github.com/AsteriskZuo/ffmpeg_build_scripts                    #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Brief introduction:                                                         #" >/dev/null
echo "# Build x264 library                                                          #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Prerequisites:                                                              #" >/dev/null
echo "# GNU bash (version 3.2.57 test success on macOS)                             #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Reference:                                                                  #" >/dev/null
echo "# none.                                                                       #" >/dev/null
echo "###############################################################################" >/dev/null
echo
echo "###############################################################################" >/dev/null
echo "#### Debug setting partition                                              #####" >/dev/null
echo "###############################################################################" >/dev/null

# selog_head_printt: usage: set [--abefhkmnptuvxBCHP] [-o option] [arg ...]
# relog_head_printad -n1 -p "Press any key to continue..."

log_debug_print "param_count=$#, params=$@"

echo "###############################################################################" >/dev/null
echo "#### Variable declarations partition                                      #####" >/dev/null
echo "###############################################################################" >/dev/null

echo "###############################################################################" >/dev/null
echo "#### Variable declarations partition on Android                           #####" >/dev/null
echo "###############################################################################" >/dev/null

echo "###############################################################################" >/dev/null
echo "#### Function implementation partition                                    #####" >/dev/null
echo "###############################################################################" >/dev/null

function ffm_lib_clean_x264() {
    log_info_print "ffm_lib_clean_x264 start..."
    if test -d $FFMPEG_TMP_OS_XXX_TMP_DIR; then
        rm -rf $FFMPEG_TMP_OS_XXX_TMP_DIR
    fi
    if test -d $FFMPEG_TMP_OS_XXX_OUTPUT_DIR; then
        rm -rf $FFMPEG_TMP_OS_XXX_OUTPUT_DIR
    fi
    # if test -d $FFMPEG_TMP_OS_XXX_SRC_DIR; then
    #     rm -rf $FFMPEG_TMP_OS_XXX_SRC_DIR
    # fi
    log_info_print "ffm_lib_clean_x264 end..."
}
function ffm_lib_mkdir_x264() {
    log_info_print "ffm_lib_mkdir_x264 start..."
    if test ! -d $FFMPEG_TMP_OS_XXX_TMP_DIR; then
        mkdir -p $FFMPEG_TMP_OS_XXX_TMP_DIR
    fi
    if test ! -d $FFMPEG_TMP_OS_XXX_OUTPUT_DIR; then
        mkdir -p $FFMPEG_TMP_OS_XXX_OUTPUT_DIR
    fi
    if test ! -d $FFMPEG_TMP_OS_XXX_SRC_DIR; then
        mkdir -p $FFMPEG_TMP_OS_XXX_SRC_DIR
    fi
    log_info_print "ffm_lib_mkdir_x264 end..."
}
function ffm_lib_prerequisites_x264() {
    # 库的预处理部分：包括：安装依赖环境、下载源码等操作。
    log_info_print "ffm_lib_prerequisites_x264 start..."

    FFMPEG_XXX_FULL_NAME="${FFMPEG_XXX_NAME}-${FFMPEG_XXX_VERSION}"
    local local_src_git="${FFMPEG_TMP_OS_XXX_SRC_DIR}/${FFMPEG_XXX_FULL_NAME}_git"
    local local_src=${FFMPEG_TMP_OS_XXX_SRC_DIR}/${FFMPEG_XXX_FULL_NAME}
    if [ ! -r ${local_src_git} ]; then
        log_warning_print "${FFMPEG_XXX_NAME} source file not found. Trying to download..."
        log_debug_print "download url: https://code.videolan.org/videolan/x264.git"
        local DOWNLOAD_SUCCESS="yes"
        git clone ${FFMPEG_XXX_URL} ${local_src_git} || DOWNLOAD_SUCCESS="no"
        if [ "no" = $DOWNLOAD_SUCCESS ]; then
            log_error_print "${FFMPEG_XXX_NAME} src download fail." && rm -rf ${local_src_git}
        fi
    fi
    # rm -rf ${local_src}
    if [ ! -d "${local_src}" ]; then
        local cp_success="yes"
        cp -f -R "${local_src_git}" "${local_src}" || cp_success="no"
        if [ "no" = cp_success ]; then
            log_error_print "${FFMPEG_XXX_NAME} src uncompress fail." && rm -rf ${local_src}
        fi
        pushd .
        cd ${local_src}
        git checkout -b "stable" "origin/stable"
        git pull
        git checkout ${FFMPEG_XXX_VERSION}
        popd
    fi

    read -n1 -p "key..."

    log_info_print "ffm_lib_prerequisites_x264 end..."
}
function ffm_lib_build_x264_ios() {
    log_info_print "ffm_lib_build_x264_ios start..."
    log_info_print "ffm_lib_build_x264_ios params_count="$# "params_content="$@

    local lv_tmp_dir="${FFMPEG_TMP_OS_XXX_TMP_DIR}/${FFMPEG_CURRENT_ARCH}"
    local lv_output_dir="${FFMPEG_TMP_OS_XXX_OUTPUT_DIR}/${FFMPEG_CURRENT_ARCH}"
    local lv_platform_trait=""
    local lv_device_type=""

    # local variable
    local lv_prefix=$lv_output_dir
    local lv_extra_asflags=""
    local lv_extra_cflags="-arch ${FFMPEG_CURRENT_ARCH} -std=c11"
    local lv_extra_ldflags=""
    local lv_extra_rcflags=""
    local lv_other_options="--disable-cli --enable-static --enable-lto --enable-strip --enable-pic"
    local lv_host=""
    local lv_cc="xcrun -sdk ${lv_device_type} clang"
    local lv_as="gas-preprocessor.pl -arch aarch64 -- $lv_cc"

    if [ "armv7" = ${FFMPEG_CURRENT_ARCH} ]; then
        lv_extra_cflags="$lv_extra_cflags -mios-version-min=$IOS_DEPLOYMENT_MIN_TARGET -fembed-bitcode"
        lv_host="arm-apple-darwin"
        local lv_device_type="iPhoneOS"
        lv_device_type=$(echo ${lv_device_type} | tr '[:upper:]' '[:lower:]')
        lv_cc="xcrun -sdk ${lv_device_type} clang"
        lv_as="gas-preprocessor.pl -- $lv_cc"
    elif [ "arm64" = ${FFMPEG_CURRENT_ARCH} ]; then
        lv_extra_cflags="$lv_extra_cflags -mios-version-min=$IOS_DEPLOYMENT_MIN_TARGET -fembed-bitcode"
        lv_host="aarch64-apple-darwin"
        lv_device_type="iPhoneOS"
        lv_device_type=$(echo ${lv_device_type} | tr '[:upper:]' '[:lower:]')
        lv_cc="xcrun -sdk ${lv_device_type} clang"
        lv_as="gas-preprocessor.pl -arch aarch64 -- $lv_cc"
    elif [ "i386" = ${FFMPEG_CURRENT_ARCH} ]; then
        lv_extra_cflags="${lv_extra_cflags} -mios-simulator-version-min=$IOS_DEPLOYMENT_MIN_TARGET"
        lv_host="i386-apple-darwin"
        lv_device_type="iPhoneSimulator"
        lv_device_type=$(echo ${lv_device_type} | tr '[:upper:]' '[:lower:]')
        lv_cc="xcrun -sdk ${lv_device_type} clang"
        lv_as="gas-preprocessor.pl -- $lv_cc"
    elif [ "x86_64" = ${FFMPEG_CURRENT_ARCH} ]; then
        lv_extra_cflags="${lv_extra_cflags} -mios-simulator-version-min=$IOS_DEPLOYMENT_MIN_TARGET"
        # Omit the lv_host assignment, the system will use config.guess to fill in automatically.
        lv_host="x86_64-apple-darwin"
        lv_device_type="iPhoneSimulator"
        lv_device_type=$(echo ${lv_device_type} | tr '[:upper:]' '[:lower:]')
        lv_cc="xcrun -sdk ${lv_device_type} clang"
        lv_as="gas-preprocessor.pl -- $lv_cc"
    fi

    lv_extra_asflags=$lv_extra_cflags
    lv_extra_ldflags=$lv_extra_cflags

    log_var_split_print "lv_platform_trait=$lv_platform_trait"
    log_var_split_print "lv_device_type=$lv_device_type"

    log_var_split_print "lv_prefix=$lv_prefix"
    log_var_split_print "lv_extra_asflags=$lv_extra_asflags"
    log_var_split_print "lv_extra_cflags=$lv_extra_cflags"
    log_var_split_print "lv_extra_ldflags=$lv_extra_ldflags"
    log_var_split_print "lv_extra_rcflags=$lv_extra_rcflags"
    log_var_split_print "lv_other_options=$lv_other_options"
    log_var_split_print "lv_host=$lv_host"

    local lv_configure_file="${FFMPEG_SRC_XXX_DIR}/${FFMPEG_XXX_FULL_NAME}}/configure"
    log_var_split_print "lv_configure_file=$lv_configure_file"

    log_debug_print "$lv_configure_file in progress ..."
    read -n1 -p "Press any key to continue..."

    pushd .

    cd ${lv_tmp_dir}

    export CC=$lv_cc
    export AS=$lv_as

    sh $lv_configure_file \
        --prefix="${lv_prefix}" \
        --host="${lv_host}" \
        --extra-asflags="${lv_extra_asflags}" \
        --extra-cflags="${lv_extra_cflags}" \
        --extra-ldflags="${lv_extra_ldflags}" \
        "${lv_other_options}" >${FFMPEG_LOG} 2>&1 || log_error_print "Configuration error. See log (${FFMPEG_LOG}) for details."

    log_debug_print "make and make install in progress ..."
    read -n1 -p "Press any key to continue..."

    make clean >>${FFMPEG_LOG} 2>&1 || log_error_print "Make clean error. See log (${FFMPEG_LOG}) for details."
    make -j${FFMPEG_WORK_THREAD_COUNT} install >>${FFMPEG_LOG} 2>&1 || log_error_print "Make or install error. See log (${FFMPEG_LOG}) for details."

    popd

    log_info_print "ffm_lib_build_x264_ios end..."
}
function ffm_lib_build_x264_android() {
    log_info_print "ffm_lib_build_x264_android start..."
    log_info_print "ffm_lib_build_x264_android params_count="$# "params_content="$@

    local lv_tmp_dir="${FFMPEG_TMP_OS_XXX_TMP_DIR}/${FFMPEG_CURRENT_ARCH}"
    local lv_output_dir="${FFMPEG_TMP_OS_XXX_OUTPUT_DIR}/${FFMPEG_CURRENT_ARCH}"

    # local variable
    local lv_prefix=$lv_output_dir
    local lv_extra_asflags=""
    local lv_extra_cflags="-arch ${FFMPEG_CURRENT_ARCH} -std=c11"
    local lv_extra_ldflags=""
    local lv_extra_rcflags=""
    local lv_other_options="--disable-cli --enable-static --enable-lto --enable-strip --enable-pic"
    local lv_host=""

    # common variable

    local CURRENT_ARCH_FLAGS=""
    local CURRENT_ARCH_LINK=""

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
        log_error_print "FFMPEG_CURRENT_ARCH=$FFMPEG_CURRENT_ARCH is error."
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

    lv_host=$CURRENT_TRIPLE_armv7a
    lv_extra_cflags=$CFLAGS
    lv_extra_asflags=$lv_extra_cflags
    lv_extra_ldflags=$lv_extra_cflags

    log_var_split_print "lv_prefix=$lv_prefix"
    log_var_split_print "lv_extra_asflags=$lv_extra_asflags"
    log_var_split_print "lv_extra_cflags=$lv_extra_cflags"
    log_var_split_print "lv_extra_ldflags=$lv_extra_ldflags"
    log_var_split_print "lv_extra_rcflags=$lv_extra_rcflags"
    log_var_split_print "lv_other_options=$lv_other_options"
    log_var_split_print "lv_host=$lv_host"

    local lv_configure_file="${FFMPEG_SRC_XXX_DIR}/${FFMPEG_XXX_FULL_NAME}}/configure"
    log_var_split_print "lv_configure_file=$lv_configure_file"

    log_debug_print "$lv_configure_file in progress ..."
    read -n1 -p "Press any key to continue..."

    pushd .

    cd ${lv_tmp_dir}

    sh $lv_configure_file \
        --prefix="${lv_prefix}" \
        --host="${lv_host}" \
        --extra-asflags="${lv_extra_asflags}" \
        --extra-cflags="${lv_extra_cflags}" \
        --extra-ldflags="${lv_extra_ldflags}" \
        "${lv_other_options}" >${FFMPEG_LOG} 2>&1 || log_error_print "Configuration error. See log (${FFMPEG_LOG}) for details."

    log_debug_print "make and make install in progress ..."
    read -n1 -p "Press any key to continue..."

    make clean >>${FFMPEG_LOG} 2>&1 || log_error_print "Make clean error. See log (${FFMPEG_LOG}) for details."
    make -j${FFMPEG_WORK_THREAD_COUNT} install >>${FFMPEG_LOG} 2>&1 || log_error_print "Make or install error. See log (${FFMPEG_LOG}) for details."

    popd

    log_info_print "ffm_lib_build_x264_android end..."
}
function ffm_lib_lipo_x264_ios() {
    log_info_print "ffm_lib_lipo_x264_ios start..."

    log_info_print "ffm_lib_lipo_x264_ios end..."
}
function ffm_lib_lipo_x264_android() {
    log_info_print "ffm_lib_lipo_x264_android start..."

    log_info_print "ffm_lib_lipo_x264_android end..."
}

echo "###############################################################################" >/dev/null
echo "#### Process control partition                                            #####" >/dev/null
echo "###############################################################################" >/dev/null

# function ffm_lib_x264_ios_auto() {
    
# }
# function ffm_lib_x264_android_auto() {
    
# }

echo "###############################################################################" >/dev/null
echo "#### Function test partition                                              #####" >/dev/null
echo "###############################################################################" >/dev/null

# ffm_lib_xxx
# ffm_lib_clean_xxx
# ffm_lib_mkdir_xxx
# ffm_lib_prerequisites_xxx
# ffm_lib_build_xxx
# ffm_lib_lipo_xxx

echo ""
read -n1 -p "Press any key to continue..."
