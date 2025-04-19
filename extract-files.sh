#!/bin/bash
#
# SPDX-FileCopyrightText: 2016 The CyanogenMod Project
# SPDX-FileCopyrightText: 2017-2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=vicky
VENDOR=motorola

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

export TARGET_ENABLE_CHECKELF=true

export PATCHELF_VERSION=0_17_2

# If XML files don't have comments before the XML header, use this flag
# Can still be used with broken XML files by using blob_fixup
export TARGET_DISABLE_XML_FIXING=true

export TARGET_ENABLE_CHECKELF=true

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        --only-firmware)
            ONLY_FIRMWARE=true
            ;;
        -n | --no-cleanup)
            CLEAN_VENDOR=false
            ;;
        -k | --kang)
            KANG="--kang"
            ;;
        -s | --section)
            SECTION="${2}"
            shift
            CLEAN_VENDOR=false
            ;;
        *)
            SRC="${1}"
            ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup {
    case "$1" in
        system_ext/lib64/libsink.so)
           [ "$2" = "" ] && return 0
           "${PATCHELF}" --add-needed "libaudioclient_shim.so" "$2"
            ;;
        vendor/bin/hw/android.hardware.gnss-service.mediatek |\
        vendor/lib64/hw/android.hardware.gnss-impl-mediatek.so)
            [ "$2" = "" ] && return 0
            "$PATCHELF" --replace-needed "android.hardware.gnss-V1-ndk_platform.so" "android.hardware.gnss-V1-ndk.so" "$2"
            ;;
        vendor/etc/init/android.hardware.neuralnetworks-shim-service-mtk.rc)
            [ "$2" = "" ] && return 0
            sed -i 's/start/enable/' "$2"
	          ;;
        vendor/lib*/hw/mt6789/vendor.mediatek.hardware.pq@2.15-impl.so|\
        vendor/bin/hw/vendor.mediatek.hardware.pq@2.2-service)
	    [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v32.so" "${2}"
            "${PATCHELF}" --replace-needed "libbinder.so" "libbinder-v32.so" "${2}"
            "${PATCHELF}" --replace-needed "libhidlbase.so" "libhidlbase-v32.so" "${2}"
            ;;
	vendor/bin/hw/vendor.mediatek.hardware.mtkpower@1.0-service)
	    [ "$2" = "" ] && return 0
            "$PATCHELF" --replace-needed "android.hardware.power-V2-ndk_platform.so" "android.hardware.power-V2-ndk.so" "$2"
            ;;
        vendor/etc/init/vendor.mediatek.hardware.mtkpower@1.0-service.rc)
            [ "$2" = "" ] && return 0
            echo "$(cat ${2}) input" > "${2}"
            ;;
        vendor/lib*/hw/android.hardware.thermal@2.0-impl.so)
	    [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v32.so" "${2}"
            ;;
        vendor/bin/hw/android.hardware.security.keymint-service.trustonic)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "android.hardware.security.keymint-V1-ndk_platform.so" "android.hardware.security.keymint-V1-ndk.so" "${2}"
            "${PATCHELF}" --replace-needed "android.hardware.security.secureclock-V1-ndk_platform.so" "android.hardware.security.secureclock-V1-ndk.so" "${2}"
            "${PATCHELF}" --replace-needed "android.hardware.security.sharedsecret-V1-ndk_platform.so" "android.hardware.security.sharedsecret-V1-ndk.so" "${2}"
            grep -q "android.hardware.security.rkp-V3-ndk.so" "${2}" || ${PATCHELF} --add-needed "android.hardware.security.rkp-V3-ndk.so" "${2}"
            ;;
        *)
            return 1
            ;;
    esac

    return 0
}

function blob_fixup_dry() {
    blob_fixup "${1}" ""
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
