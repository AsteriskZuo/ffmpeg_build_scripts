#!/bin/sh

# source ../color_log.sh
source ./ffmpeg_global_variable.sh

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
echo "# Build ffmpeg library                                                        #" >/dev/null
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

echo "###############################################################################" >/dev/null
echo "#### Variable declarations partition                                      #####" >/dev/null
echo "###############################################################################" >/dev/null

LOCAL_LIBRARY_NAME=$1

echo "###############################################################################" >/dev/null
echo "#### Variable declarations partition on Android                           #####" >/dev/null
echo "###############################################################################" >/dev/null

echo "###############################################################################" >/dev/null
echo "#### Function implementation partition                                    #####" >/dev/null
echo "###############################################################################" >/dev/null

# xxx is library name
function ffm_lib_xxx() {
    log_info_print "ffm_lib_xxx start..."
    log_debug_print "xxx is library name."
    log_info_print "ffm_lib_xxx end..."
}
function ffm_lib_clean_ffmpeg() {
    log_info_print "ffm_lib_clean_ffmpeg start..."
    if test -d $FFMPEG_TMP_OS_XXX_DIR; then
        rm -rf $FFMPEG_TMP_OS_XXX_DIR
    fi
    log_info_print "ffm_lib_clean_ffmpeg end..."
}
function ffm_lib_mkdir_ffmpeg() {
    log_info_print "ffm_lib_mkdir_ffmpeg start..."
    if test ! -d $FFMPEG_TMP_OS_XXX_DIR; then
        rm -rf $FFMPEG_TMP_OS_XXX_DIR
    fi
    log_info_print "ffm_lib_mkdir_ffmpeg end..."
}
function ffm_lib_prerequisites_ffmpeg() {
    # 库的预处理部分：包括：安装依赖环境、下载源码等操作。
    log_info_print "ffm_lib_prerequisites_ffmpeg start..."
    FFMPEG_XXX_FULL_NAME="${FFMPEG_TMP_OS_XXX_SRC_DIR}/${FFMPEG_XXX_NAME}-${FFMPEG_XXX_VERSION}"
    local 
    if [ ! -r $FFMPEG_FULL_NAME ]; then
        log_warning_print 'FFmpeg source file not found. Trying to download...'
        log_debug_print "download url: http://www.ffmpeg.org/releases/$FFMPEG_FULL_NAME.tar.bz2"
        curl ${FFMPEG_URL} >${FFMPEG_FULL_NAME}.tar.bz2 || log_error_print "ffmpeg src download fail." 
        tar -x -f ${FFMPEG_FULL_NAME}.tar.bz2 || log_error_print "ffmpeg src uncompress fail." 
    fi
    log_info_print "ffm_lib_prerequisites_ffmpeg end..."
}
function ffm_lib_build_xxx() {
    # 构建方法主要包括：1.设置环境变量、配置两边、输出目录等参数；2.执行构建；3.执行make和make install命令
    log_info_print "ffm_lib_build_xxx start..."
    log_debug_print "The construction function mainly includes: 
        1. Set environment variables, configuration variables, output directory and other parameters; 
        2. Execute configure; 
        3. Perform make and make install."
    log_info_print "ffm_lib_build_xxx end..."
}
function ffm_lib_lipo_xxx() {
    # 生成后处理事件。iOS静态库一般将多个CPU架构合并成一个静态库文件；Android一般将多个静态库合并成一个动态库。因为Android的NDK建议使用动态库。
    log_info_print "ffm_lib_build_xxx start..."
    log_debug_print "Generate post-processing events. IOS static library generally combines multiple CPU architectures into one static library file; Android typically combines multiple static libraries into one dynamic library. Because Android's NDK recommends using dynamic libraries."
    log_info_print "ffm_lib_build_xxx end..."
}

echo "###############################################################################" >/dev/null
echo "#### Process control partition                                            #####" >/dev/null
echo "###############################################################################" >/dev/null

echo "###############################################################################" >/dev/null
echo "#### Function test partition                                              #####" >/dev/null
echo "###############################################################################" >/dev/null

ffm_lib_xxx
ffm_lib_clean_xxx
ffm_lib_mkdir_xxx
ffm_lib_prerequisites_xxx
ffm_lib_build_xxx
ffm_lib_lipo_xxx

echo ""
read -n1 -p "Press any key to continue..."
