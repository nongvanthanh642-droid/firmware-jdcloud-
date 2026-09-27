# OpenWrt CI Builder for JD Cloud AX1800 Pro (Qualcomm IPQ6000)

Firmware compilation suite tailored for **JD Cloud AX1800 Pro** (512MB RAM, 64GB eMMC), configured as an industrial **4G Cellular Gateway & IoT / BMS (Niagara N4 / Node-RED) Edge Controller**.

---

## 🚀 Quick Start (Compile in 3 Steps)

1. **Fork or Push this repository to your GitHub account**:
   - Push these exact files to your new GitHub repository:
     - `.github/workflows/build-openwrt.yml`
     - `diy-part1.sh`
     - `diy-part2.sh`
     - `.config`
     - `files/etc/uci-defaults/99-expand-emmc.sh`
     - `files/etc/uci-defaults/98-custom-settings.sh`

2. **Trigger Compilation**:
   - Navigate to the **Actions** tab on your GitHub repository.
   - Select **"Build OpenWrt for JD Cloud AX1800 Pro"** from the left sidebar.
   - Click **Run workflow** -> Select branch (`master`) -> Click **Run workflow**.

3. **Download Firmware**:
   - Once completed (~45 to 90 minutes depending on GitHub runner speed), go to the **Releases** tab or the bottom of the Actions run summary.
   - Download the `*sysupgrade.bin` artifact.
   - Flash via U-Boot Web Failsafe UI (`192.168.1.1`) or LuCI System -> Backup / Flash Firmware.

---

## 📦 Key Specifications & Included Features

| Feature | Specification / Included Package |
|---|---|
| **Device Model** | JD Cloud AX1800 Pro (Qualcomm IPQ6000) / `jdcloud_re-cs-07` |
| **Storage (64GB eMMC)** | Automated firstboot script `99-expand-emmc.sh` expands partition & ext4 filesystem to utilize all 64GB for Docker & Edge storage. |
| **4G / 5G Cellular Drivers** | `kmod-usb-net-rndis`, `kmod-usb-net-qmi-wwan`, `kmod-usb-net-cdc-mbim`, `kmod-usb-serial-option`, `modemmanager`, `usb-modeswitch` |
| **Band Lock & LTE Only** | `luci-app-modemband` (Web UI for locking LTE bands: B1, B3, B7, B8, B28, etc.) |
| **Cell Lock (BTS / PCI)** | `atinout`, `picocom` for Quectel/Fibocom AT command scripts (`AT+QNWLOCK`) |
| **SMS & USSD** | `luci-app-sms-tool` + `sms-tool` for OTP reading and balance checks |
| **Multi-WAN Failover** | `mwan3` + `luci-app-mwan3` + `luci-app-nlbwmon` (Bandwidth monitor) |
| **IoT & Edge Apps** | Docker CE (`dockerd`, `docker-compose`, `luci-app-dockerman`), Mosquitto MQTT, Tailscale VPN |
| **Security & Routing** | NekoBox (`sing-box` core for Proxy/SNI bypass), AdGuard Home |
| **DNS Stack** | `dnsmasq-full` (with DNSSEC, ipset, nftset support) |
| **Language & Theme** | Vietnamese (`luci-i18n-base-vi`) + Argon Theme (`luci-theme-argon`) |

---

## 🛠️ Cell Lock & AT Command Guide (Quectel EP06 / EM12 / RM500Q)

To lock to a specific cell tower (PCI and EARFCN) using `atinout` in SSH:

```bash
# 1. Check current serving cell information
echo "AT+QENG=\"servingcell\"" | atinout - /dev/ttyUSB2 -

# 2. Force 4G LTE Only mode
echo "AT+QCFG=\"nwscanmode\",3,1" | atinout - /dev/ttyUSB2 -

# 3. Lock to specific Cell (e.g., EARFCN 1850, PCI 324)
echo "AT+QNWLOCK=\"common/4g\",1,1850,324" | atinout - /dev/ttyUSB2 -

# 4. Clear Cell Lock (Restore Auto-Selection)
echo "AT+QNWLOCK=\"common/4g\",0" | atinout - /dev/ttyUSB2 -
```

---

## 💾 64GB eMMC Storage Utilization

On first boot after flashing, `/etc/uci-defaults/99-expand-emmc.sh` automatically:
1. Re-reads and fixes the GPT secondary partition table.
2. Expands the rootfs partition to 100% of the 64GB eMMC chip.
3. Resizes the ext4 filesystem using `resize2fs`.
4. Configures Docker root directory at `/opt/docker` so container images won't run out of space.
