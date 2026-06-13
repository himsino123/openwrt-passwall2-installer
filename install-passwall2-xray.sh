#!/bin/sh

echo "=== Update package list ==="
opkg update

echo "=== Install basic HTTPS tools ==="
opkg install wget-ssl ca-bundle ca-certificates

echo "=== Install dnsmasq-full ==="
opkg install dnsmasq-full

echo "=== Install Passwall2 transparent proxy requirements ==="
opkg install kmod-nft-socket kmod-nft-tproxy kmod-nft-nat ip-full iptables-nft

echo "=== Add Passwall2 public key ==="
wget -O /tmp/passwall.pub https://ftp.iij.ad.jp/pub/sourceforge.jp/storage/g/o/op/openwrt-passwall-build/passwall.pub
opkg-key add /tmp/passwall.pub

echo "=== Detect OpenWrt release and architecture ==="
read release arch << EOF
$(. /etc/openwrt_release; echo ${DISTRIB_RELEASE%.*} $DISTRIB_ARCH)
EOF

echo "Release: $release"
echo "Arch: $arch"

echo "=== Add Passwall2 feeds ==="
for feed in passwall_luci passwall_packages passwall2; do
    grep -q "src/gz $feed " /etc/opkg/customfeeds.conf || \
    echo "src/gz $feed https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-$release/$arch/$feed" >> /etc/opkg/customfeeds.conf
done

echo "=== Update package list again ==="
opkg update

echo "=== Install Passwall2 + Xray core ==="
opkg install luci-app-passwall2 xray-core v2ray-geoip v2ray-geosite

echo "=== Enable Passwall2 ==="
/etc/init.d/passwall2 enable

echo "=== Done ==="
echo "Open LuCI > Services > Passwall2"
