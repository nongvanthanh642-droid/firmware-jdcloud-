#!/bin/sh
# =============================================================================
# /etc/uci-defaults/98-custom-settings.sh
# Initial System Provisioning for 4G Gateway & IoT
# =============================================================================

# Set Vietnamese locale by default if enabled
uci set luci.main.lang='vi'
uci commit luci

# Set system timezone to Asia/Ho_Chi_Minh (+07:00)
uci set system.@system[0].zonename='Asia/Ho_Chi_Minh'
uci set system.@system[0].timezone='<+07>-7'
uci commit system

# Pre-configure Docker daemon to use the expanded eMMC /opt/docker data-root
if [ -d "/opt/docker" ] || mkdir -p /opt/docker; then
    mkdir -p /etc/docker
    cat << 'EOF' > /etc/docker/daemon.json
{
  "data-root": "/opt/docker",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
fi

# Enable MWAN3 automatic cellular failover tracking
uci set mwan3.globals.mmx_mask='0x3F00'
uci commit mwan3 2>/dev/null || true

exit 0
