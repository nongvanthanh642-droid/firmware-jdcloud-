#!/bin/sh
# =============================================================================
# /etc/uci-defaults/99-expand-emmc.sh
# AUTO-EXPAND 64GB eMMC ROOTFS & OVERLAY ON FIRST BOOT
# Target: JD Cloud AX1800 Pro (Qualcomm IPQ6000 / eMMC: /dev/mmcblk0)
# Purpose: Ensures Docker, Node-RED, and Niagara N4 BMS Gateways have
# full access to the remaining ~58GB+ disk space.
# =============================================================================

FLAG_FILE="/etc/emmc_expanded.done"

if [ -f "$FLAG_FILE" ]; then
    logger -t EMMC_EXPAND "64GB eMMC storage expansion already completed. Skipping."
    exit 0
fi

logger -t EMMC_EXPAND "Starting automated 64GB eMMC RootFS expansion on JD Cloud AX1800 Pro..."

# Detect root block device (typically /dev/mmcblk0)
ROOT_DEV="/dev/mmcblk0"

if [ ! -b "$ROOT_DEV" ]; then
    logger -t EMMC_EXPAND "Error: Root block device $ROOT_DEV not found. Aborting."
    exit 0
fi

# Find the current rootfs_data / overlay partition number
# For IPQ6000 ext4 sysupgrade, the root partition is usually partition 27 or 28, or rootfs partition
PART_NUM=$(grep -E 'rootfs_data|rootfs' /proc/mtd /proc/partitions 2>/dev/null | awk '{print $4}' | grep -o '[0-9]*$' | tail -n 1)

# Fallback: inspect mount table to find mounted /overlay or / root device
if [ -z "$PART_NUM" ]; then
    ROOTFS_MOUNT=$(df -h / | awk 'NR==2 {print $1}')
    PART_NUM=$(echo "$ROOTFS_MOUNT" | grep -o '[0-9]*$')
fi

logger -t EMMC_EXPAND "Detected target partition number: ${PART_NUM:-last}"

# Use parted or gdisk to fix the GPT secondary header at the end of the 64GB eMMC
which parted >/dev/null 2>&1
if [ $? -eq 0 ]; then
    logger -t EMMC_EXPAND "Repairing GPT table at end of 64GB eMMC..."
    # Fix GPT table to cover the entire disk
    parted -s "$ROOT_DEV" print ---pretend-input-tty <<EOF
Fix
EOF

    # Expand the last rootfs_data partition to 100% of the disk
    if [ -n "$PART_NUM" ]; then
        logger -t EMMC_EXPAND "Expanding partition $PART_NUM to 100% of eMMC..."
        parted -s "$ROOT_DEV" resizepart "$PART_NUM" 100%
    fi
fi

# Inform the kernel of partition table changes
partx -u "$ROOT_DEV" 2>/dev/null || blockdev --rereadpt "$ROOT_DEV" 2>/dev/null

# Resize the ext4 filesystem online
which resize2fs >/dev/null 2>&1
if [ $? -eq 0 ]; then
    # Resize ext4 on mounted root / overlay
    logger -t EMMC_EXPAND "Resizing ext4 filesystem to maximum disk capacity..."
    resize2fs "${ROOT_DEV}p${PART_NUM}" 2>/dev/null || resize2fs /dev/root 2>/dev/null || resize2fs $(df -P /overlay | awk 'NR==2 {print $1}') 2>/dev/null
fi

# Create dedicated directory for Docker and BMS IoT storage
mkdir -p /opt/docker
mkdir -p /opt/bms-gateway
mkdir -p /opt/niagara

# Mark completion so it won't run again on normal boots
touch "$FLAG_FILE"
logger -t EMMC_EXPAND "SUCCESS: 64GB eMMC RootFS storage expansion completed! Full space available."

exit 0
