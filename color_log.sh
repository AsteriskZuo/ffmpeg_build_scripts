#!/bin/sh
echo "###############################################################################" >/dev/null
echo "# Script Summary:                                                             #" >/dev/null
echo "# Author:                  yu.zuo                                             #" >/dev/null
echo "# Update Date:             2020.03.30                                         #" >/dev/null
echo "# Script version:          1.0.0                                              #" >/dev/null
echo "# Url: https://github.com/AsteriskZuo/ffmpeg_build_scripts                    #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Brief introduction:                                                         #" >/dev/null
echo "# This script implements output color log.                                    #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Prerequisites:                                                              #" >/dev/null
echo "# GNU bash (version 3.2.57 test success on macOS)                             #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Reference:                                                                  #" >/dev/null
echo "# Url: https://blog.csdn.net/kx_nullpointer/article/details/38585963          #" >/dev/null
echo "# Url: https://www.centos.bz/2013/07/linux-shell-c-show-color-word/           #" >/dev/null
echo "###############################################################################" >/dev/null

echo "# 基本语法介绍:
# 符号含义:
# \\033[0m 关闭所有属性
# \\033[1m 设置高亮度
# \\033[4m 下划线
# \\033[5m 闪烁
# \\033[7m 反显
# \\033[8m 消隐
# \\033[30m 至 \\33[37m 设置前景色
# \\033[40m 至 \\33[47m 设置背景色
# \\033[nA 光标上移n行
# \\033[nB 光标下移n行
# \\033[nC 光标右移n行
# \\033[nD 光标左移n行
# \\033[y;xH设置光标位置
# \\033[2J 清屏
# \\033[K 清除从光标到行尾的内容
# \\033[s 保存光标位置
# \\033[u 恢复光标位置
# \\033[?25l 隐藏光标
# \\033[?25h 显示光标
# 字体颜色:30 - 39
# 30:黑
# 31:红
# 32:绿
# 33:黄
# 34:蓝色
# 35:紫色
# 36:深绿
# 37:白色 
# 字体背景颜色:40 — 49
# 40:黑
# 41:深红
# 42:绿
# 43:黄色
# 44:蓝色
# 45:紫色
# 46:深绿
# 47:白色
" >/dev/null

echo "###############################################################################" >/dev/null
echo "#### Variable declarations partition                                      #####" >/dev/null
echo "###############################################################################" >/dev/null

LOG_VAR_BOLD="1"
LOG_VAR_UNDERLINE="4"
LOG_VAR_BLINK="5"
LOG_VAR_CONVERT="7"
LOG_VAR_HIDE="8"

#foreground color
LOG_VAR_FG_GREY="30"
LOG_VAR_FG_RED="31"
LOG_VAR_FG_GREEN="32"
LOG_VAR_FG_YELLOW="33"
LOG_VAR_FG_BLUE="34"
LOG_VAR_FG_VIOLET="35"
LOG_VAR_FG_SKY_BLUE="36"
LOG_VAR_FG_WHITE="37"

#background color
LOG_VAR_BG_BLACK="40"
LOG_VAR_BG_RED="41"
LOG_VAR_BG_GREEN="42"
LOG_VAR_BG_YELLOW="43"
LOG_VAR_BG_BLUE="44"
LOG_VAR_BG_VIOLET="45"
LOG_VAR_BG_SKYBLUE="46"
LOG_VAR_BG_WHITE="47"

echo "###############################################################################" >/dev/null
echo "#### Function implementation partition                                    #####" >/dev/null
echo "###############################################################################" >/dev/null

