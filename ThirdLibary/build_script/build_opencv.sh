#!/bin/sh

#作者：康林
#参数:
#    $1:编译目标(android、windows_msvc、windows_mingw、unix、unix_mingw)
#    $2:源码的位置 

#运行本脚本前,先运行 build_$1_envsetup.sh 进行环境变量设置,需要先设置下面变量:
#   RABBITIM_BUILD_TARGERT   编译目标（android、windows_msvc、windows_mingw、unix、unix_mingw）
#   RABBITIM_BUILD_PREFIX=`pwd`/../${RABBITIM_BUILD_TARGERT}  #修改这里为安装前缀
#   RABBITIM_BUILD_SOURCE_CODE    #源码目录
#   RABBITIM_BUILD_CROSS_PREFIX     #交叉编译前缀
#   RABBITIM_BUILD_CROSS_SYSROOT  #交叉编译平台的 sysroot

set -e
HELP_STRING="Usage $0 PLATFORM (android|windows_msvc|windows_mingw|unix|unix_mingw) [SOURCE_CODE_ROOT_DIRECTORY]"

case $1 in
    android|windows_msvc|windows_mingw|unix|unix_mingw)
    RABBITIM_BUILD_TARGERT=$1
    ;;
    *)
    echo "${HELP_STRING}"
    exit 1
    ;;
esac

if [ -z "${RABBITIM_BUILD_PREFIX}" ]; then
    echo ". `pwd`/build_${RABBITIM_BUILD_TARGERT}_envsetup.sh"
    . `pwd`/build_${RABBITIM_BUILD_TARGERT}_envsetup.sh
fi

if [ -n "$2" ]; then
    RABBITIM_BUILD_SOURCE_CODE=$2
else
    RABBITIM_BUILD_SOURCE_CODE=${RABBITIM_BUILD_PREFIX}/../src/opencv
fi

CUR_DIR=`pwd`
cd ${RABBITIM_BUILD_SOURCE_CODE}

#下载源码:
if [ ! -d ${RABBITIM_BUILD_SOURCE_CODE} ]; then
    OPENCV_VERSION=2.4.11
    if [ -n "$RABBITIM_USE_REPOSITORIES" ]; then
        echo "git clone git://github.com/Itseez/opencv.git  ${RABBITIM_BUILD_SOURCE_CODE}"
        git clone --branch=${OPENCV_VERSION} git://github.com/Itseez/opencv.git ${RABBITIM_BUILD_SOURCE_CODE}
    else
        echo "wget https://github.com/Itseez/opencv/archive/${OPENCV_VERSION}.zip"
        cd ${RABBITIM_BUILD_SOURCE_CODE}
        wget https://github.com/Itseez/opencv/archive/${OPENCV_VERSION}.zip
        unzip ${OPENCV_VERSION}.zip
        mv -f opencv-${OPENCV_VERSION} ${RABBITIM_BUILD_SOURCE_CODE}
    fi
fi

cd ${RABBITIM_BUILD_SOURCE_CODE}

mkdir -p build_${RABBITIM_BUILD_TARGERT}
cd build_${RABBITIM_BUILD_TARGERT}
rm -fr *

echo ""
echo "RABBITIM_BUILD_TARGERT:${RABBITIM_BUILD_TARGERT}"
echo "RABBITIM_BUILD_SOURCE_CODE:$RABBITIM_BUILD_SOURCE_CODE"
echo "CUR_DIR:`pwd`"
echo "RABBITIM_BUILD_PREFIX:$RABBITIM_BUILD_PREFIX"
echo "RABBITIM_BUILD_HOST:$RABBITIM_BUILD_HOST"
echo "RABBITIM_BUILD_CROSS_HOST:$RABBITIM_BUILD_CROSS_HOST"
echo "RABBITIM_BUILD_CROSS_PREFIX:$RABBITIM_BUILD_CROSS_PREFIX"
echo "RABBITIM_BUILD_CROSS_SYSROOT:$RABBITIM_BUILD_CROSS_SYSROOT"
echo ""

#需要设置 CMAKE_MAKE_PROGRAM 为 make 程序路径。
case `uname -s` in
    MINGW* | CYGWIN*)
        GENERATORS="MSYS Makefiles"
        ;;
    Linux* | Unix* | *)
        GENERATORS="Unix Makefiles" 
        ;;
esac

CMAKE_PARA="-DBUILD_SHARED_LIBS=ON"
case ${RABBITIM_BUILD_TARGERT} in
    android)
        CMAKE_PARA="-DBUILD_SHARED_LIBS=OFF -DCMAKE_TOOLCHAIN_FILE=${RABBITIM_BUILD_SOURCE_CODE}/platforms/android/android.toolchain.cmake"
        CMAKE_PARA="${CMAKE_PARA} -DANDROID_NATIVE_API_LEVEL=android-${RABBITIM_BUILD_PLATFORMS_VERSION} "

        if [ -n "$RABBITIM_CMAKE_MAKE_PROGRAM" ]; then
            CMAKE_PARA="${CMAKE_PARA} -DCMAKE_MAKE_PROGRAM=$RABBITIM_CMAKE_MAKE_PROGRAM" 
        fi
        ;;
    unix)
        CMAKE_PARA="-DWITH_LIBV4L=ON -DWITH_V4L=ON"
        ;;
    windows_msvc)
        ;;
    windows_mingw)
        ;;
	unix_mingw)
		CMAKE_PARA="${CMAKE_PARA} -DCMAKE_TOOLCHAIN_FILE=$RABBITIM_BUILD_PREFIX/../../cmake/platforms/toolchain-mingw-linux.cmake"
		;;
    *)
    echo "${HELP_STRING}"
    return 2
    ;;
