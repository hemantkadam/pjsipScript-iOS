#!/bin/bash
#@author Hemant Kadam

./build-libssl.sh

svn checkout http://svn.pjsip.org/repos/pjproject/trunk

BASE_FOLDER="$(pwd)/trunk"
BASE_FOLDER_SSL="$(pwd)/bin"
BASE_FOLDER_SSL_LIB="$(pwd)/lib"

PJLIB_PATH="${BASE_FOLDER}/pjlib"
PJLIB_UTIL_PATH="${BASE_FOLDER}/pjlib-util"
PJMEDIA_PATH="${BASE_FOLDER}/pjmedia"
PJNATH_PATH="${BASE_FOLDER}/pjnath"
PJSIP_PATH="${BASE_FOLDER}/pjsip"
PJ_THIRD_PARTY_PATH="${BASE_FOLDER}/third_party"

TARGET_HEADER_PATHS=("${PJLIB_PATH}" "${PJLIB_UTIL_PATH}" "${PJMEDIA_PATH}" "${PJNATH_PATH}" "${PJSIP_PATH}")

PJSIP_ALL_LIB_PATH="${BASE_FOLDER}/lib"
PJSIP_ALL_HEADER_PATH="${BASE_FOLDER}/pjsip-include/"

#Create config_site.h file for iOS build configuration
CONFIG_SITE_PATH="${BASE_FOLDER}/pjlib/include/pj/config_site.h"

echo "Creating config site file for iOS ..."
cat <<EOF > "$CONFIG_SITE_PATH"
#define PJ_CONFIG_IPHONE 1
#define PJ_HAS_SSL_SOCK 1

#include <pj/config_site_sample.h>
EOF


#Target architectures that you want to build
#Build "arm64" "armv7" "armv7s" for device
#Build "i386" "x86_64" for simulator

TARGET_ARCHS_DEVICE=("arm64" "armv7" "armv7s")
TARGET_ARCHS_SIMULATOR=("i386" "x86_64")

for arch in "${TARGET_ARCHS_DEVICE[@]}"
do
echo "Compile for device arch $arch ..."
export MIN_IOS="-miphoneos-version-min=8.0"

cd "${BASE_FOLDER}"
OPENSSL_PATH="${BASE_FOLDER_SSL}/iPhoneOS10.2-${arch}.sdk/"

ARCH="-arch ${arch}" ./configure-iphone --with-ssl="${OPENSSL_PATH}" && make dep && make clean && make
done

#Set DEVPATH depending on latest iOS sdk. Note: this can vary from SDK to SDK
#Do replace this with proper path
export DEVPATH=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer
for arch in "${TARGET_ARCHS_SIMULATOR[@]}"
do
echo "Compile for Simulator arch $arch ..."
cd "${BASE_FOLDER}"
OPENSSL_PATH="${BASE_FOLDER_SSL}/iPhoneSimulator10.2-${arch}.sdk/"

ARCH="-arch ${arch}" CFLAGS="-O2 -m32 -mios-simulator-version-min=8.0" LDFLAGS="-O2 -m32 -mios-simulator-version-min=8.0" ./configure-iphone --with-ssl="${OPENSSL_PATH}" && make dep && make clean && make

done

echo "unset DEVPATH"
unset DEVPATH

#Make directory for all pjsip headers
rm -rf "${PJSIP_ALL_HEADER_PATH}"
mkdir -p "${PJSIP_ALL_HEADER_PATH}"

#Copy all header files under single folder
for path in "${TARGET_HEADER_PATHS[@]}"
do
echo "Coping header files from $path to $PJSIP_ALL_HEADER_PATH"
cp -r "${path}/include/" "${PJSIP_ALL_HEADER_PATH}"
done

echo "Binding all different arch lib into single lib using -lipo ..."
lipo -arch arm64 "${PJLIB_PATH}"/lib/libpj-arm64-apple-darwin_ios.a -arch armv7s "${PJLIB_PATH}"/lib/libpj-armv7s-apple-darwin_ios.a -arch armv7 "${PJLIB_PATH}"/lib/libpj-armv7-apple-darwin_ios.a -arch i386 "${PJLIB_PATH}"/lib/libpj-i386-apple-darwin_ios.a -arch x86_64 "${PJLIB_PATH}"/lib/libpj-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libpj-arm-apple-darwin_ios.a

