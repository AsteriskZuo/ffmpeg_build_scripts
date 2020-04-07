#!/bin/sh

source ./color_log.sh

echo "###############################################################################" >/dev/null
echo "# Script Summary:                                                             #" >/dev/null
echo "# Author:                  yu.zuo                                             #" >/dev/null
echo "# Create Date:             2020.03.31                                         #" >/dev/null
echo "# Update Date:             2020.03.31                                         #" >/dev/null
echo "# Script version:          1.0.0                                              #" >/dev/null
echo "# Url: https://github.com/AsteriskZuo/ffmpeg_build_scripts                    #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Brief introduction:                                                         #" >/dev/null
echo "# Declare global variables                                                    #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Prerequisites:                                                              #" >/dev/null
echo "# GNU bash (version 3.2.57 test success on macOS)                             #" >/dev/null
echo "#                                                                             #" >/dev/null
echo "# Reference:                                                                  #" >/dev/null
echo "# none.                                                                       #" >/dev/null
echo "###############################################################################" >/dev/null

echo "###############################################################################" >/dev/null
echo "#### Help instruction partition                                           #####" >/dev/null
echo "###############################################################################" >/dev/null

# Boolean conditional judgment
export FFMPEG_BOOL_SET=("yes" "no")

# Enable or disable
export FFMPEG_ENABLE_SET=("enable" "disable")

# work thread count
export FFMPEG_WORK_THREAD_COUNT_SET=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16)

echo "###############################################################################" >/dev/null
echo "#### Debug setting partition                                              #####" >/dev/null
echo "###############################################################################" >/dev/null

export FFMPEG_ENABLE_LOG_FILE="yes"

echo "###############################################################################" >/dev/null
echo "#### Variable declarations partition                                      #####" >/dev/null
echo "###############################################################################" >/dev/null

# all build target system platform name
export FFMPEG_ALL_TARGET_OS=("iOS" "Android")

# "armv7" "arm64" "i386" "x86_64"
# warning: "i386" is not test
export FFMPEG_ALL_ARCH_ON_IOS=("armv7" "arm64" "x86_64")

# "armeabi" "armeabi-v7a" "arm64-v8a" "x86" "x86_64"
# error: "x86" can not compile success, detail "src/libswscale/x86/rgb2rgb_template.c:1666:13: error: inline assembly requires more registers than available"
# warning: "armeabi" is not test
export FFMPEG_ALL_ARCH_ON_ANDROID=("armeabi-v7a" "arm64-v8a" "x86_64")

# "yes" "no"
# If yes, some libraries might be activated, but if no, they must all be inactive.
export FFMPEG_ENABLE_ALL_EXTERNAL_LIBRARY="no"

# work thread count for make commandline
export FFMPEG_WORK_THREAD_COUNT="4"

# "src" "tmp" "tool"
export FFMPEG_ALL_CLEAN_TYPE_PREDEFINE=("src" "tmp" "tool")
export FFMPEG_ALL_CLEAN_TYPE=()

# enable ffmpeg external library
export FFMPEG_ENABLE_EXTERNAL_LIBRARY="yes"

export FFMPEG_NAME="ffmpeg"
export FFMPEG_VERSION="4.2.2"
export FFMPEG_FULL_NAME=${FFMPEG_NAME}-${FFMPEG_VERSION}
export FFMPEG_URL="http://www.ffmpeg.org/releases/${FFMPEG_NAME}-${FFMPEG_VERSION}.tar.bz2"
export FFMPEG_XXX_NAME=$FFMPEG_NAME
export FFMPEG_XXX_VERSION=$FFMPEG_VERSION
export FFMPEG_XXX_FULL_NAME=$FFMPEG_FULL_NAME
export FFMPEG_XXX_URL=$FFMPEG_URL

export FFMPEG_ROOT_DIR=$(pwd)
export FFMPEG_SH_SUB_DIR="${FFMPEG_ROOT_DIR}/ffmpeg_script"
export FFMPEG_SRC_DIR="${FFMPEG_ROOT_DIR}/ffmpeg_src"
export FFMPEG_TMP_DIR="${FFMPEG_ROOT_DIR}/ffmpeg_tmp"
export FFMPEG_TOOL_DIR="${FFMPEG_ROOT_DIR}/ffmpeg_tool"
export FFMPEG_TEST_DIR="${FFMPEG_ROOT_DIR}/ffmpeg_test"
export FFMPEG_OUTPUT_DIR="${FFMPEG_ROOT_DIR}/ffmpeg_output"

