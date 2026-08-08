#!/bin/bash
# OrangeFox build configuration for Redmi Turbo 4 Pro (onyx)

# Device identification
export FDEVICE="onyx"
export FOX_VARIANT="RedmiTurbo4Pro"

# A/B device with dedicated recovery partition
export FOX_AB_DEVICE=1
export OF_AB_DEVICE_WITH_RECOVERY_PARTITION=1

# Virtual A/B device
export FOX_VIRTUAL_AB_DEVICE=1

# Dynamic partitions (super)
export OF_DYNAMIC_PARTITIONS=1
# super partition size (11 GB reported from partitions)
export OF_DYNAMIC_FULL_SIZE=11534336

# Build tools
export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER=1
export FOX_USE_TAR_BINARY=1
export FOX_USE_XZ_UTILS=1
export FOX_USE_LZ4_BINARY=1
export FOX_USE_ZSTD_BINARY=1
export FOX_USE_NANO_EDITOR=1
export FOX_USE_BASH_SHELL=1
export FOX_USE_GREP_BINARY=1

# Magisk support
export OF_USE_MAGISKBOOT=1
export OF_USE_MAGISKBOOT_FOR_ALL_PATCHES=1

# KernelSU support  
export FOX_ENABLE_KERNEL_SU=1

# Prebuilt kernel
export OF_FORCE_PREBUILT_KERNEL=1

# Display settings
export OF_SCREEN_H=2400
export OF_STATUS_H=120
export OF_STATUS_INDENT_LEFT=60
export OF_STATUS_INDENT_RIGHT=60
export OF_CLOCK_POS=1

# No flashlight / LED
export OF_USE_GREEN_LED=0
export OF_FLASHLIGHT_ENABLE=0

# Encryption
export OF_DEFAULT_KEYMASTER_VERSION=4.1
export OF_ENABLE_FBE_METADATA_ENCRYPTION=1

# Filesystem / EROFS support
export OF_SUPPORT_EROFS=1
export OF_SUPPORT_ALL_BLOCK_DEVICES=1

# MIUI specific - device is MIUI/HyperOS based
export OF_PATCH_AVB20=1

# ADB
export OF_ADVANCED_SECURITY=1

# Use LZMA compression if size is too big
# export OF_USE_LZMA_COMPRESSION=1

# Function to validate device target
fox_get_target_device() {
    local chkdev=$(echo "$BASH_SOURCE" | grep -w "$FDEVICE")
    if [ -n "$chkdev" ]; then
        export FOX_BUILD_DEVICE="$FDEVICE"
    else
        echo "WARNING: Device mismatch detected! (ignored in CI, setting FOX_BUILD_DEVICE=$FDEVICE)"
        export FOX_BUILD_DEVICE="$FDEVICE"
    fi
}

fox_get_target_device

# Additional variables for build
export ALLOW_MISSING_DEPENDENCIES=true
export LC_ALL="C"

# Register lunch combo with the build system
add_lunch_combo twrp_onyx-eng
add_lunch_combo twrp_onyx-userdebug
