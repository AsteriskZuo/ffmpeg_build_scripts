#!/bin/sh

source ../color_log.sh

echo "###############################################################################" >/dev/null
echo "# Script Summary:                                                             #" >/dev/null
echo "# Author:                  yu.zuo                                             #" >/dev/null
echo "# Create Date:             2020.03.30                                         #" >/dev/null
echo "# Update Date:             2020.03.31                                         #" >/dev/null
echo "# Script version:          1.0.0                                              #" >/dev/null
echo "# Url: https://github.com/AsteriskZuo/ffmpeg_build_scripts                    #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Brief introduction:                                                         #" >/dev/null
echo "# This script implements test case.                                           #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Prerequisites:                                                              #" >/dev/null
echo "# GNU bash (version 3.2.57 test success on macOS)                             #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Reference:                                                                  #" >/dev/null
echo "# Url: https://blog.csdn.net/Jerry_1126/article/details/80628359              #" >/dev/null
echo "# Url: https://blog.csdn.net/neo949332116/article/details/100181500           #" >/dev/null
echo "# Url: https://blog.csdn.net/taiyang1987912/article/details/39551385          #" >/dev/null
echo "# Url: https://www.cnblogs.com/hurryup/articles/10241601.html                 #" >/dev/null
echo "# Url: https://cloud.tencent.com/developer/ask/59944                          #" >/dev/null
echo "# Url: https://www.cnblogs.com/lmx1002/p/10132656.html                        #" >/dev/null
echo "# Url: https://blog.csdn.net/panfengzjz/article/details/81865925              #" >/dev/null
echo "# Url: http://www.voidcn.com/article/p-qpmevtxb-btr.html                      #" >/dev/null
echo "# Url: https://cloud.tencent.com/developer/ask/151529                         #" >/dev/null
echo "###############################################################################" >/dev/null

echo "###############################################################################" >/dev/null
echo "#### Function test partition                                              #####" >/dev/null
echo "###############################################################################" >/dev/null

function log_test2() {
    log_basic_print ${LOG_VAR_BG_GREEN} ${LOG_VAR_FG_RED} ${LOG_VAR_BLINK} "log test content"
    log_basic_print ${LOG_VAR_BG_BLACK} ${LOG_VAR_FG_RED} ${LOG_VAR_BLINK} "log test content"
    log_debug_print "debug: log test content"
    log_info_print "info: log test content"
    log_warning_print "warning: log test content"
    log_error_print "error: log test content"
    log_fatal_print "fatal: log test content"
    log_print "common: log test content"

    echo "standalone syntax:" "\\033[${LOG_VAR_BG_GREEN}m\\033[${LOG_VAR_FG_RED}m\\033[7m \"log test content\"\\033[0m"
    echo ";;; syntax:" "\\033[${LOG_VAR_BG_GREEN};${LOG_VAR_FG_RED};7m \"log test content\"\\033[0m"
    echo "1m:" "\\033[${LOG_VAR_FG_RED};1m \"log test content\"\\033[0m"
    echo "4m:" "\\033[${LOG_VAR_FG_RED};4m \"log test content\"\\033[0m"
    echo "5m:" "\\033[${LOG_VAR_FG_RED};5m \"log test content\"\\033[0m"
    echo "7m:" "\\033[${LOG_VAR_FG_RED};7m \"log test content\"\\033[0m"
    echo "8m:" "\\033[${LOG_VAR_FG_RED};8m \"log test content\"\\033[0m"
    echo "foreground:" "\\033[${LOG_VAR_FG_RED}m \"log test content\"\\033[0m"
    echo "background:" "\\033[${LOG_VAR_BG_GREEN}m \"log test content\"\\033[0m"
    echo "foreground:background" "\\033[${LOG_VAR_BG_GREEN};${LOG_VAR_FG_RED}m \"log test content\"\\033[0m"
    echo "foreground:background:1m" "\\033[${LOG_VAR_BG_GREEN};${LOG_VAR_FG_RED};1m \"log test content\"\\033[0m"
    echo "foreground:background:4m" "\\033[${LOG_VAR_BG_GREEN};${LOG_VAR_FG_RED};4m \"log test content\"\\033[0m"
    echo "foreground:background:5m" "\\033[${LOG_VAR_BG_GREEN};${LOG_VAR_FG_RED};5m \"log test content\"\\033[0m"
    echo "foreground:background:7m" "\\033[${LOG_VAR_BG_GREEN};${LOG_VAR_FG_RED};7m \"log test content\"\\033[0m"
    echo "foreground:background:8m" "\\033[${LOG_VAR_BG_GREEN};${LOG_VAR_FG_RED};8m \"log test content\"\\033[0m"
}

