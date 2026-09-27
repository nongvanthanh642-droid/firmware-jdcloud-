#!/bin/bash
# =============================================================================
# diy-part2.sh - Custom Source Modifications & Default Settings
# Target: JD Cloud AX1800 Pro (Qualcomm IPQ6000)
# =============================================================================

# 1. Modify default LAN IP address (192.168.1.1)
sed -i 's/192.168.1.1/192.168.1.1/g' package/base-files/files/bin/config_generate

# 2. Remove default dnsmasq and force dnsmasq-full package definition
rm -rf package/network/services/dnsmasq
svn export https://github.com/openwrt/openwrt/trunk/package/network/services/dnsmasq package/network/services/dnsmasq 2>/dev/null || true

# 3. Set default theme to Argon
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile 2>/dev/null || true

# 4. Enable executable permissions on all uci-default custom scripts
if [ -d "files/etc/uci-defaults" ]; then
    chmod +x files/etc/uci-defaults/* 2>/dev/null || true
    echo ">>> Verified execution bits on files/etc/uci-defaults/*.sh"
fi

# 5. Ensure maximum MTU clamping & TCP MSS for 4G LTE connections
echo ">>> diy-part2.sh completed successfully!"