esac

CMAKE_PARA="${CMAKE_PARA} -DBUILD_DOCS=OFF -DBUILD_opencv_apps=OFF -DBUILD_EXAMPLES=OFF -DBUILD_ANDROID_EXAMPLES=OFF"
CMAKE_PARA="${CMAKE_PARA} -DBUILD_TESTS=OFF -DBUILD_FAT_JAVA_LIB=OFF -DBUILD_JASPER=OFF -DBUILD_JPEG=OFF"
CMAKE_PARA="${CMAKE_PARA} -DBUILD_OPENEXR=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_PACKAGE=OFF -DBUILD_PNG=OFF"
CMAKE_PARA="${CMAKE_PARA} -DBUILD_TBB=OFF -DBUILD_TIFF=OFF -DBUILD_WITH_DEBUG_INFO=OFF -DWITH_OPENCL=OFF "
CMAKE_PARA="${CMAKE_PARA} -DBUILD_opencv_videostab=OFF -DBUILD_opencv_ts=OFF -DBUILD_opencv_java=OFF -DWITH_WEBP=OFF"
CMAKE_PARA="${CMAKE_PARA} -DWITH_TIFF=OFF -DWITH_JPEG=OFF -DWITH_PNG=OFF -DWITH_OPENEXR=OFF -DWITH_WIN32UI=OFF"
CMAKE_PARA="${CMAKE_PARA} -DWITH_FFMPEG=OFF -DWITH_1394=OFF -DWITH_VTK=OFF -DWITH_VFW=OFF -DWITH_IPP=OFF -DWITH_IPP_A=OFF"
CMAKE_PARA="${CMAKE_PARA} -DWITH_PVAPI=OFF -DWITH_JASPER=OFF -DWITH_OPENCLAMDFFT=OFF -DWITH_OPENCLAMDBLAS=OFF"
CMAKE_PARA="${CMAKE_PARA} -DWITH_GIGEAPI=OFF -DWITH_GSTREAMER=OFF -DWITH_GTK=OFF"
CMAKE_PARA="${CMAKE_PARA} -DBUILD_opencv_video=ON -DBUILD_opencv_videoio=ON"

cmake .. \
    -DCMAKE_INSTALL_PREFIX="$RABBITIM_BUILD_PREFIX" \
    -DCMAKE_BUILD_TYPE="Release" \
    -G"${GENERATORS}" ${CMAKE_PARA} 

cmake --build . --target install --config Release -- ${RABBITIM_MAKE_JOB_PARA}

if [ "${RABBITIM_BUILD_TARGERT}" == "android" ]; then
    if [ -d ${RABBITIM_BUILD_PREFIX}/sdk/native/jni/include ]; then
        cp -fr ${RABBITIM_BUILD_PREFIX}/sdk/native/jni/include/opencv* ${RABBITIM_BUILD_PREFIX}/include/.
    fi
    mkdir -p ${RABBITIM_BUILD_PREFIX}/lib/cmake
    cp -fr ${RABBITIM_BUILD_PREFIX}/sdk/native/jni/*.cmake ${RABBITIM_BUILD_PREFIX}/lib/cmake/.
    if [ -d ${RABBITIM_BUILD_PREFIX}/sdk/native/libs/armeabi-v7a ]; then
        cp -fr ${RABBITIM_BUILD_PREFIX}/sdk/native/libs/armeabi-v7a/* ${RABBITIM_BUILD_PREFIX}/lib/.
    fi
    if [ -d ${RABBITIM_BUILD_PREFIX}/sdk/native/3rdparty/libs/armeabi-v7a ]; then
        cp -fr ${RABBITIM_BUILD_PREFIX}/sdk/native/3rdparty/libs/armeabi-v7a/* ${RABBITIM_BUILD_PREFIX}/lib/.
    fi
    #rm -fr ${RABBITIM_BUILD_PREFIX}/sdk ${RABBITIM_BUILD_PREFIX}/apk  ${RABBITIM_BUILD_PREFIX}/LICENSE  ${RABBITIM_BUILD_PREFIX}/README.android 
else
    if [ -f ${RABBITIM_BUILD_PREFIX}/Open*.cmake ]; then
        mkdir -p ${RABBITIM_BUILD_PREFIX}/lib/cmake
        mv -f ${RABBITIM_BUILD_PREFIX}/OpenCV*.cmake ${RABBITIM_BUILD_PREFIX}/lib/cmake/.
    fi
fi

cd $CUR_DIR