lipo -arch arm64 "${PJLIB_UTIL_PATH}"/lib/libpjlib-util-arm64-apple-darwin_ios.a -arch armv7 "${PJLIB_UTIL_PATH}"/lib/libpjlib-util-armv7-apple-darwin_ios.a -arch armv7s "${PJLIB_UTIL_PATH}"/lib/libpjlib-util-armv7s-apple-darwin_ios.a -arch i386 "${PJLIB_UTIL_PATH}"/lib/libpjlib-util-i386-apple-darwin_ios.a -arch x86_64 "${PJLIB_UTIL_PATH}"/lib/libpjlib-util-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libpjlib-util-arm-apple-darwin_ios.a

lipo -arch arm64 "${PJMEDIA_PATH}"/lib/libpjmedia-arm64-apple-darwin_ios.a -arch armv7 "${PJMEDIA_PATH}"/lib/libpjmedia-armv7-apple-darwin_ios.a -arch armv7s "${PJMEDIA_PATH}"/lib/libpjmedia-armv7s-apple-darwin_ios.a -arch i386 "${PJMEDIA_PATH}"/lib/libpjmedia-i386-apple-darwin_ios.a -arch x86_64 "${PJMEDIA_PATH}"/lib/libpjmedia-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libpjmedia-arm-apple-darwin_ios.a

lipo -arch arm64 "${PJMEDIA_PATH}"/lib/libpjmedia-audiodev-arm64-apple-darwin_ios.a -arch armv7 "${PJMEDIA_PATH}"/lib/libpjmedia-audiodev-armv7-apple-darwin_ios.a -arch armv7s "${PJMEDIA_PATH}"/lib/libpjmedia-audiodev-armv7s-apple-darwin_ios.a -arch i386 "${PJMEDIA_PATH}"/lib/libpjmedia-audiodev-i386-apple-darwin_ios.a -arch x86_64 "${PJMEDIA_PATH}"/lib/libpjmedia-audiodev-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libpjmedia-audiodev-arm-apple-darwin_ios.a

lipo -arch arm64 "${PJMEDIA_PATH}"/lib/libpjmedia-codec-arm64-apple-darwin_ios.a -arch armv7 "${PJMEDIA_PATH}"/lib/libpjmedia-codec-armv7-apple-darwin_ios.a -arch armv7s "${PJMEDIA_PATH}"/lib/libpjmedia-codec-armv7s-apple-darwin_ios.a -arch i386 "${PJMEDIA_PATH}"/lib/libpjmedia-codec-i386-apple-darwin_ios.a -arch x86_64 "${PJMEDIA_PATH}"/lib/libpjmedia-codec-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libpjmedia-codec-arm-apple-darwin_ios.a

lipo -arch arm64 "${PJMEDIA_PATH}"/lib/libpjmedia-videodev-arm64-apple-darwin_ios.a -arch armv7 "${PJMEDIA_PATH}"/lib/libpjmedia-videodev-armv7-apple-darwin_ios.a -arch armv7s "${PJMEDIA_PATH}"/lib/libpjmedia-videodev-armv7s-apple-darwin_ios.a -arch i386 "${PJMEDIA_PATH}"/lib/libpjmedia-videodev-i386-apple-darwin_ios.a -arch x86_64 "${PJMEDIA_PATH}"/lib/libpjmedia-videodev-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libpjmedia-videodev-arm-apple-darwin_ios.a

lipo -arch arm64 "${PJMEDIA_PATH}"/lib/libpjsdp-arm64-apple-darwin_ios.a -arch armv7 "${PJMEDIA_PATH}"/lib/libpjsdp-armv7-apple-darwin_ios.a -arch armv7s "${PJMEDIA_PATH}"/lib/libpjsdp-armv7s-apple-darwin_ios.a -arch i386 "${PJMEDIA_PATH}"/lib/libpjsdp-i386-apple-darwin_ios.a -arch x86_64 "${PJMEDIA_PATH}"/lib/libpjsdp-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libpjsdp-arm-apple-darwin_ios.a

lipo -arch arm64 "${PJNATH_PATH}"/lib/libpjnath-arm64-apple-darwin_ios.a -arch armv7 "${PJNATH_PATH}"/lib/libpjnath-armv7-apple-darwin_ios.a -arch armv7s "${PJNATH_PATH}"/lib/libpjnath-armv7s-apple-darwin_ios.a -arch i386 "${PJNATH_PATH}"/lib/libpjnath-i386-apple-darwin_ios.a -arch x86_64 "${PJNATH_PATH}"/lib/libpjnath-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libpjnath-arm-apple-darwin_ios.a

