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
echo "# Build lame library                                                          #" >/dev/null
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

FFMPEG_XXX_FULL_NAME="${FFMPEG_XXX_NAME}-${FFMPEG_XXX_VERSION}"

echo "###############################################################################" >/dev/null
echo "#### Variable declarations partition on Android                           #####" >/dev/null
echo "###############################################################################" >/dev/null

echo "###############################################################################" >/dev/null
echo "#### Function implementation partition                                    #####" >/dev/null
echo "###############################################################################" >/dev/null

function ffm_lib_clean_lame() {
    log_info_print "ffm_lib_clean_lame start..."
    if test -d $FFMPEG_TMP_OS_XXX_TMP_DIR; then
        rm -rf $FFMPEG_TMP_OS_XXX_TMP_DIR
    fi
    if test -d $FFMPEG_TMP_OS_XXX_OUTPUT_DIR; then
        rm -rf $FFMPEG_TMP_OS_XXX_OUTPUT_DIR
    fi
    if test -d $FFMPEG_TMP_OS_XXX_SRC_DIR/$FFMPEG_XXX_FULL_NAME; then
        rm -rf $FFMPEG_TMP_OS_XXX_SRC_DIR/$FFMPEG_XXX_FULL_NAME
    fi
    log_info_print "ffm_lib_clean_lame end..."
}
function ffm_lib_mkdir_lame() {
    log_info_print "ffm_lib_mkdir_lame start..."
    if test ! -d $FFMPEG_TMP_OS_XXX_TMP_DIR; then
        mkdir -p $FFMPEG_TMP_OS_XXX_TMP_DIR
    fi
    if test ! -d $FFMPEG_TMP_OS_XXX_OUTPUT_DIR; then
        mkdir -p $FFMPEG_TMP_OS_XXX_OUTPUT_DIR
    fi
    if test ! -d $FFMPEG_TMP_OS_XXX_SRC_DIR; then
        mkdir -p $FFMPEG_TMP_OS_XXX_SRC_DIR
    fi
    log_info_print "ffm_lib_mkdir_lame end..."
}
function ffm_lib_prerequisites_lame() {
    # 库的预处理部分：包括：安装依赖环境、下载源码等操作。
    log_info_print "ffm_lib_prerequisites_lame start..."

    if [ ! $(which ncurses) ]; then
        log_warning_print "ncurses not found. Trying to install..."
        brew install ncurses || log_error_print "ncurses install fail."

        log_warning_print "create ncurses symbolic link ..."
        pushd .
        cd /usr/local/opt/ncurses/bin
        local lv_file_name=($(ls | grep "ncurses"))
        log_var_split_print "lv_file_name=${lv_file_name[@]}"
        ln -f -s "${lv_file_name[0]}" "ncurses"
        popd

        # ref: https://stackoverflow.com/questions/56784894/macos-catalina-10-15beta-why-is-bash-profile-not-sourced-by-my-shell
        # Apple has changed the default shell to zsh. Therefore you have to rename your configuration files. .bashrc is now .zshrc and .bash_profile is now .zprofile.
        local lv_profile_name=""
        local lv_os_version=($(uname -r | sed "s/\./ /g"))
        if [ 18 -lt ${lv_os_version[0]} ]; then
            lv_profile_name=".zshrc"
        else
            lv_profile_name=".bash_profile"
        fi

        log_warning_print "modify system setting $lv_profile_name ..."
        echo '' >>~/$lv_profile_name
        echo 'export PATH="/usr/local/opt/ncurses/bin:$PATH"' >>~/$lv_profile_name
        echo 'export LDFLAGS="-L/usr/local/opt/ncurses/lib $LDFLAGS"' >>~/$lv_profile_name
        echo 'export CPPFLAGS="-I/usr/local/opt/ncurses/include $CPPFLAGS"' >>~/$lv_profile_name
        echo 'export PKG_CONFIG_PATH="/usr/local/opt/ncurses/lib/pkgconfig"' >>~/$lv_profile_name
        source ~/$lv_profile_name
    fi

    local local_src_zip="${FFMPEG_TMP_OS_XXX_SRC_DIR}/${FFMPEG_XXX_FULL_NAME}.tar.gz"
    local local_src=${FFMPEG_TMP_OS_XXX_SRC_DIR}/${FFMPEG_XXX_FULL_NAME}
    if [ ! -r $local_src_zip ]; then
        log_warning_print "${FFMPEG_XXX_NAME} source file not found. Trying to download..."
        log_debug_print "download url: https://jaist.dl.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz"
        local DOWNLOAD_SUCCESS="yes"
        curl -L "https://jaist.dl.sourceforge.net/project/lame/lame/${FFMPEG_XXX_VERSION}/${FFMPEG_XXX_NAME}-${FFMPEG_XXX_VERSION}.tar.gz" >$local_src_zip || DOWNLOAD_SUCCESS="no"
        if [ "no" = $DOWNLOAD_SUCCESS ]; then
            log_error_print "${FFMPEG_XXX_NAME} src download fail." && rm -rf ${local_src_zip}
        fi
    fi
    # rm -rf "$local_src"
    if [ ! -d "$local_src" ]; then
        local uncompress_success="yes"
        tar -x -C "${FFMPEG_TMP_OS_XXX_SRC_DIR}" -f "$local_src_zip" || uncompress_success="no"
        if [ "no" = uncompress_success ]; then
            log_error_print "ffmpeg src uncompress fail." && rm -rf ${local_src}
        fi
    fi

    log_info_print "ffm_lib_prerequisites_lame end..."
}
function ffm_lib_build_lame_ios() {
    log_info_print "ffm_lib_build_lame_ios start..."
    log_info_print "ffm_lib_build_lame_ios params_count="$# "params_content="$@

    local lv_tmp_dir="${FFMPEG_TMP_OS_XXX_TMP_DIR}/${FFMPEG_CURRENT_ARCH}"
    local lv_output_dir="${FFMPEG_TMP_OS_XXX_OUTPUT_DIR}/${FFMPEG_CURRENT_ARCH}"
    local lv_platform_trait=""
    local lv_device_type=""

    # local variable
    local lv_prefix=$lv_output_dir
    local lv_extra_asflags=""
    local lv_cflags="-arch ${FFMPEG_CURRENT_ARCH} -std=c11"
    local lv_cxxflags="-arch ${FFMPEG_CURRENT_ARCH} -std=c++11"
    local lv_ldflags=""
    local lv_other_options="--enable-static=yes --enable-shared=no --enable-mp3x --enable-mp3rtp"
    local lv_host=""
    local lv_cc=""
    local lv_cxx=""
    local lv_as=""
    local lv_ar=""

    if [ "armv7" = ${FFMPEG_CURRENT_ARCH} ]; then
        lv_cflags="$lv_cflags -mios-version-min=$IOS_DEPLOYMENT_MIN_TARGET -fembed-bitcode"
        lv_cxxflags="$lv_cxxflags -mios-version-min=$IOS_DEPLOYMENT_MIN_TARGET -fembed-bitcode"
        lv_host="arm-apple-darwin"
        local lv_device_type="iPhoneOS"
        lv_device_type=$(echo ${lv_device_type} | tr '[:upper:]' '[:lower:]')
        lv_cc="xcrun -sdk ${lv_device_type} clang"
        lv_ar="xcrun -sdk ${lv_device_type} ar"
        lv_cxx="xcrun -sdk ${lv_device_type} clang++"
        lv_as="gas-preprocessor.pl -arch arm -- $lv_cc"
    elif [ "arm64" = ${FFMPEG_CURRENT_ARCH} ]; then
        lv_cflags="$lv_cflags -mios-version-min=$IOS_DEPLOYMENT_MIN_TARGET -fembed-bitcode"
        lv_cxxflags="$lv_cxxflags -mios-version-min=$IOS_DEPLOYMENT_MIN_TARGET -fembed-bitcode"
        lv_host="aarch64-apple-darwin"
        lv_device_type="iPhoneOS"
        lv_device_type=$(echo ${lv_device_type} | tr '[:upper:]' '[:lower:]')
        lv_cc="xcrun -sdk ${lv_device_type} clang"
        lv_ar="xcrun -sdk ${lv_device_type} ar"
        lv_cxx="xcrun -sdk ${lv_device_type} clang++"
        lv_as="gas-preprocessor.pl -arch aarch64 -- $lv_cc"
    elif [ "i386" = ${FFMPEG_CURRENT_ARCH} ]; then
        lv_cflags="${lv_cflags} -mios-simulator-version-min=$IOS_DEPLOYMENT_MIN_TARGET"
        lv_cxxflags="${lv_cxxflags} -mios-simulator-version-min=$IOS_DEPLOYMENT_MIN_TARGET"
        lv_host="i386-apple-darwin"
        lv_device_type="iPhoneSimulator"
        lv_device_type=$(echo ${lv_device_type} | tr '[:upper:]' '[:lower:]')
        lv_cc="xcrun -sdk ${lv_device_type} clang"
        lv_ar="xcrun -sdk ${lv_device_type} ar"
        lv_cxx="xcrun -sdk ${lv_device_type} clang++"
        lv_as="$lv_cc"
        lv_platform_trait="--disable-asm"
    elif [ "x86_64" = ${FFMPEG_CURRENT_ARCH} ]; then
        lv_cflags="${lv_cflags} -mios-simulator-version-min=$IOS_DEPLOYMENT_MIN_TARGET"
        lv_cxxflags="${lv_cxxflags} -mios-simulator-version-min=$IOS_DEPLOYMENT_MIN_TARGET"
        # Omit the lv_host assignment, the system will use config.guess to fill in automatically.
        lv_host="x86_64-apple-darwin"
        lv_device_type="iPhoneSimulator"
        lv_device_type=$(echo ${lv_device_type} | tr '[:upper:]' '[:lower:]')
        lv_cc="xcrun -sdk ${lv_device_type} clang"
        lv_ar="xcrun -sdk ${lv_device_type} ar"
        lv_cxx="xcrun -sdk ${lv_device_type} clang++"
        lv_as="$lv_cc"
        lv_platform_trait="--disable-asm"
    fi

    lv_extra_asflags=$lv_cflags
    lv_ldflags=$lv_cflags
    lv_other_options="$lv_other_options $lv_platform_trait"

    log_var_split_print "lv_cc=$lv_cc"
    log_var_split_print "lv_cxx=$lv_cxx"
    log_var_split_print "lv_as=$lv_as"
    log_var_split_print "lv_ar=$lv_ar"

    log_var_split_print "lv_platform_trait=$lv_platform_trait"
    log_var_split_print "lv_device_type=$lv_device_type"

    log_var_split_print "lv_prefix=$lv_prefix"
    log_var_split_print "lv_extra_asflags=$lv_extra_asflags"
    log_var_split_print "lv_cflags=$lv_cflags"
    log_var_split_print "lv_cxxflags=$lv_cxxflags"
    log_var_split_print "lv_ldflags=$lv_ldflags"
    log_var_split_print "lv_other_options=$lv_other_options"
    log_var_split_print "lv_host=$lv_host"

    local lv_configure_file="${FFMPEG_TMP_OS_XXX_SRC_DIR}/${FFMPEG_XXX_FULL_NAME}/configure"
    log_var_split_print "lv_configure_file=$lv_configure_file"

    log_debug_print "$lv_configure_file in progress ..."
    # read -n1 -p "Press any key to continue..."

    pushd .

    cd ${lv_tmp_dir}

    export CC="$lv_cc $lv_cflags"
    export CXX="$lv_cxx $lv_cxxflags"
    export AR=$lv_ar
    export LD=$CC

    sh $lv_configure_file \
        --prefix=${lv_prefix} \
        --host=${lv_host} \
        ${lv_other_options} >${FFMPEG_LOG} 2>&1 || log_error_print "Configuration error. See log (${FFMPEG_LOG}) for details."

    log_debug_print "make and make install in progress ..."
    # read -n1 -p "Press any key to continue..."

    make clean >>${FFMPEG_LOG} 2>&1 || log_error_print "Make clean error. See log (${FFMPEG_LOG}) for details."
    make -j${FFMPEG_WORK_THREAD_COUNT} install >>${FFMPEG_LOG} 2>&1 || log_error_print "Make or install error. See log (${FFMPEG_LOG}) for details."

    popd

    log_info_print "ffm_lib_build_lame_ios end..."
}
function ffm_lib_build_lame_android() {
    log_info_print "ffm_lib_build_lame_android start..."
    log_info_print "ffm_lib_build_lame_android params_count="$# "params_content="$@

    local lv_tmp_dir="${FFMPEG_TMP_OS_XXX_TMP_DIR}/${FFMPEG_CURRENT_ARCH}"
    local lv_output_dir="${FFMPEG_TMP_OS_XXX_OUTPUT_DIR}/${FFMPEG_CURRENT_ARCH}"
    local lv_platform_trait=""

    # local variable
    local lv_prefix=$lv_output_dir
    local lv_extra_asflags=""
    local lv_cflags="-arch ${FFMPEG_CURRENT_ARCH} -std=c11"
    local lv_cxxflags="-arch ${FFMPEG_CURRENT_ARCH} -std=c++11"
    local lv_ldflags=""
    local lv_other_options="--enable-static=yes --enable-shared=yes --enable-mp3x --enable-mp3rtp"
    local lv_host=""

    # common variable

    local CURRENT_ARCH_FLAGS=""
    local CURRENT_ARCH_LINK=""

    local CURRENT_ARCH=""
    local CURRENT_TRIPLE_armv7a=""
    local CURRENT_CPU=""

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
    elif [ "arm64-v8a" = ${FFMPEG_CURRENT_ARCH} ]; then
        ANDROID_CURRENT_TRIPLE=${ANDROID_ABI_TRIPLES[1]}
        CURRENT_TRIPLE_armv7a=$ANDROID_CURRENT_TRIPLE
        ANDROID_CURRENT_ABI=${ANDROID_ABIS[1]}
        ANDROID_CURRENT_MARCH=${ANDROID_MARCHS[1]}
        CURRENT_ARCH="aarch64"
    elif [ "x86" = ${FFMPEG_CURRENT_ARCH} ]; then
        CURRENT_ARCH_FLAGS="-march=i686 -mtune=intel -msse3 -mfpmath=sse -m32"
        ANDROID_CURRENT_TRIPLE=${ANDROID_ABI_TRIPLES[2]}
        CURRENT_TRIPLE_armv7a=$ANDROID_CURRENT_TRIPLE
        ANDROID_CURRENT_ABI=${ANDROID_ABIS[2]}
        ANDROID_CURRENT_MARCH=${ANDROID_MARCHS[2]}
        CURRENT_ARCH="x86"
        lv_platform_trait="--disable-asm"
    elif [ "x86_64" = ${FFMPEG_CURRENT_ARCH} ]; then
        CURRENT_ARCH_FLAGS="-march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=intel"
        ANDROID_CURRENT_TRIPLE=${ANDROID_ABI_TRIPLES[3]}
        CURRENT_TRIPLE_armv7a=$ANDROID_CURRENT_TRIPLE
        ANDROID_CURRENT_ABI=${ANDROID_ABIS[3]}
        ANDROID_CURRENT_MARCH=${ANDROID_MARCHS[3]}
        CURRENT_ARCH="x86_64"
        lv_platform_trait="--disable-asm"
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

    export CC="$CC $CFLAGS"
    export CXX="$CXX $CXXFLAGS"

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

    lv_other_options="${lv_other_options} ${lv_platform_trait}"
    lv_host=$CURRENT_TRIPLE_armv7a
    lv_cflags=$CFLAGS
    lv_extra_asflags=$lv_cflags
    lv_ldflags=$lv_cflags

    log_var_split_print "lv_prefix=$lv_prefix"
    log_var_split_print "lv_extra_asflags=$lv_extra_asflags"
    log_var_split_print "lv_cflags=$lv_cflags"
    log_var_split_print "lv_ldflags=$lv_ldflags"
    log_var_split_print "lv_other_options=$lv_other_options"
    log_var_split_print "lv_host=$lv_host"

    local lv_configure_file="${FFMPEG_TMP_OS_XXX_SRC_DIR}/${FFMPEG_XXX_FULL_NAME}/configure"
    log_var_split_print "lv_configure_file=$lv_configure_file"

    log_debug_print "$lv_configure_file in progress ..."
    # read -n1 -p "Press any key to continue..."

    pushd .

    cd ${lv_tmp_dir}

    sh $lv_configure_file \
        --prefix=${lv_prefix} \
        --host=${lv_host} \
        ${lv_other_options} >${FFMPEG_LOG} 2>&1 || log_error_print "Configuration error. See log (${FFMPEG_LOG}) for details."

    log_debug_print "make and make install in progress ..."
    # read -n1 -p "Press any key to continue..."

    make clean >>${FFMPEG_LOG} 2>&1 || log_error_print "Make clean error. See log (${FFMPEG_LOG}) for details."
    make -j${FFMPEG_WORK_THREAD_COUNT} install >>${FFMPEG_LOG} 2>&1 || log_error_print "Make or install error. See log (${FFMPEG_LOG}) for details."

    popd

    log_info_print "ffm_lib_build_lame_android end..."
}
function ffm_lib_lipo_lame_ios() {
    log_info_print "ffm_lib_lipo_lame_ios start..."

    log_info_print "ffm_lib_lipo_lame_ios end..."
}
function ffm_lib_lipo_lame_android() {
    log_info_print "ffm_lib_lipo_lame_android start..."

    log_info_print "ffm_lib_lipo_lame_android end..."
}

echo "###############################################################################" >/dev/null
echo "#### Process control partition                                            #####" >/dev/null
echo "###############################################################################" >/dev/null

# function ffm_lib_lame_ios_auto() {

# }
# function ffm_lib_lame_android_auto() {

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

# echo ""
# read -n1 -p "Press any key to continue..."
