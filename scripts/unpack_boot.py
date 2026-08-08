#!/usr/bin/env python3
"""Unpack Android boot image (v0-v4) to extract kernel."""

import struct
import sys
import os

def unpack_bootimg(path, out_dir):
    with open(path, 'rb') as f:
        data = f.read()

    # Parse header
    magic = data[:8]
    print(f"Magic: {magic}")

    if magic != b'ANDROID!':
        print("Not an Android boot image!")
        return

    # Version
    header_version = struct.unpack_from('<I', data, 40)[0]
    print(f"Header version: {header_version}")

    # Common fields (v0+)
    kernel_size = struct.unpack_from('<I', data, 8)[0]
    kernel_addr = struct.unpack_from('<I', data, 12)[0]
    ramdisk_size = struct.unpack_from('<I', data, 16)[0]
    ramdisk_addr = struct.unpack_from('<I', data, 20)[0]
    second_size = struct.unpack_from('<I', data, 24)[0]
    second_addr = struct.unpack_from('<I', data, 28)[0]
    tags_addr = struct.unpack_from('<I', data, 32)[0]
    page_size = struct.unpack_from('<I', data, 36)[0]

    # v1+ fields
    if header_version >= 1:
        recovery_dtbo_size = struct.unpack_from('<I', data, 1648)[0]
        recovery_dtbo_offset = struct.unpack_from('<Q', data, 1656)[0]
        header_size = struct.unpack_from('<I', data, 1664)[0]

    # v2+ fields
    if header_version >= 2:
        dtb_size = struct.unpack_from('<I', data, 1668)[0]
        dtb_addr = struct.unpack_from('<Q', data, 1672)[0]

    # v3+ fields: header_size is at a different position
    if header_version >= 3:
        hdr_size_field = struct.unpack_from('<I', data, 56)[0]
    elif header_version >= 1:
        hdr_size_field = struct.unpack_from('<I', data, 1664)[0]
    else:
        hdr_size_field = 0

    # v4 ramdisk is uint64_t
    if header_version >= 4:
        ramdisk_size = struct.unpack_from('<Q', data, 12)[0]
        print(f"  (v4 ramdisk size 64-bit)")

    print(f"Page size: {page_size}")
    print(f"Kernel size: {kernel_size} ({kernel_size // 1024} KB)")
    print(f"Ramdisk size: {ramdisk_size} ({ramdisk_size // 1024} KB)")
    print(f"DTB size: {dtb_size if header_version >= 2 else 'N/A'}")
    print(f"Header size field: {hdr_size_field}")

    os.makedirs(out_dir, exist_ok=True)

    if header_version >= 3:
        # v3/v4: no page alignment, content starts at header_size
        kernel_offset = hdr_size_field
        ramdisk_offset = kernel_offset + kernel_size
        second_offset = 0
        dtb_offset = 0
    elif header_version == 0:
        # v0: page aligned
        n = (kernel_size + page_size - 1) // page_size
        m = (ramdisk_size + page_size - 1) // page_size
        o = (second_size + page_size - 1) // page_size

        kernel_offset = page_size
        ramdisk_offset = (1 + n) * page_size
        second_offset = (1 + n + m) * page_size
        tags_offset = (1 + n + m + o) * page_size

        dtb_offset = 0
    else:
        # v1/v2: page aligned with header_size
        if header_version == 1:
            hdr_sz = hdr_size_field or 1648
        elif header_version == 2:
            hdr_sz = hdr_size_field or 1668
        else:
            hdr_sz = hdr_size_field

        kernel_offset = ((hdr_sz + page_size - 1) // page_size) * page_size
        ramdisk_offset = kernel_offset + ((kernel_size + page_size - 1) // page_size) * page_size
        second_offset = ramdisk_offset + ((ramdisk_size + page_size - 1) // page_size) * page_size
        tags_offset = second_offset + ((second_size + page_size - 1) // page_size) * page_size

        if header_version >= 2:
            dtb_offset = second_offset + ((second_size + page_size - 1) // page_size) * page_size
        else:
            dtb_offset = 0

    # Extract kernel
    if kernel_size > 0:
        kernel_path = os.path.join(out_dir, 'kernel')
        with open(kernel_path, 'wb') as f:
            f.write(data[kernel_offset:kernel_offset + kernel_size])
        print(f"Extracted kernel to: {kernel_path}")

    # Extract ramdisk
    if ramdisk_size > 0:
        ramdisk_path = os.path.join(out_dir, 'ramdisk.cpio.gz')
        with open(ramdisk_path, 'wb') as f:
            f.write(data[ramdisk_offset:ramdisk_offset + ramdisk_size])
        print(f"Extracted ramdisk to: {ramdisk_path}")

    # Extract DTB (v2+)
    if header_version >= 2 and dtb_size > 0:
        dtb_path = os.path.join(out_dir, 'dtb.img')
        with open(dtb_path, 'wb') as f:
            f.write(data[dtb_offset:dtb_offset + dtb_size])
        print(f"Extracted DTB to: {dtb_path}")

    # Extract recovery DTBO (v1+)
    if header_version >= 1 and recovery_dtbo_size > 0:
        dtbo_path = os.path.join(out_dir, 'recovery_dtbo.img')
        with open(dtbo_path, 'wb') as f:
            f.write(data[recovery_dtbo_offset:recovery_dtbo_offset + recovery_dtbo_size])
        print(f"Extracted recovery DTBO to: {dtbo_path}")

    # Save cmdline if available
    if header_version >= 2:
        cmdline = data[64:64+512].split(b'\x00')[0].decode('utf-8', errors='replace')
        if cmdline:
            with open(os.path.join(out_dir, 'cmdline.txt'), 'w') as f:
                f.write(cmdline)
            print(f"Cmdline: {cmdline[:80]}...")

    print("\nDone!")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python unpack_boot.py <boot.img> [output_dir]")
        sys.exit(1)

    boot_path = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else 'boot_extracted'
    unpack_bootimg(boot_path, out)
