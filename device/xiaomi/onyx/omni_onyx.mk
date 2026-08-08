# Product definition for Redmi Turbo 4 Pro (onyx)
# OrangeFox Recovery

# Inherit common OrangeFox/TWRP configuration
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit Virtual A/B OTA compression
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)

# Device
PRODUCT_DEVICE := onyx
PRODUCT_NAME := twrp_onyx
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := Redmi Turbo 4 Pro
PRODUCT_MANUFACTURER := Xiaomi

# Build fingerprint
PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=fox_onyx \
    PRIVATE_BUILD_DESC="fox_onyx-eng 99.87.36 AP2A.240905.003 eng.ireddr.20260611.142332 test-keys"

BUILD_FINGERPRINT := "Xiaomi/mivendor/mivendor:15/AQ3A.250226.002/OS3.0.303.0.WOLCNXM:user/release-keys"

# Screen
TARGET_SCREEN_HEIGHT := 2400
TARGET_SCREEN_WIDTH := 1080

# Properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.adb.secure=0 \
    ro.secure=0 \
    ro.debuggable=1 \
    ro.force.debuggable=0 \
    persist.sys.usb.config=adb \
    ro.recovery.usb.vid=18D1 \
    ro.recovery.usb.adb.pid=D001 \
    ro.recovery.usb.fastboot.pid=4EE0 \
    ro.build.selinux=1 \
    persist.sys.disable_rescue=true

# Copy device-specific scripts
PRODUCT_COPY_FILES += \
    device/xiaomi/onyx/recovery/root/fstab.onyx:$(TARGET_COPY_OUT_RECOVERY)/root/fstab.onyx \
    device/xiaomi/onyx/recovery/root/init.recovery.qcom.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.qcom.rc