lipo -arch arm64 "${PJSIP_PATH}"/lib/libpjsip-arm64-apple-darwin_ios.a -arch armv7 "${PJSIP_PATH}"/lib/libpjsip-armv7-apple-darwin_ios.a -arch armv7s "${PJSIP_PATH}"/lib/libpjsip-armv7s-apple-darwin_ios.a -arch i386 "${PJSIP_PATH}"/lib/libpjsip-i386-apple-darwin_ios.a -arch x86_64 "${PJSIP_PATH}"/lib/libpjsip-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libpjsip-arm-apple-darwin_ios.a

lipo -arch arm64 "${PJSIP_PATH}"/lib/libpjsip-simple-arm64-apple-darwin_ios.a -arch armv7 "${PJSIP_PATH}"/lib/libpjsip-simple-armv7-apple-darwin_ios.a -arch armv7s "${PJSIP_PATH}"/lib/libpjsip-simple-armv7s-apple-darwin_ios.a -arch i386 "${PJSIP_PATH}"/lib/libpjsip-simple-i386-apple-darwin_ios.a -arch x86_64 "${PJSIP_PATH}"/lib/libpjsip-simple-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libpjsip-simple-arm-apple-darwin_ios.a

lipo -arch arm64 "${PJSIP_PATH}"/lib/libpjsip-ua-arm64-apple-darwin_ios.a -arch armv7 "${PJSIP_PATH}"/lib/libpjsip-ua-armv7-apple-darwin_ios.a -arch armv7s "${PJSIP_PATH}"/lib/libpjsip-ua-armv7s-apple-darwin_ios.a -arch i386 "${PJSIP_PATH}"/lib/libpjsip-ua-i386-apple-darwin_ios.a -arch x86_64 "${PJSIP_PATH}"/lib/libpjsip-ua-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libpjsip-ua-arm-apple-darwin_ios.a

lipo -arch arm64 "${PJSIP_PATH}"/lib/libpjsua-arm64-apple-darwin_ios.a -arch armv7 "${PJSIP_PATH}"/lib/libpjsua-armv7-apple-darwin_ios.a -arch armv7s "${PJSIP_PATH}"/lib/libpjsua-armv7s-apple-darwin_ios.a -arch i386 "${PJSIP_PATH}"/lib/libpjsua-i386-apple-darwin_ios.a -arch x86_64 "${PJSIP_PATH}"/lib/libpjsua-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libpjsua-arm-apple-darwin_ios.a

lipo -arch arm64 "${PJSIP_PATH}"/lib/libpjsua2-arm64-apple-darwin_ios.a -arch armv7 "${PJSIP_PATH}"/lib/libpjsua2-armv7-apple-darwin_ios.a -arch armv7s "${PJSIP_PATH}"/lib/libpjsua2-armv7s-apple-darwin_ios.a -arch i386 "${PJSIP_PATH}"/lib/libpjsua2-i386-apple-darwin_ios.a -arch x86_64 "${PJSIP_PATH}"/lib/libpjsua2-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libpjsua2-arm-apple-darwin_ios.a

lipo -arch arm64 "${PJ_THIRD_PARTY_PATH}"/lib/libg7221codec-arm64-apple-darwin_ios.a -arch armv7 "${PJ_THIRD_PARTY_PATH}"/lib/libg7221codec-armv7-apple-darwin_ios.a -arch armv7s "${PJ_THIRD_PARTY_PATH}"/lib/libg7221codec-armv7s-apple-darwin_ios.a -arch i386 "${PJ_THIRD_PARTY_PATH}"/lib/libg7221codec-i386-apple-darwin_ios.a -arch x86_64 "${PJ_THIRD_PARTY_PATH}"/lib/libg7221codec-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libg7221codec-arm-apple-darwin_ios.a

lipo -arch arm64 "${PJ_THIRD_PARTY_PATH}"/lib/libgsmcodec-arm64-apple-darwin_ios.a -arch armv7 "${PJ_THIRD_PARTY_PATH}"/lib/libgsmcodec-armv7-apple-darwin_ios.a -arch armv7s "${PJ_THIRD_PARTY_PATH}"/lib/libgsmcodec-armv7s-apple-darwin_ios.a -arch i386 "${PJ_THIRD_PARTY_PATH}"/lib/libgsmcodec-i386-apple-darwin_ios.a -arch x86_64 "${PJ_THIRD_PARTY_PATH}"/lib/libgsmcodec-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libgsmcodec-arm-apple-darwin_ios.a