export FFMPEG_CURRENT_DIR=""

export FFMPEG_TMP_OS_LIPO_DIR=""
export FFMPEG_TMP_OS_LOG_DIR=""
export FFMPEG_TMP_OS_XXX_DIR=""
export FFMPEG_TMP_OS_XXX_TMP_DIR=""
export FFMPEG_TMP_OS_XXX_OUTPUT_DIR=""
export FFMPEG_TMP_OS_XXX_SRC_DIR=""
export FFMPEG_TMP_OS_XXX_INCLUDE_DIR=""

export FFMPEG_CURRENT_TARGET_OS=""
export FFMPEG_CURRENT_ARCH=""

export FFMPEG_LOG=""

echo "###############################################################################" >/dev/null
echo "#### Variable declarations partition on iOS                               #####" >/dev/null
echo "###############################################################################" >/dev/null

export IOS_DEPLOYMENT_MIN_TARGET="8.0"

echo "###############################################################################" >/dev/null
echo "#### Variable declarations partition on Android                           #####" >/dev/null
echo "###############################################################################" >/dev/null

export ANDROID_NDK_DIR="/Users/asteriskzuo/Library/Android/sdk/ndk-bundle"
export ANDROID_HOST_TAG="darwin-x86_64"
export ANDROID_TOOLCHAIN_DIR="$ANDROID_NDK_DIR/toolchains/llvm/prebuilt/$ANDROID_HOST_TAG"
export ANDROID_MARCHS=("arm" "arm64" "x86" "x86_64")
export ANDROID_ABIS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")

# Note: For 32-bit ARM, the compiler is prefixed with armv7a-linux-androideabi, but the binutils tools are prefixed
# with arm-linux-androideabi. For other architectures, the prefixes are the same for all tools.
export ANDROID_ABI_TRIPLES=("armv7a-linux-androideabi" "aarch64-linux-android" "i686-linux-android" "x86_64-linux-android")

# <=19 use standalone toolchain which need manual compile by make_standalone_toolchain.py
# >19 use prebuilt toolchain from ndk-bundle
# >=21 support 64 bit arm
# >=23 support neon which supports ARM Advanced SIMD, commonly known as Neon, an optional instruction set extension for ARMv7 and ARMv8.
# Android 2.1(7) 5.0(21) 6.0(23) 10.0(29)
# suggest: use version 23 or later
# suggest: use Android prebuilt version toolchain
export ANDROID_API=23
export ANDROID_MIN_API=7
export ANDROID_MAX_API=29
export ANDROID_ENABLE_STANDALONE_TOOLCHAIN="no"

export ANDROID_CURRENT_MARCH=""
export ANDROID_CURRENT_ABI=""
export ANDROID_CURRENT_TRIPLE=""
export ANDROID_CURRENT_TOOLCHAIN_DIR=""

echo "###############################################################################" >/dev/null
echo "#### external library partition                                           #####" >/dev/null
echo "###############################################################################" >/dev/null

export FFMPEG_ALL_BUILD_LIBRARY=()

# Codec library for encoding and decoding AV1 video streams
# url: https://aomedia.googlesource.com/aom
# advise: yes
export FFMPEG_EXTERNAL_LIBRARY_aom="aom"
export FFMPEG_EXTERNAL_LIBRARY_aom_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_aom_version="1.0.0"
export FFMPEG_EXTERNAL_LIBRARY_aom_url="http://xxx.com/${FFMPEG_EXTERNAL_LIBRARY_aom}-${FFMPEG_EXTERNAL_LIBRARY_aom_version}.zip"

# Minimalistic plugin API for video effects
# url: https://frei0r.dyne.org/
export FFMPEG_EXTERNAL_LIBRARY_frei0r="frei0r"
export FFMPEG_EXTERNAL_LIBRARY_frei0r_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_frei0r_version="1.7.0"
export FFMPEG_EXTERNAL_LIBRARY_frei0r_url=""

