#!/bin/sh

source ./color_log.sh

echo "###############################################################################" >/dev/null
echo "#### Function test partition                                              #####" >/dev/null
echo "###############################################################################" >/dev/null

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

function ffmpeg_return_string() {
    return $1
}
# echo ${ffmpeg_return_string 1}
# $(ffmpeg_return_string 1) | echo $?
# $(ffmpeg_return_string 12) | echo $?
# ffmpeg_return_string 100 | echo $?
# ffmpeg_return_string 1000
# ffmpeg_return_string "hello"

FFMPEG_ENABLE_SET=("enable" "disable")
function ffmpeg_is_enable() {
    local value=$1
    # echo "value=$value"
    if [ "yes" = $value ]; then
    # echo 1
        return 1
    else
    # echo 0
        return 0
    fi
}

function ffmpeg_test_set() {
    local value=$1
    eval $value="enable"
}
# sdlk="all"
# ffmpeg_test_set sdlk
# echo $sdlk

function ffmpeg_test_set2() {
    local key=$1
    local value=$2
    eval $key='$value'
}
var_key="123"
var_value="456"
ffmpeg_test_set2 var_key $var_value
echo "var_key=$var_key"