lipo -arch arm64 "${PJ_THIRD_PARTY_PATH}"/lib/libilbccodec-arm64-apple-darwin_ios.a -arch armv7 "${PJ_THIRD_PARTY_PATH}"/lib/libilbccodec-armv7-apple-darwin_ios.a -arch armv7s "${PJ_THIRD_PARTY_PATH}"/lib/libilbccodec-armv7s-apple-darwin_ios.a -arch i386 "${PJ_THIRD_PARTY_PATH}"/lib/libilbccodec-i386-apple-darwin_ios.a -arch x86_64 "${PJ_THIRD_PARTY_PATH}"/lib/libilbccodec-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libilbccodec-arm-apple-darwin_ios.a

lipo -arch arm64 "${PJ_THIRD_PARTY_PATH}"/lib/libresample-arm64-apple-darwin_ios.a -arch armv7 "${PJ_THIRD_PARTY_PATH}"/lib/libresample-armv7-apple-darwin_ios.a -arch armv7s "${PJ_THIRD_PARTY_PATH}"/lib/libresample-armv7s-apple-darwin_ios.a -arch i386 "${PJ_THIRD_PARTY_PATH}"/lib/libresample-i386-apple-darwin_ios.a -arch x86_64 "${PJ_THIRD_PARTY_PATH}"/lib/libresample-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libresample-arm-apple-darwin_ios.a

lipo -arch arm64 "${PJ_THIRD_PARTY_PATH}"/lib/libspeex-arm64-apple-darwin_ios.a -arch armv7 "${PJ_THIRD_PARTY_PATH}"/lib/libspeex-armv7-apple-darwin_ios.a -arch armv7s "${PJ_THIRD_PARTY_PATH}"/lib/libspeex-armv7s-apple-darwin_ios.a -arch i386 "${PJ_THIRD_PARTY_PATH}"/lib/libspeex-i386-apple-darwin_ios.a -arch x86_64 "${PJ_THIRD_PARTY_PATH}"/lib/libspeex-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libspeex-arm-apple-darwin_ios.a

lipo -arch arm64 "${PJ_THIRD_PARTY_PATH}"/lib/libsrtp-arm64-apple-darwin_ios.a -arch armv7 "${PJ_THIRD_PARTY_PATH}"/lib/libsrtp-armv7-apple-darwin_ios.a -arch armv7s "${PJ_THIRD_PARTY_PATH}"/lib/libsrtp-armv7s-apple-darwin_ios.a -arch i386 "${PJ_THIRD_PARTY_PATH}"/lib/libsrtp-i386-apple-darwin_ios.a -arch x86_64 "${PJ_THIRD_PARTY_PATH}"/lib/libsrtp-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libsrtp-arm-apple-darwin_ios.a

lipo -arch arm64 "${PJ_THIRD_PARTY_PATH}"/lib/libwebrtc-arm64-apple-darwin_ios.a -arch armv7 "${PJ_THIRD_PARTY_PATH}"/lib/libwebrtc-armv7-apple-darwin_ios.a -arch armv7s "${PJ_THIRD_PARTY_PATH}"/lib/libwebrtc-armv7s-apple-darwin_ios.a -arch i386 "${PJ_THIRD_PARTY_PATH}"/lib/libwebrtc-i386-apple-darwin_ios.a -arch x86_64 "${PJ_THIRD_PARTY_PATH}"/lib/libwebrtc-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libwebrtc-arm-apple-darwin_ios.a

lipo -arch arm64 "${PJ_THIRD_PARTY_PATH}"/lib/libyuv-arm64-apple-darwin_ios.a -arch armv7 "${PJ_THIRD_PARTY_PATH}"/lib/libyuv-armv7-apple-darwin_ios.a -arch armv7s "${PJ_THIRD_PARTY_PATH}"/lib/libyuv-armv7s-apple-darwin_ios.a -arch i386 "${PJ_THIRD_PARTY_PATH}"/lib/libyuv-i386-apple-darwin_ios.a -arch x86_64 "${PJ_THIRD_PARTY_PATH}"/lib/libyuv-x86_64-apple-darwin_ios.a -create -output "${PJSIP_ALL_LIB_PATH}"/libyuv-arm-apple-darwin_ios.a


cp -r "${BASE_FOLDER_SSL_LIB}/libcrypto.a" "${PJSIP_ALL_LIB_PATH}"
cp -r "${BASE_FOLDER_SSL_LIB}/libssl.a" "${PJSIP_ALL_LIB_PATH}"
