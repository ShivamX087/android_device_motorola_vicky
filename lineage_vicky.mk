#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from device makefile.
$(call inherit-product, device/motorola/vicky/device.mk)

# Inherit some common LineageOS stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_NAME := lineage_vicky
PRODUCT_DEVICE := vicky
PRODUCT_MANUFACTURER := motorola
PRODUCT_BRAND := motorola
PRODUCT_MODEL := moto G72

PRODUCT_GMS_CLIENTID_BASE := android-motorola

PRODUCT_SYSTEM_NAME := vicky
PRODUCT_SYSTEM_DEVICE := vicky

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="vicky_g_sys-user 13 T2SVS33M.68-21-8-14 d6e5ed release-keys" \
    BuildFingerprint=motorola/vicky_g_sys/vicky:13/T2SVS33M.68-21-8-14/d6e5ed:user/release-keys \
    SystemModel=$(PRODUCT_SYSTEM_DEVICE) \
    SystemName=$(PRODUCT_SYSTEM_NAME) \
    ProductModel=$(PRODUCT_SYSTEM_DEVICE) \
    DeviceProduct=$(PRODUCT_SYSTEM_NAME)