# High quality MPEG Audio Layer III (MP3) encoder
# url: https://lame.sourceforge.io/
# advise: yes
export FFMPEG_EXTERNAL_LIBRARY_lame="lame"
export FFMPEG_EXTERNAL_LIBRARY_lame_enable="yes"
export FFMPEG_EXTERNAL_LIBRARY_lame_version="3.100"
export FFMPEG_EXTERNAL_LIBRARY_lame_url="https://jaist.dl.sourceforge.net/project/lame/lame/${FFMPEG_EXTERNAL_LIBRARY_lame}/${FFMPEG_EXTERNAL_LIBRARY_lame}-${FFMPEG_EXTERNAL_LIBRARY_lame_version}.tar.gz"

# Subtitle renderer for the ASS/SSA subtitle format
# url: https://github.com/libass/libass
export FFMPEG_EXTERNAL_LIBRARY_libass="libass"
export FFMPEG_EXTERNAL_LIBRARY_libass_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_libass_version="0.14.0"
export FFMPEG_EXTERNAL_LIBRARY_libass_url=""

# Blu-Ray disc playback library for media players like VLC
# url: https://www.videolan.org/developers/libbluray.html
# advise: yes
export FFMPEG_EXTERNAL_LIBRARY_libbluray="libbluray"
export FFMPEG_EXTERNAL_LIBRARY_libbluray_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_libbluray_version="1.1.2"
export FFMPEG_EXTERNAL_LIBRARY_libbluray_url=""

# High quality, one-dimensional sample-rate conversion library
# url: https://sourceforge.net/projects/soxr/
# advise: yes
export FFMPEG_EXTERNAL_LIBRARY_libsoxr="libsoxr"
export FFMPEG_EXTERNAL_LIBRARY_libsoxr_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_libsoxr_version="0.1.3"
export FFMPEG_EXTERNAL_LIBRARY_libsoxr_url=""

# Transcode video stabilization plugin
# url: http://public.hronopik.de/vid.stab/
# advise: yes
export FFMPEG_EXTERNAL_LIBRARY_libvidstab="libvidstab"
export FFMPEG_EXTERNAL_LIBRARY_libvidstab_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_libvidstab_version="1.1.0"
export FFMPEG_EXTERNAL_LIBRARY_libvidstab_url=""

# Vorbis General Audio Compression Codec
# url: https://xiph.org/vorbis/
# advise: yes
export FFMPEG_EXTERNAL_LIBRARY_libvorbis="libvorbis"
export FFMPEG_EXTERNAL_LIBRARY_libvorbis_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_libvorbis_version="1.3.6"
export FFMPEG_EXTERNAL_LIBRARY_libvorbis_url=""

# VP8/VP9 video codec
# https://www.webmproject.org/code/
export FFMPEG_EXTERNAL_LIBRARY_libvpx="libvpx"
export FFMPEG_EXTERNAL_LIBRARY_libvpx_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_libvpx_version="1.8.2"
export FFMPEG_EXTERNAL_LIBRARY_libvpx_url=""

# Audio codecs extracted from Android open source project
# url: https://opencore-amr.sourceforge.io/
# advise: yes
export FFMPEG_EXTERNAL_LIBRARY_opencore_amr="opencore_amr"
export FFMPEG_EXTERNAL_LIBRARY_opencore_amr_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_opencore_amr_version="0.1.5"
export FFMPEG_EXTERNAL_LIBRARY_opencore_amr_url=""

# Library for JPEG-2000 image manipulation
# url: https://www.openjpeg.org/
# advise: yes
export FFMPEG_EXTERNAL_LIBRARY_openjpeg="openjpeg"
export FFMPEG_EXTERNAL_LIBRARY_openjpeg_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_openjpeg_version="2.3.1"
export FFMPEG_EXTERNAL_LIBRARY_openjpeg_url=""

# Audio codec
# https://www.opus-codec.org/
# advise: yes
export FFMPEG_EXTERNAL_LIBRARY_opus="opus"
export FFMPEG_EXTERNAL_LIBRARY_opus_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_opus_version="1.3.1"
export FFMPEG_EXTERNAL_LIBRARY_opus_url=""

# Tool for downloading RTMP streaming media
# https://rtmpdump.mplayerhq.hu/
export FFMPEG_EXTERNAL_LIBRARY_rtmpdump="rtmpdump"
export FFMPEG_EXTERNAL_LIBRARY_rtmpdump_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_rtmpdump_version="2.4"
export FFMPEG_EXTERNAL_LIBRARY_rtmpdump_url=""