function log_basic_print() {
    # background: ${1}
    # foreground: ${2}
    # sytle: ${3}
    # log content: ${4}
    echo "\\033[${1};${2};${3}m${@:4}\\033[0m"
}
function log_basic_print_without_bg() {
    # foreground: ${1}
    # sytle: ${2}
    # log content: ${3}
    echo "\\033[${1};${2}m${@:3}\\033[0m"
}
function log_debug_print() {
    # high | blue
    log_basic_print_without_bg ${LOG_VAR_FG_BLUE} ${LOG_VAR_BLINK} $@
}
function log_info_print() {
    # high | green
    log_basic_print_without_bg ${LOG_VAR_FG_GREEN} ${LOG_VAR_BLINK} $@
}
function log_warning_print() {
    # high | bold | yellow
    log_basic_print_without_bg ${LOG_VAR_FG_YELLOW} ${LOG_VAR_BOLD} $@
}
function log_error_print() {
    # high | bold | red
    log_basic_print_without_bg ${LOG_VAR_FG_RED} ${LOG_VAR_BOLD} $@
}
function log_fatal_print() {
    # high | bold | red | blink
    log_basic_print ${LOG_VAR_BG_GREEN} ${LOG_VAR_FG_RED} ${LOG_VAR_BOLD} $@
}
function log_print() {
    # log content: ${1}
    echo $@
}

echo "###############################################################################" >/dev/null
echo "#### Function test partition                                              #####" >/dev/null
echo "###############################################################################" >/dev/null

# log_basic_print ${LOG_VAR_BG_GREEN} ${LOG_VAR_FG_RED} ${LOG_VAR_BLINK} "log test content"
# log_basic_print ${LOG_VAR_BG_BLACK} ${LOG_VAR_FG_RED} ${LOG_VAR_BLINK} "log test content"
# log_debug_print "debug: log test content"
# log_info_print "info: log test content"
# log_warning_print "warning: log test content"
# log_error_print "error: log test content"
# log_fatal_print "fatal: log test content"
# log_print "common: log test content"

# echo "standalone syntax:" "\\033[${LOG_VAR_BG_GREEN}m\\033[${LOG_VAR_FG_RED}m\\033[7m \"log test content\"\\033[0m"
# echo ";;; syntax:" "\\033[${LOG_VAR_BG_GREEN};${LOG_VAR_FG_RED};7m \"log test content\"\\033[0m"
# echo "1m:" "\\033[${LOG_VAR_FG_RED};1m \"log test content\"\\033[0m"
# echo "4m:" "\\033[${LOG_VAR_FG_RED};4m \"log test content\"\\033[0m"
# echo "5m:" "\\033[${LOG_VAR_FG_RED};5m \"log test content\"\\033[0m"
# echo "7m:" "\\033[${LOG_VAR_FG_RED};7m \"log test content\"\\033[0m"
# echo "8m:" "\\033[${LOG_VAR_FG_RED};8m \"log test content\"\\033[0m"
# echo "foreground:" "\\033[${LOG_VAR_FG_RED}m \"log test content\"\\033[0m"
# echo "background:" "\\033[${LOG_VAR_BG_GREEN}m \"log test content\"\\033[0m"
# echo "foreground:background" "\\033[${LOG_VAR_BG_GREEN};${LOG_VAR_FG_RED}m \"log test content\"\\033[0m"
# echo "foreground:background:1m" "\\033[${LOG_VAR_BG_GREEN};${LOG_VAR_FG_RED};1m \"log test content\"\\033[0m"
# echo "foreground:background:4m" "\\033[${LOG_VAR_BG_GREEN};${LOG_VAR_FG_RED};4m \"log test content\"\\033[0m"
# echo "foreground:background:5m" "\\033[${LOG_VAR_BG_GREEN};${LOG_VAR_FG_RED};5m \"log test content\"\\033[0m"
# echo "foreground:background:7m" "\\033[${LOG_VAR_BG_GREEN};${LOG_VAR_FG_RED};7m \"log test content\"\\033[0m"
# echo "foreground:background:8m" "\\033[${LOG_VAR_BG_GREEN};${LOG_VAR_FG_RED};8m \"log test content\"\\033[0m"

log_info_print "import color log function..."
# read -n1 -p "Press any key to continue..."