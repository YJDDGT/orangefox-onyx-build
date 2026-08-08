# BoardConfig.mk for Redmi Turbo 4 Pro (onyx)
# SOC: Qualcomm SM8735 (Snapdragon 8s Gen 3)

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := kryo

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_VARIANT := kryo

# Bootloader
TARGET_NO_BOOTLOADER := true
TARGET_BOOTLOADER_BOARD_NAME := onyx
TARGET_BOARD_PLATFORM := xiaomi_sm8735
TARGET_BOARD_PLATFORM_GPU := qcom-adreno
TARGET_USES_64_BIT_BINDER := true

# Use mke2fs for ext4 (instead of make_ext4fs which is deprecated)
TARGET_USES_MKE2FS := true

# Kernel
BOARD_KERNEL_CMDLINE := console=ttynull cgroup_disable=pressure kasan.stacktrace=off kvm-arm.mode=protected kpti=0 swiotlb=0 loop.max_part=7 pcie_ports=compat irqaffinity=0-1 kasan=off rcupdate.rcu_expedited=1 rcu_nocbs=0-7 kernel.panic_on_rcu_stall=1 fw_devlink.strict=1 cgroup.memory=nokmem,nosocket pci-msm-drv.pcie_sm_regs=0x1D07000,0x1040,0x1048,0x3000,0x1 video=vfb:640x400,bpp=32,memsize=3072000 erofs.reserved_pages=64 printk.always_kmsg_dump=1 cpufreq.default_governor=performance
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x01000000
BOARD_TAGS_OFFSET := 0x00000100
BOARD_KERNEL_SECOND_OFFSET := 0x00000000
BOARD_DTB_OFFSET := 0x01f00000
BOARD_BOOT_HEADER_VERSION := 4
BOARD_HEADER_SIZE := 4096
BOARD_MKBOOTIMG_ARGS := --header_version $(BOARD_BOOT_HEADER_VERSION)

# Prebuilt kernel
TARGET_PREBUILT_KERNEL := device/xiaomi/onyx/prebuilt/kernel
BOARD_PREBUILT_DTBOIMAGE := device/xiaomi/onyx/prebuilt/dtbo.img

# Partitions (A/B)
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    init_boot \
    system \
    system_ext \
    system_dlkm \
    product \
    vendor \
    vendor_boot \
    vendor_dlkm \
    vbmeta \
    vbmeta_system

# Recovery partition (dedicated, not recovery-as-boot)
BOARD_USES_RECOVERY_AS_BOOT := false
BOARD_HAS_NO_REAL_SDCARD := true
RECOVERY_SDCARD_ON_DATA := true

# Dynamic partitions
BOARD_SUPER_PARTITION_SIZE := 11811160064
BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 11799151104
BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    system \
    system_ext \
    system_dlkm \
    product \
    vendor \
    vendor_dlkm \
    odm

# F2FS / EROFS
TARGET_USERIMAGES_USE_F2FS := true
TARGET_USERIMAGES_USE_EXT4 := true
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs

# Encryption
BOARD_USES_QCOM_FBE_DECRYPTION := true
BOARD_USES_METADATA_PARTITION := true
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_INCLUDE_FBE_METADATA_DECRYPT := true
TW_USE_FSCRYPT_POLICY := 2

# TWRP / OrangeFox flags
TW_THEME := portrait_hdpi
TW_NO_SCREEN_BLANK := true
TW_SCREEN_BLANK_ON_BOOT := true
TW_BRIGHTNESS_PATH := "/sys/class/backlight/panel0-backlight/brightness"
TW_MAX_BRIGHTNESS := 4096
TW_DEFAULT_BRIGHTNESS := 1024
TW_FRAMERATE := 60
TW_EXCLUDE_DEFAULT_USB_INIT := true
TW_EXCLUDE_APEX := true
TW_INCLUDE_FASTBOOTD := true
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_REPACK_TOOLS := true
TW_INCLUDE_LPDUMP := true
TW_INCLUDE_LPTOOLS := true
TW_HAS_NO_RECOVERY_PARTITION := false

# Use toybox
TW_USE_TOOLBOX := true

# Don't include super_empty.img
BOARD_BUILD_SUPER_IMAGE_BY_DEFAULT := false

# Debug
TARGET_USES_LOGD := true
TWRP_INCLUDE_LOGCAT := true
TW_EXCLUDE_TWRPAPP := true

# SEPolicy
BOARD_SEPOLICY_DIRS := device/xiaomi/onyx/sepolicy
