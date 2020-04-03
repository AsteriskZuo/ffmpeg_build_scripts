#!/bin/sh

source ../color_log.sh

echo "###############################################################################" >/dev/null
echo "# Script Summary:                                                             #" >/dev/null
echo "# Author:                  xxx                                                #" >/dev/null
echo "# Create Date:             xxxx.xx.xx                                         #" >/dev/null
echo "# Update Date:             xxxx.xx.xx                                         #" >/dev/null
echo "# Script version:          x.x.x                                              #" >/dev/null
echo "# Url: http://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Brief introduction:                                                         #" >/dev/null
echo "# xxxxxx.                                                                     #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Prerequisites:                                                              #" >/dev/null
echo "# xxxxxx.                                                                     #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Reference:                                                                  #" >/dev/null
echo "# xxxxxx.                                                                     #" >/dev/null
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


echo "###############################################################################" >/dev/null
echo "#### Variable declarations partition on Android                           #####" >/dev/null
echo "###############################################################################" >/dev/null

echo "###############################################################################" >/dev/null
echo "#### Function implementation partition                                    #####" >/dev/null
echo "###############################################################################" >/dev/null

log_info_print "
    
脚本模板使用说明：
	1.该脚本为子脚本，不建议单独使用；
	2.该脚本可以使用本全局变量，但是不建议修改；
	3.该脚本某些函数(方法)会被主脚本适当时机调用(后面详细介绍)；
	4.该脚本文件名字格式必须为：build_library_xxx，其中xxx为专有名词；
	5.该脚本为插件式脚本，由主脚本自动判断是否符合条件并加载和使用其中指定函数(方法)；
	6.该脚本请尽量使用本地变量（local xxx），避免与其他脚本或全局变量冲突。
	7.如果必须要使用全局变量可以以xxx开头命名变量。
    
Script template instructions:
    1. The script is a subscript, which is not recommended to be used separately;
    2. The script can use this global variable, but it is not recommended to modify it;
    3. Some of the functions (methods) of the script will be called appropriately by the main script (more on that later);
    4. The script file name format must be: build_library_xxx, where XXX is a proper noun;
    5. The script is a plug-in script, and the main script automatically determines whether it meets the conditions and loads and USES the specified functions (methods);
    6. For this script, use local XXX whenever possible to avoid conflicts with other scripts or global variables.
    7. If you must use global variables, you can name variables beginning with XXX.
"

# xxx is library name
function ffm_lib_xxx() {
    log_info_print "ffm_lib_xxx start..."
    log_debug_print "xxx is library name."
    log_warning_print "Do not change the value of a global variable, only the main script has permission to change it."
    log_info_print "ffm_lib_xxx end..."
}
function ffm_lib_clean_xxx() {
    log_info_print "ffm_lib_clean_xxx start..."
    log_debug_print "Clean up your subdirectories. Please create under the specified directory."
    log_debug_print "FFMPEG_TMP_OS_XXX_DIR is root temp directory."
    log_debug_print "FFMPEG_SRC_XXX_DIR is src directory."
    log_info_print "ffm_lib_clean_xxx end..."
}
function ffm_lib_mkdir_xxx() {
    log_info_print "ffm_lib_mkdir_xxx start..."
    log_debug_print "Create your own subdirectory."
    log_info_print "ffm_lib_mkdir_xxx end..."
}
function ffm_lib_prerequisites_xxx() {
    # 库的预处理部分：包括：安装依赖环境、下载源码等操作。
    log_info_print "ffm_lib_prerequisites_xxx start..."
    log_debug_print "Prepare the prerequisites for the library. Include: install dependencies, download source code and so on."
    log_debug_print "All required dependencies are placed in the main script."
    log_info_print "ffm_lib_prerequisites_xxx end..."
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