# Audio time stretcher tool and library
# url: https://breakfastquay.com/rubberband/
export FFMPEG_EXTERNAL_LIBRARY_rubberband="rubberband"
export FFMPEG_EXTERNAL_LIBRARY_rubberband_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_rubberband_version="1.8.2"
export FFMPEG_EXTERNAL_LIBRARY_rubberband_url=""

# Low-level access to audio, keyboard, mouse, joystick, and graphics
# url: https://www.libsdl.org/
export FFMPEG_EXTERNAL_LIBRARY_sdl2="sdl2"
export FFMPEG_EXTERNAL_LIBRARY_sdl2_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_sdl2_version="2.0.10"
export FFMPEG_EXTERNAL_LIBRARY_sdl2_url=""

# Compression/decompression library aiming for high speed
# url: https://google.github.io/snappy/
export FFMPEG_EXTERNAL_LIBRARY_snappy="snappy"
export FFMPEG_EXTERNAL_LIBRARY_snappy_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_snappy_version="1.1.8"
export FFMPEG_EXTERNAL_LIBRARY_snappy_url=""

# Audio codec designed for speech
# url: https://speex.org/
# advise: yes
export FFMPEG_EXTERNAL_LIBRARY_speex="speex"
export FFMPEG_EXTERNAL_LIBRARY_speex_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_speex_version="1.2.0"
export FFMPEG_EXTERNAL_LIBRARY_speex_url=""

# OCR (Optical Character Recognition) engine
# url: https://github.com/tesseract-ocr/
export FFMPEG_EXTERNAL_LIBRARY_tesseract="tesseract"
export FFMPEG_EXTERNAL_LIBRARY_tesseract_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_tesseract_version="4.1.1"
export FFMPEG_EXTERNAL_LIBRARY_tesseract_url=""

# Open video compression format
# url: https://www.theora.org/
# advise: yes
export FFMPEG_EXTERNAL_LIBRARY_theora="theora"
export FFMPEG_EXTERNAL_LIBRARY_theora_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_theora_version="1.1.1"
export FFMPEG_EXTERNAL_LIBRARY_theora_url=""

# Image format providing lossless and lossy compression for web images
# https://developers.google.com/speed/webp/
# advise: yes
export FFMPEG_EXTERNAL_LIBRARY_webp="webp"
export FFMPEG_EXTERNAL_LIBRARY_webp_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_webp_version="1.1.0"
export FFMPEG_EXTERNAL_LIBRARY_webp_url=""

# H.264/AVC encoder
# https://www.videolan.org/developers/x264.html
# advise: yes
export FFMPEG_EXTERNAL_LIBRARY_X264="x264"
export FFMPEG_EXTERNAL_LIBRARY_X264_enable="yes"
export FFMPEG_EXTERNAL_LIBRARY_x264_version="1771b556"
export FFMPEG_EXTERNAL_LIBRARY_x264_url="https://code.videolan.org/videolan/x264.git"

# H.265/HEVC encoder
# https://bitbucket.org/multicoreware/x265
# advise: yes
export FFMPEG_EXTERNAL_LIBRARY_x265="x265"
export FFMPEG_EXTERNAL_LIBRARY_x265_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_x265_version="3.3"
export FFMPEG_EXTERNAL_LIBRARY_x265_url=""

# High-performance, high-quality MPEG-4 video library
# url: https://labs.xvid.com/
# advise: yes
export FFMPEG_EXTERNAL_LIBRARY_xvid="xvid"
export FFMPEG_EXTERNAL_LIBRARY_xvid_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_xvid_version="1.3.7"
export FFMPEG_EXTERNAL_LIBRARY_xvid_url=""

# General-purpose data compression with high compression ratio
# url: https://tukaani.org/xz/
# advise: yes
export FFMPEG_EXTERNAL_LIBRARY_xz="xz"
export FFMPEG_EXTERNAL_LIBRARY_xz_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_xz_version="5.2.4"
export FFMPEG_EXTERNAL_LIBRARY_xz_url=""

# Cryptography and SSL/TLS Toolkit
# url: https://openssl.org/
# advise: yes
export FFMPEG_EXTERNAL_LIBRARY_openssl="openssl"
export FFMPEG_EXTERNAL_LIBRARY_openssl_enable="no"
export FFMPEG_EXTERNAL_LIBRARY_openssl_version="1.1.1d"
export FFMPEG_EXTERNAL_LIBRARY_openssl_url=""

# end