function log_test() {
    local x=100
    ptrx=x
    eval $ptrx=50
    echo $x

    y=100
    ptry=$y
    eval $ptry=50
    echo $y

    a=100
    ptra=a
    $ptra=50
    echo $a

    b=100
    ptrb=b
    $ptrb=50
    echo $b

    eval $ptrc=50
    echo $ptrc
}

function log_test_sed() {
    params=("1 2 3" "4 5")
    echo ${#params[@]}
    echo ${params[@]}

    params=($(echo "1234=567 90" | sed "s/=/&\ /g"))
    echo ${#params[@]}
    echo ${params[@]}

    params2=($(echo "1234=567 90" | sed "s/^.*\\=//g"))
    echo ${#params2[@]}
    echo ${params2[@]}
    echo ${params2[0]}
    echo ${params2[1]}

    params3=($(echo "1234=567 90" | sed "s/\\=.*$//g"))
    echo ${#params3[@]}
    echo ${params3[@]}
    echo ${params3[0]}
    echo ${params3[1]}

    params4=($(echo "src|tmp|tool" | sed "s/|/ /g"))
    echo ${#params4[@]}
    echo ${params4[@]}
    echo ${params4[0]}
    echo ${params4[1]}
    echo ${params4[2]}
}

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

function ffmpeg_test_join() {
    echo join "1" "2"
    echo join "1""2"
    a="123"
    b="456"
    c="789"
    echo join $a $b
    echo join $a $b $c
}

function ffmpeg_test_return_string() {
    return $1
}
function ffmpeg_test_invoke_return_string() {
    # 测试函数返回字符串，实际上函数不支持返回字符串
    # 仅返回错误码0-255
    ffmpeg_return_string 1
    # ret1=$()
    echo "ret1=$ret1"
    ret2=$?
    echo "ret2=$ret2"
    ret3=$(ffmpeg_return_string 244)
    echo "ret3=$ret3"
    ret4=$?
    echo "ret4=$ret4"
    ret5=$(ffmpeg_return_string 1000)
    echo "ret5=$ret5"
    ret6=$?
    echo "ret6=$ret6"
    ret7=$(ffmpeg_return_string "hello world")
    echo "ret7=$ret7"
    ret8=$?
    echo "ret8=$ret8"
}

function ffmpeg_test_set() {
    local value=$1
    eval $value="enable"
}
function ffmpeg_test_invoke_set() {
    sdlk="all"
    ffmpeg_test_set sdlk
    echo $sdlk
}

function ffmpeg_test_set2() {
    local key=$1
    local value=$2
    eval $key='$value'
}
function ffmpeg_test_invoke_set2() {
    # 使用eval达到修改变量值的方法
    var_key="123"
    var_value="456"
    ffmpeg_test_set2 var_key $var_value
    echo "var_key=$var_key"
}

function ffmpeg_test_fun_name() {
    echo "$1"
}
function ffmpeg_test_invoke_fun_name() {
    # 使用变量保存函数名称
    local ffmpeg_test_fun_name "11111"
    local fun_name_1="ffmpeg_test"
    local fun_name_2="_"
    local fun_name_3="fun_name"
    local fun_name=$(echo "${fun_name_1}${fun_name_2}${fun_name_3}")
    echo "fun_name=$fun_name"
    $fun_name "22222"
}

function ffmpeg_test_import_script() {
    # 使用变量作为脚本文件名称
    local fun_name_1="obj2"
    local fun_name_2=".sh"
    local fun_name=$(echo ${fun_name_1}${fun_name_2})
    source ./test_shell.sh
    source $fun_name || echo "not found sh file" && exit 1
}

function ffmpeg_test_export_var() {
    export test_var="haha"
    # echo "test_var=$test_var"
    export test_var_2="haha"
    # echo "test_var_2=$test_var_2"
    test_var_4="haha"
    # echo "test_var_4=$test_var_4"
}
function ffmpeg_test_invoke_export_var() {
    # 全局变量
    # test_var="ioio"
    # echo "test_var=$test_var"

    # # 本地变量
    # local test_var_2="ioio"
    # echo "test_var_2=$test_var_2"

    # # 改变变量
    # ffmpeg_test_export_var

    # # 结果
    # echo "test_var=$test_var"
    # echo "test_var_2=$test_var_2"

    # 外部脚本可以改变当前脚本变量
    export test_var_3="haha"
    echo "test_var_3=$test_var_3"
    source ./test_obj.sh
    echo "test_var_3=$test_var_3"

    # 导出的变量，被改变后，在使用时候不需要使用export关键字
    # export test_var_4="ioio"
    # echo "test_var_4=$test_var_4"
    # ffmpeg_test_export_var
    # echo "test_var_4=$test_var_4"
}

function ffmpeg_is_in() {
    local value=$1
    shift
    for var in $@; do
        [ $var = $value ] && return 0
    done
    return 1
}
function ffmpeg_test_is_in() {
    # 指定变量值是否在数组里面
    local num_set=(1 2 3 4 5)
    local num="1"
    if ffmpeg_is_in ${num} ${num_set[@]}; then
        echo "ifs"
    else
        echo "else"
    fi
    local num="17"
    if ffmpeg_is_in ${num} ${num_set[@]}; then
        echo "ifs"
    else
        echo "else"
    fi
}

function ffmpeg_is_enable() {
    # error
    # if [ "yes" = $1 ]; then
    #     return 1
    # else
    #     return 0
    # fi

    # error
    # [ "yes" = $1 ] && return 1
    # return 0

    # ok
    [ "yes" = $1 ]
}
function ffmpeg_test_is_enable() {
    # 使用函数返回值作为if控制的判断条件
    echo "1:"
    if ((1)); then
        echo "if1"
    else
        echo "else"
    fi

    echo "2:"
    if ((0)); then
        echo "if0"
    else
        echo "else"
    fi

    echo "3:"
    local var1="yes"
    if ffmpeg_is_enable ${var1}; then
        echo "if"
    else
        echo "else"
    fi

    echo "4:"
    if (($(ffmpeg_is_enable ${var1}))); then
        echo "if"
    else
        echo "else"
    fi

    echo "5:"
    local var2="no"
    if ffmpeg_is_enable ${var2}; then
        echo "if"
    else
        echo "else"
    fi

}

function ffmpeg_test_dir_is_exist() {
    [ -d "$1" ]
}
function ffmpeg_test_invoke_dir_is_exist() {
    if ffmpeg_test_dir_is_exist "test_dir"; then
        echo "exist"
    else
        echo "not exist"
    fi
    if ffmpeg_test_dir_is_exist "asdf"; then
        echo "exist"
    else
        echo "not exist"
    fi
}

function ffmpeg_test_logic() {
    # ok
    ffmpeg_test_dir_is_exist "asdf" || echo "fail" && exit 1
}
function ffmpeg_test_logic2() {
    # 遇到错误之后无法正常退出
    ffmpeg_test_dir_is_exist "asdf" || (echo "fail" && exit 1)
}

function ffmpeg_test_get_var_var_value() {
    # 获取变量的变量的值
    color_name="red"
    red=31
    color=$(eval echo '$'"${color_name}")
    echo ${color}

    local name_1="r"
    local name_2="e"
    local name_3="d"
    color2=$(eval echo '$'"${name_1}${name_2}${name_3}")
    echo ${color2}

    local FFMPEG_EXTERNAL_LIBRARY_aom="aom"
    local FFMPEG_EXTERNAL_LIBRARY_aom_version="1.0.0"
    ssss="FFMPEG_EXTERNAL_LIBRARY_${FFMPEG_EXTERNAL_LIBRARY_aom}_version"
    eeee=$(eval echo '$'"${ssss}")
    echo ${eeee}
    ffff=$(eval echo '$'"${ssss}")
    echo ${ffff}
    gggg=$(eval echo '$'${ssss})
    echo ${gggg}
}

function test_transfer_parameters() {
    echo $@
}
function test_invoke_transfer_parameters() {
    # 字符串参数包含连续多个空格 ?
    test_transfer_parameters [["hello   world"]]
    test_transfer_parameters 'hello   world'
}

function test_var_var() {
    local var_1="haha"
    var_var_1=$var_1
    echo $var_var_1
    var_var_1=var_1
    echo $var_var_1
}
# set -v
# set -x
# ls -la

# 显示执行命令所在行的行号
# set -x
# PS4=':${LINENO}+'
# ls -la
# ls -la



read -n1 -p "any key...."
