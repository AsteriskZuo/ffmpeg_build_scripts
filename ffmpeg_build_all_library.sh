#!/bin/sh

source ./ffmpeg_global_variable.sh

log_head_print "###############################################################################"
log_head_print "# Script Summary:                                                             #"
log_head_print "# Author:                  yu.zuo                                             #"
log_head_print "# Create Date:             2020.03.23                                         #"
log_head_print "# Update Date:             2020.03.31                                         #"
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

echo "###############################################################################" >/dev/null
echo "#### Help instruction partition                                           #####" >/dev/null
echo "###############################################################################" >/dev/null

function ffmpeg_is_in() {
    local value=$1
    shift
    for var in $@; do
        [ $var = $value ] && return 0
    done
    return 1
}

function show_help() {
    log_info_print "

Usage: $0 [options]
Options: [defaults in brackets after descriptions]

Help options:
  --help|-h                print this message

  --ios[=?]                only build iOS library ["armv7","arm64","x86_64"]
  --android[=?]            only build Android library ["armeabi-v7a","arm64-v8a","x86_64"]
  --all                    build all library (same without arguments)

  --eael=<?>               enable all external library, detail for FFMPEG_BOOL_SET variable
  --wtc=<?>                work thread count for make commandline, detail for FFMPEG_WORK_THREAD_COUNT_SET variable
  --csd[=?:]               clean src directory, detail for FFMPEG_ALL_CLEAN_TYPE variable, example --csd=src:tmp:tool

Parameter setting:
  FFMPEG_ENABLE_LOG_FILE:      whether to print logs to files [yes]
  FFMPEG_ALL_TARGET_OS:        what the build platform includes ["iOS" "Android"]
  FFMPEG_ALL_ARCH_ON_IOS:      what the build type of iOS platform includes ["armv7" "arm64" "x86_64"]
  FFMPEG_ALL_ARCH_ON_ANDROID:  what the build type of Android platform includes ["armeabi-v7a" "arm64-v8a" "x86_64"]
  ANDROID_NDK_DIR:             Android ndk root directory (you must set up ! )
  IOS_DEPLOYMENT_MIN_TARGET:   the lowest version supported by iOS [8.0]
  ANDROID_API:                 the lowest version supported by Android [23]
  ANDROID_ENABLE_STANDALONE_TOOLCHAIN: whether to use standalone toolchain for Android [no]
  FFMPEG_ENABLE_ALL_EXTERNAL_LIBRARY: whether to enable all ffmpeg external library [no]
  FFMPEG_WORK_THREAD_COUNT:    work thread count for make command line [4]
  FFMPEG_ALL_CLEAN_TYPE:       clean src directory, default no any thing
"
    exit 0
}

opt_count=$#
opt=$*
# log_var_print "opt=$opt"
# log_var_print "opt_count=$opt_count"

if [ ! $opt ]; then
    show_help
fi

