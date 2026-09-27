#!/bin/bash
# =============================================================================
# diy-part1.sh - Custom Feeds configuration for OpenWrt Source
# Target: JD Cloud AX1800 Pro (Qualcomm IPQ6000)
# BMS/IoT Gateway Stack: Modemband, SMS Tool, NekoBox, AdGuardHome, Argon Theme
# =============================================================================

# Remove existing duplicate feeds if any
sed -i 's/^#\(.*telephony\)/\1/' feeds.conf.default

# 1. JerryKuKu Argon Theme & Configuration Web App
echo 'src-git argon https://github.com/jerrykuku/luci-theme-argon.git' >> feeds.conf.default
echo 'src-git argonconfig https://github.com/jerrykuku/luci-app-argon-config.git' >> feeds.conf.default

# 2. 4G/LTE Modem Band Locking Web UI (modemband)
echo 'src-git modemband https://github.com/4fun/luci-app-modemband.git' >> feeds.conf.default

# 3. SMS & USSD Tool (sms-tool) for Quectel/Fibocom/Huawei modems
echo 'src-git smstool https://github.com/koshev-ay/luci-app-sms-tool.git' >> feeds.conf.default

# 4. AdGuardHome & LuCI GUI
echo 'src-git adguardhome https://github.com/rufengsuixing/luci-app-adguardhome.git' >> feeds.conf.default

# 5. NekoBox (Sing-box Universal Proxy / SNI Bypass for IoT & Edge)
echo 'src-git nekobox https://github.com/Thaolga/luci-app-nekobox.git' >> feeds.conf.default

# Optional: Extra Modem drivers feed if compiling older official OpenWrt
# echo 'src-git modemfeed https://github.com/Siriling/openwrt-modem-feeds.git' >> feeds.conf.default

echo ">>> Custom feeds successfully injected into feeds.conf.default!"