for opt; do
    optval="${opt#*=}"
    case "$opt" in
    --help | -h)
        show_help
        ;;
    --ios | --iOS | --ios=* | --iOS=*)
        FFMPEG_ALL_TARGET_OS=("iOS")
        FFMPEG_ALL_ARCH_ON_ANDROID=()
        if ffmpeg_is_in $optval ${FFMPEG_ALL_ARCH_ON_IOS[@]}; then
            FFMPEG_ALL_ARCH_ON_IOS=($optval)
        else
            a=1
        fi
        ;;
    --android | --Android | --android=* | --Android=*)
        FFMPEG_ALL_TARGET_OS=("Android")
        FFMPEG_ALL_ARCH_ON_IOS=()
        if ffmpeg_is_in $optval ${FFMPEG_ALL_ARCH_ON_ANDROID[@]}; then
            FFMPEG_ALL_ARCH_ON_ANDROID=($optval)
        else
            a=1
        fi
        ;;
    --all)
        FFMPEG_ALL_TARGET_OS=("iOS" "Android")
        ;;
    --eael=*)
        if ffmpeg_is_in $optval ${FFMPEG_BOOL_SET[@]}; then
            FFMPEG_ENABLE_ALL_EXTERNAL_LIBRARY=($optval)
        else
            a=1
        fi
        ;;
    --wtc=*)
        if ffmpeg_is_in $optval ${FFMPEG_WORK_THREAD_COUNT_SET[@]}; then
            FFMPEG_WORK_THREAD_COUNT=($optval)
        else
            a=1
        fi
        ;;
    --csd | --csd=*)
        if [ "--csd" = "$opt" ]; then
            FFMPEG_ALL_CLEAN_TYPE=${FFMPEG_ALL_CLEAN_TYPE_PREDEFINE[@]}
        else
            FFMPEG_ALL_CLEAN_TYPE=()
            ALL_CLEAN_TYPE=($(echo ${optval} | sed "s/:/ /g"))
            ALL_CLEAN_TYPE_DEFINE=${FFMPEG_ALL_CLEAN_TYPE_PREDEFINE[@]}
            for CLEAN_TYPE in ${ALL_CLEAN_TYPE[@]}; do
                if ffmpeg_is_in $CLEAN_TYPE ${ALL_CLEAN_TYPE_DEFINE[@]}; then
                    FFMPEG_ALL_CLEAN_TYPE[${#FFMPEG_ALL_CLEAN_TYPE[@]}]=$CLEAN_TYPE
                fi
            done
        fi
        ;;
    *)
        show_help
        ;;
    esac
done

log_head_print "###############################################################################"
log_head_print "#### Debug setting partition                                              #####"
log_head_print "###############################################################################"

# set: usage: set [--abefhkmnptuvxBCHP] [-o option] [arg ...]
# read -n1 -p "Press any key to continue..."

log_var_split_print "FFMPEG_ENABLE_LOG_FILE=$FFMPEG_ENABLE_LOG_FILE"
log_var_split_print "FFMPEG_WORK_THREAD_COUNT=$FFMPEG_WORK_THREAD_COUNT"
log_var_split_print "FFMPEG_ALL_CLEAN_TYPE=${FFMPEG_ALL_CLEAN_TYPE[@]}"

log_head_print "###############################################################################"
log_head_print "#### Variable declarations partition                                      #####"
log_head_print "###############################################################################"

log_var_split_print "FFMPEG_ALL_TARGET_OS=${FFMPEG_ALL_TARGET_OS[@]}"
log_var_split_print "FFMPEG_ALL_ARCH_ON_IOS=${FFMPEG_ALL_ARCH_ON_IOS[@]}"
log_var_split_print "FFMPEG_ALL_ARCH_ON_ANDROID=${FFMPEG_ALL_ARCH_ON_ANDROID[@]}"

log_var_split_print "FFMPEG_NAME=$FFMPEG_NAME"
log_var_split_print "FFMPEG_VERSION=$FFMPEG_VERSION"
log_var_split_print "FFMPEG_FULL_NAME=$FFMPEG_FULL_NAME"
log_var_split_print "FFMPEG_XXX_NAME=$FFMPEG_XXX_NAME"
log_var_split_print "FFMPEG_XXX_VERSION=$FFMPEG_XXX_VERSION"
log_var_split_print "FFMPEG_XXX_FULL_NAME=$FFMPEG_XXX_FULL_NAME"
log_var_split_print "FFMPEG_XXX_URL=$FFMPEG_XXX_URL"

log_var_split_print "FFMPEG_ROOT_DIR=$FFMPEG_ROOT_DIR"
log_var_split_print "FFMPEG_SH_SUB_DIR=$FFMPEG_SH_SUB_DIR"
log_var_split_print "FFMPEG_SRC_DIR=$FFMPEG_SRC_DIR"
log_var_split_print "FFMPEG_TMP_DIR=$FFMPEG_TMP_DIR"
log_var_split_print "FFMPEG_TOOL_DIR=$FFMPEG_TOOL_DIR"
log_var_split_print "FFMPEG_TEST_DIR=$FFMPEG_TEST_DIR"
log_var_split_print "FFMPEG_SRC_XXX_DIR=$FFMPEG_SRC_XXX_DIR"

log_var_split_print "FFMPEG_CURRENT_DIR=$FFMPEG_CURRENT_DIR"

log_var_split_print "FFMPEG_TMP_OS_LIPO_DIR=$FFMPEG_TMP_OS_LIPO_DIR"
log_var_split_print "FFMPEG_TMP_OS_LOG_DIR=$FFMPEG_TMP_OS_LOG_DIR"
log_var_split_print "FFMPEG_TMP_OS_XXX_DIR=$FFMPEG_TMP_OS_XXX_DIR"
log_var_split_print "FFMPEG_TMP_OS_XXX_TMP_DIR=$FFMPEG_TMP_OS_XXX_TMP_DIR"
log_var_split_print "FFMPEG_TMP_OS_XXX_OUTPUT_DIR=$FFMPEG_TMP_OS_XXX_OUTPUT_DIR"
log_var_split_print "FFMPEG_TMP_OS_XXX_SRC_DIR=$FFMPEG_TMP_OS_XXX_SRC_DIR"

log_var_split_print "FFMPEG_CURRENT_TARGET_OS=$FFMPEG_CURRENT_TARGET_OS"
log_var_split_print "FFMPEG_CURRENT_ARCH=$FFMPEG_CURRENT_ARCH"

log_var_split_print "FFMPEG_LOG=$FFMPEG_LOG"

log_head_print "###############################################################################"
log_head_print "#### Variable declarations partition on iOS                               #####"
log_head_print "###############################################################################"

log_var_split_print "IOS_DEPLOYMENT_MIN_TARGET=$IOS_DEPLOYMENT_MIN_TARGET"

log_head_print "###############################################################################"
log_head_print "#### Variable declarations partition on Android                           #####"
log_head_print "###############################################################################"

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
log_head_print "#### external library partition                                           #####"
log_head_print "###############################################################################"

log_var_split_print "FFMPEG_ENABLE_ALL_EXTERNAL_LIBRARY=$FFMPEG_ENABLE_ALL_EXTERNAL_LIBRARY"

if [ "yes" == $FFMPEG_ENABLE_ALL_EXTERNAL_LIBRARY ]; then
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_aom_enable=$FFMPEG_EXTERNAL_LIBRARY_aom_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_frei0r_enable=$FFMPEG_EXTERNAL_LIBRARY_frei0r_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_lame_enable=$FFMPEG_EXTERNAL_LIBRARY_lame_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_libass_enable=$FFMPEG_EXTERNAL_LIBRARY_libass_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_libbluray_enable=$FFMPEG_EXTERNAL_LIBRARY_libbluray_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_libsoxr_enable=$FFMPEG_EXTERNAL_LIBRARY_libsoxr_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_libvidstab_enable=$FFMPEG_EXTERNAL_LIBRARY_libvidstab_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_libvorbis_enable=$FFMPEG_EXTERNAL_LIBRARY_libvorbis_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_libvpx_enable=$FFMPEG_EXTERNAL_LIBRARY_libvpx_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_opencore_amr_enable=$FFMPEG_EXTERNAL_LIBRARY_opencore_amr_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_openjpeg_enable=$FFMPEG_EXTERNAL_LIBRARY_openjpeg_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_opus_enable=$FFMPEG_EXTERNAL_LIBRARY_opus_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_rtmpdump_enable=$FFMPEG_EXTERNAL_LIBRARY_rtmpdump_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_rubberband_enable=$FFMPEG_EXTERNAL_LIBRARY_rubberband_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_sdl2_enable=$FFMPEG_EXTERNAL_LIBRARY_sdl2_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_snappy_enable=$FFMPEG_EXTERNAL_LIBRARY_snappy_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_speex_enable=$FFMPEG_EXTERNAL_LIBRARY_speex_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_tesseract_enable=$FFMPEG_EXTERNAL_LIBRARY_tesseract_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_theora_enable=$FFMPEG_EXTERNAL_LIBRARY_theora_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_webp_enable=$FFMPEG_EXTERNAL_LIBRARY_webp_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_X264_enable=$FFMPEG_EXTERNAL_LIBRARY_X264_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_x265_enable=$FFMPEG_EXTERNAL_LIBRARY_x265_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_xvid_enable=$FFMPEG_EXTERNAL_LIBRARY_xvid_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_xz_enable=$FFMPEG_EXTERNAL_LIBRARY_xz_enable"
    log_var_split_print "FFMPEG_EXTERNAL_LIBRARY_openssl_enable=$FFMPEG_EXTERNAL_LIBRARY_openssl_enable"
else
    FFMPEG_EXTERNAL_LIBRARY_aom_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_frei0r_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_lame_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_libass_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_libbluray_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_libsoxr_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_libvidstab_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_libvorbis_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_libvpx_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_opencore_amr_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_openjpeg_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_opus_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_rtmpdump_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_rubberband_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_sdl2_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_snappy_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_speex_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_tesseract_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_theora_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_webp_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_X264_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_x265_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_xvid_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_xz_enable="no"
    FFMPEG_EXTERNAL_LIBRARY_openssl_enable="no"
fi

if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_aom_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_aom; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_frei0r_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_frei0r; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_lame_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_lame; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_libass_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_libass; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_libbluray_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_libbluray; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_libsoxr_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_libsoxr; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_libvidstab_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_libvidstab; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_libvorbis_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_libvorbis; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_libvpx_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_libvpx; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_opencore_amr_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_opencore_amr; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_openjpeg_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_openjpeg; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_opus_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_opus; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_rtmpdump_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_rtmpdump; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_rubberband_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_rubberband; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_sdl2_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_sdl2; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_snappy_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_snappy; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_speex_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_speex; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_tesseract_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_tesseract; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_theora_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_theora; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_webp_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_webp; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_X264_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_X264; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_x265_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_x265; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_xvid_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_xvid; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_xz_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_xz; fi
if [ "yes" = $FFMPEG_EXTERNAL_LIBRARY_openssl_enable ]; then FFMPEG_ALL_BUILD_LIBRARY[${#FFMPEG_ALL_BUILD_LIBRARY[@]}]=$FFMPEG_EXTERNAL_LIBRARY_openssl; fi

log_var_split_print "FFMPEG_ALL_BUILD_LIBRARY=${FFMPEG_ALL_BUILD_LIBRARY[@]}"

read -n1 -p "Confirm parameters, press any key to continue, otherwise CTRL + C terminates..."

log_head_print "###############################################################################"
log_head_print "#### Function implementation partition                                    #####"
log_head_print "###############################################################################"

function ffmpeg_output_log_control() {
    if [ "yes" != $FFMPEG_ENABLE_LOG_FILE ]; then
        FFMPEG_LOG=""
    fi
}

function ffmpeg_clean_src() {
    log_info_print "ffmpeg_clean_src start..."
    if test -d $FFMPEG_SRC_DIR; then
        rm -rf $FFMPEG_SRC_DIR
    fi
    log_info_print "ffmpeg_clean_src end..."
}
function ffmpeg_clean_tmp() {
    log_info_print "ffmpeg_clean_tmp start..."
    if test -d $FFMPEG_TMP_DIR; then
        rm -rf $FFMPEG_TMP_DIR
    fi
    log_info_print "ffmpeg_clean_tmp end..."
}
function ffmpeg_clean_tool() {
    log_info_print "ffmpeg_clean_tool start..."
    if test -d $FFMPEG_TOOL_DIR; then
        rm -rf $FFMPEG_TOOL_DIR
    fi
    log_info_print "ffmpeg_clean_tool end..."
}
function ffmpeg_clean() {
    # clean tmp and output dir
    log_info_print "ffmpeg_clean start..."
    for CLEAN_TYPE in ${FFMPEG_ALL_CLEAN_TYPE[@]}; do
        if [ "src" = $CLEAN_TYPE ]; then
            ffmpeg_clean_src
        elif [ "tmp" = $CLEAN_TYPE ]; then
            ffmpeg_clean_tmp
        elif [ "tool" = $CLEAN_TYPE ]; then
            ffmpeg_clean_tool
        fi
    done
    log_info_print "ffmpeg_clean end..."
}

function ffmpeg_mkdir() {
    # make directory
    log_info_print "ffmpeg_mkdir start..."
    if test ! -d $FFMPEG_SRC_DIR; then
        mkdir -p $FFMPEG_SRC_DIR
    fi
    if test ! -d $FFMPEG_TMP_DIR; then
        mkdir -p $FFMPEG_TMP_DIR
    fi
    if test ! -d $FFMPEG_TOOL_DIR; then
        mkdir -p $FFMPEG_TOOL_DIR
    fi
    log_info_print "ffmpeg_mkdir end..."
}

function ffmpeg_prerequisites_ios() {
    log_info_print "ffmpeg_prerequisites_ios start..."

    if [ ! $(which perl) ]; then
        log_warning_print 'Perl not found. Trying to install...'
        brew install 'perl@5.18' || log_error_print "Perl install fail." && exit 1
    fi

    if [ ! $(which yasm) ]; then
        log_warning_print 'Yasm not found. Trying to install...'
        brew install yasm || log_error_print "Yasm install fail." && exit 1
    fi

    if [ ! $(which gas-preprocessor.pl) ]; then
        log_warning_print 'gas-preprocessor.pl not found. Trying to install...'
        log_debug_print "download url: https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl"
        curl -L https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl -o /usr/local/bin/gas-preprocessor.pl || log_error_print "download fail." && exit 1
        chmod +x /usr/local/bin/gas-preprocessor.pl || log_error_print "gas-preprocessor.pl install fail." && exit 1
    fi

    log_info_print "ffmpeg_prerequisites_ios end..."
}

function ffmpeg_prerequisites_android() {
    log_info_print "ffmpeg_prerequisites_android start..."

    if [ ! -d ${ANDROID_NDK_DIR} ]; then
        log_error_print "Please set android ndk dir." && exit 1
    fi

    if [ 19 -lt $ANDROID_API -a $ANDROID_API -le $ANDROID_MAX_API ]; then
        local a=1
    else
        log_error_print "ANDROID_API=$ANDROID_API is not support." && exit 1
    fi

    if [ ! $(which nasm) ]; then
        log_warning_print "Nasm not found. Trying to install..."
        brew install nasm || log_error_print "Nasm install fail." && exit 1
    fi

    # python 2.7.x
    if [ ! $(which python) ]; then
        log_warning_print "Python not found. Trying to install..."
        brew install python || log_error_print "Python 2.7.x install fail." && exit 1
    fi

    if [ "yes" = $ANDROID_ENABLE_STANDALONE_TOOLCHAIN ]; then

        ANDROID_TOOLCHAIN_DIR="$FFMPEG_TOOL_DIR/ffmpeg_android"
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
                    --install-dir=${ANDROID_TOOLCHAIN_DIR}/${MARCH} || log_error_print "Android toolchain install fail." && exit 1
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
        curl ${FFMPEG_URL} >${FFMPEG_FULL_NAME}.tar.bz2 || log_error_print "ffmpeg src download fail." && exit 1
        tar -x -f ${FFMPEG_FULL_NAME}.tar.bz2 || log_error_print "ffmpeg src uncompress fail." && exit 1
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
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" || log_error_print "brew install fail." && exit 1
    fi

    if [ ! $(which pkg-config) ]; then
        log_warning_print "Pkg-config not found. Trying to install..."
        brew install pkg-config || log_error_print "Pkg-config install fail." && exit 1
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

    local FROM_LIBRARY_DIR=${FFMPEG_TMP_OS_XXX_OUTPUT_DIR}
    local TO_LIBRARY_DIR=${FFMPEG_TMP_OS_LIPO_DIR}

    log_var_split_print "FROM_LIBRARY_DIR=$FROM_LIBRARY_DIR"
    log_var_split_print "TO_LIBRARY_DIR=$TO_LIBRARY_DIR"

    local LIBRARY_LIST=$(find ${FROM_LIBRARY_DIR}/${FFMPEG_ALL_ARCH_ON_IOS[0]} -name "*.a" | sed "s/^.*\///g")

    log_var_split_print "LIBRARY_LIST=${LIBRARY_LIST[@]}"

    for LIBRARY_FILE in ${LIBRARY_LIST[@]}; do
        log_var_split_print "LIBRARY_FILE=$LIBRARY_FILE"
        lipo -create $(find $FROM_LIBRARY_DIR -name $LIBRARY_FILE) -output $TO_LIBRARY_DIR/$LIBRARY_FILE || log_error_print "lipo fail." && exit 1
    done

    log_info_print "ffmpeg_lipo_iOS end..."
}

function ffmpeg_build_iOS() {
    log_info_print "ffmpeg_build_iOS start..."
    log_info_print "ffmpeg_build_iOS params_count="$# "params_content="$@

    local TMP_DIR="${FFMPEG_TMP_OS_XXX_TMP_DIR}/${FFMPEG_CURRENT_ARCH}"
    local OUTPUT_DIR="${FFMPEG_TMP_OS_XXX_OUTPUT_DIR}/${FFMPEG_CURRENT_ARCH}"
    local PLATFORM_TRAIT=""
    local DEVICE_TYPE=""

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

    # read -n1 -p "Press any key to continue..."

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
        --disable-doc >${FFMPEG_LOG} 2>&1 || log_error_print "Configuration error. See log (${FFMPEG_LOG}) for details." && exit 1

    read -n1 -p "Press any key to continue..."

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

    make clean >>${FFMPEG_LOG} 2>&1 || log_error_print "Make clean error. See log (${FFMPEG_LOG}) for details." && exit 1
    make -j${FFMPEG_WORK_THREAD_COUNT} install >>${FFMPEG_LOG} 2>&1 || log_error_print "Make or install error. See log (${FFMPEG_LOG}) for details." && exit 1

    popd

    log_info_print "ffmpeg_build_iOS end..."
}

function ffmpeg_build_Android() {
    log_info_print "ffmpeg_build_Android start..."
    log_info_print "ffmpeg_build_Android params_count="$# "params_content="$@

    local TMP_DIR="${FFMPEG_TMP_OS_XXX_TMP_DIR}/${FFMPEG_CURRENT_ARCH}"
    local OUTPUT_DIR="${FFMPEG_TMP_OS_XXX_OUTPUT_DIR}/${FFMPEG_CURRENT_ARCH}"

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

    # read -n1 -p "Press any key to continue..."

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
        --extra-ldflags="${LDFLAGS}" >${FFMPEG_LOG} 2>&1 || log_error_print "Configuration error. See log (${FFMPEG_LOG}) for details." && exit 1

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

    make clean >>${FFMPEG_LOG} 2>&1 || log_error_print "Make clean error. See log (${FFMPEG_LOG}) for details." && exit 1
    make -j${FFMPEG_WORK_THREAD_COUNT} install >>${FFMPEG_LOG} 2>&1 || log_error_print "Make or install error. See log (${FFMPEG_LOG}) for details." && exit 1

    popd

    log_info_print "ffmpeg_build_Android end..."
}

function ffmpeg_build_all() {
    log_info_print "ffmpeg_build_all start..."

    for ((i = 0; i < ${#FFMPEG_ALL_TARGET_OS[@]}; i++)); do

        FFMPEG_CURRENT_TARGET_OS=${FFMPEG_ALL_TARGET_OS[i]}
        FFMPEG_TMP_OS_LOG_DIR="${FFMPEG_TMP_DIR}/${FFMPEG_CURRENT_TARGET_OS}/log"
        FFMPEG_TMP_OS_LIPO_DIR="${FFMPEG_TMP_DIR}/${FFMPEG_CURRENT_TARGET_OS}/lipo"

        log_var_split_print "FFMPEG_CURRENT_TARGET_OS=${FFMPEG_CURRENT_TARGET_OS}"
        log_var_split_print "FFMPEG_TMP_OS_LOG_DIR=${FFMPEG_TMP_OS_LOG_DIR}"
        log_var_split_print "FFMPEG_TMP_OS_LIPO_DIR=${FFMPEG_TMP_OS_LIPO_DIR}"

        mkdir -p ${FFMPEG_TMP_OS_LOG_DIR}
        mkdir -p ${FFMPEG_TMP_OS_LIPO_DIR}

        if [ "iOS" = $FFMPEG_CURRENT_TARGET_OS ]; then
            log_info_print "ffmpeg_build_ios_all_library start..."

            for ((k = 0; k < ${#FFMPEG_ALL_BUILD_LIBRARY[@]}; k++)); do
                log_info_print "ffmpeg_build_ios_library ${FFMPEG_ALL_BUILD_LIBRARY[k]} start..."

                FFMPEG_TMP_OS_XXX_DIR="${FFMPEG_TMP_DIR}/${FFMPEG_CURRENT_TARGET_OS}/${FFMPEG_ALL_BUILD_LIBRARY[k]}"
                FFMPEG_TMP_OS_XXX_OUTPUT_DIR="${FFMPEG_TMP_OS_XXX_DIR}/output"
                FFMPEG_TMP_OS_XXX_TMP_DIR="${FFMPEG_TMP_OS_XXX_DIR}/tmp"
                FFMPEG_TMP_OS_XXX_SRC_DIR="${FFMPEG_TMP_OS_XXX_DIR}/${FFMPEG_ALL_BUILD_LIBRARY[k]}"

                FFMPEG_XXX_NAME="${FFMPEG_ALL_BUILD_LIBRARY[k]}"
                FFMPEG_XXX_VERSION=$(eval echo '$'"FFMPEG_EXTERNAL_LIBRARY_${FFMPEG_XXX_NAME}_version")
                FFMPEG_XXX_URL=$(eval echo '$'"FFMPEG_EXTERNAL_LIBRARY_${FFMPEG_XXX_NAME}_url")

                mkdir -p ${FFMPEG_TMP_OS_XXX_OUTPUT_DIR}
                mkdir -p ${FFMPEG_TMP_OS_XXX_TMP_DIR}
                mkdir -p ${FFMPEG_TMP_OS_XXX_SRC_DIR}

                log_var_split_print "FFMPEG_TMP_OS_XXX_DIR=$FFMPEG_TMP_OS_XXX_DIR"
                log_var_split_print "FFMPEG_TMP_OS_XXX_OUTPUT_DIR=$FFMPEG_TMP_OS_XXX_OUTPUT_DIR"
                log_var_split_print "FFMPEG_TMP_OS_XXX_TMP_DIR=$FFMPEG_TMP_OS_XXX_TMP_DIR"
                log_var_split_print "FFMPEG_TMP_OS_XXX_SRC_DIR=$FFMPEG_TMP_OS_XXX_SRC_DIR"

                log_var_split_print "FFMPEG_XXX_NAME=$FFMPEG_XXX_NAME"
                log_var_split_print "FFMPEG_XXX_VERSION=$FFMPEG_XXX_VERSION"
                log_var_split_print "FFMPEG_XXX_URL=$FFMPEG_XXX_URL"

                read -n1 -p "key..."

                for ((j = 0; j < ${#FFMPEG_ALL_ARCH_ON_IOS[@]}; j++)); do

                    FFMPEG_CURRENT_ARCH=${FFMPEG_ALL_ARCH_ON_IOS[j]}
                    FFMPEG_LOG="${FFMPEG_TMP_OS_LOG_DIR}/${FFMPEG_CURRENT_TARGET_OS}_${FFMPEG_ALL_BUILD_LIBRARY[k]}_${FFMPEG_CURRENT_ARCH}.log"

                    ffmpeg_output_log_control

                    log_var_split_print "FFMPEG_CURRENT_ARCH=${FFMPEG_CURRENT_ARCH}"
                    log_var_split_print "FFMPEG_LOG=$FFMPEG_LOG"

                    mkdir -p "${FFMPEG_TMP_OS_XXX_TMP_DIR}/${FFMPEG_CURRENT_ARCH}"
                    mkdir -p "${FFMPEG_TMP_OS_XXX_OUTPUT_DIR}/${FFMPEG_CURRENT_ARCH}"

                    ffmpeg_build_iOS ${FFMPEG_CURRENT_TARGET_OS} ${FFMPEG_CURRENT_ARCH} ${FFMPEG_ALL_BUILD_LIBRARY[k]}

                done

                ffmpeg_lipo_iOS ${FFMPEG_CURRENT_TARGET_OS} ${FFMPEG_ALL_BUILD_LIBRARY[k]}

                log_info_print "ffmpeg_build_ios_library ${FFMPEG_ALL_BUILD_LIBRARY[k]} end..."
            done

            log_info_print "ffmpeg_build_ios_all_library end..."
        elif [ "Android" = $FFMPEG_CURRENT_TARGET_OS ]; then
            log_info_print "ffmpeg_build_android_all_library start..."

            for ((k = 0; k < ${#FFMPEG_ALL_BUILD_LIBRARY[@]}; k++)); do
                log_info_print "ffmpeg_build_android_library ${FFMPEG_ALL_BUILD_LIBRARY[k]} start..."

                FFMPEG_TMP_OS_XXX_DIR="${FFMPEG_TMP_DIR}/${FFMPEG_CURRENT_TARGET_OS}/${FFMPEG_ALL_BUILD_LIBRARY[k]}"
                FFMPEG_TMP_OS_XXX_OUTPUT_DIR="${FFMPEG_TMP_OS_XXX_DIR}/output"
                FFMPEG_TMP_OS_XXX_TMP_DIR="${FFMPEG_TMP_OS_XXX_DIR}/tmp"
                FFMPEG_TMP_OS_XXX_SRC_DIR="${FFMPEG_TMP_OS_XXX_DIR}/${FFMPEG_ALL_BUILD_LIBRARY[k]}"

                FFMPEG_XXX_NAME="${FFMPEG_ALL_BUILD_LIBRARY[k]}"
                FFMPEG_XXX_VERSION=$(eval echo '$'"FFMPEG_EXTERNAL_LIBRARY_${FFMPEG_XXX_NAME}_version")
                FFMPEG_XXX_URL=$(eval echo '$'"FFMPEG_EXTERNAL_LIBRARY_${FFMPEG_XXX_NAME}_url")

                mkdir -p ${FFMPEG_TMP_OS_XXX_OUTPUT_DIR}
                mkdir -p ${FFMPEG_TMP_OS_XXX_TMP_DIR}
                mkdir -p ${FFMPEG_TMP_OS_XXX_SRC_DIR}

                log_var_split_print "FFMPEG_TMP_OS_XXX_DIR=$FFMPEG_TMP_OS_XXX_DIR"
                log_var_split_print "FFMPEG_TMP_OS_XXX_OUTPUT_DIR=$FFMPEG_TMP_OS_XXX_OUTPUT_DIR"
                log_var_split_print "FFMPEG_TMP_OS_XXX_TMP_DIR=$FFMPEG_TMP_OS_XXX_TMP_DIR"
                log_var_split_print "FFMPEG_TMP_OS_XXX_SRC_DIR=$FFMPEG_TMP_OS_XXX_SRC_DIR"

                log_var_split_print "FFMPEG_XXX_NAME=$FFMPEG_XXX_NAME"
                log_var_split_print "FFMPEG_XXX_VERSION=$FFMPEG_XXX_VERSION"
                log_var_split_print "FFMPEG_XXX_URL=$FFMPEG_XXX_URL"

                for ((j = 0; j < ${#FFMPEG_ALL_ARCH_ON_ANDROID[@]}; j++)); do

                    FFMPEG_CURRENT_ARCH=${FFMPEG_ALL_ARCH_ON_ANDROID[j]}
                    FFMPEG_LOG="${FFMPEG_TMP_OS_LOG_DIR}/${FFMPEG_CURRENT_TARGET_OS}_${FFMPEG_ALL_BUILD_LIBRARY[k]}_${FFMPEG_CURRENT_ARCH}.log"

                    ffmpeg_output_log_control

                    log_var_split_print "FFMPEG_CURRENT_ARCH=${FFMPEG_CURRENT_ARCH}"
                    log_var_split_print "FFMPEG_LOG=$FFMPEG_LOG"

                    mkdir -p "${FFMPEG_TMP_OS_XXX_TMP_DIR}/${FFMPEG_CURRENT_ARCH}"
                    mkdir -p "${FFMPEG_TMP_OS_XXX_OUTPUT_DIR}/${FFMPEG_CURRENT_ARCH}"

                    ffmpeg_build_Android ${FFMPEG_CURRENT_TARGET_OS} ${FFMPEG_CURRENT_ARCH} ${FFMPEG_ALL_BUILD_LIBRARY[k]}

                done

                log_info_print "ffmpeg_build_android_library ${FFMPEG_ALL_BUILD_LIBRARY[k]} end..."
            done

            log_info_print "ffmpeg_build_android_all_library end..."
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
