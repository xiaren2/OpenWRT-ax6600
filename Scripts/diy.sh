#!/bin/bash

#安装和更新软件包
UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	
	# 清理旧的包(更精确的匹配)
	read -ra PKG_NAMES <<< "$PKG_NAME"
	for NAME in "${PKG_NAMES[@]}"; do
		# 使用更精确的匹配,避免误删
		find feeds/luci/ feeds/packages/ package/ -maxdepth 3 -type d \( -name "$NAME" -o -name "luci-*-$NAME" \) -exec rm -rf {} + 2>/dev/null
	done
	
	# 克隆仓库
	if [[ $PKG_REPO == http* ]]; then
		local REPO_NAME=$(basename "$PKG_REPO" .git)
	else
		local REPO_NAME=$(echo "$PKG_REPO" | cut -d '/' -f 2)
		PKG_REPO="https://github.com/$PKG_REPO.git"
	fi
	
	# 检查是否克隆成功
	if ! git clone --depth=1 --single-branch --branch "$PKG_BRANCH" "$PKG_REPO" "package/$REPO_NAME"; then
		echo "错误: 克隆仓库失败 $PKG_REPO"
		return 1
	fi
	
	# 根据 PKG_SPECIAL 处理包
	case "$PKG_SPECIAL" in
		"pkg")
			for NAME in "${PKG_NAMES[@]}"; do
				# 从仓库根目录搜索,不限制路径结构
				find "./package/$REPO_NAME" -maxdepth 3 -type d \( -name "$NAME" -o -name "luci-*-$NAME" \) -print0 | \
					xargs -0 -I {} cp -rf {} ./package/ 2>/dev/null
			done
			rm -rf "./package/$REPO_NAME/"
			;;
		"name")
			# 避免重命名冲突
			rm -rf "./package/$PKG_NAME"
			mv -f "./package/$REPO_NAME" "./package/$PKG_NAME"
			;;
	esac
}

# UPDATE_PACKAGE "luci-app-poweroff" "esirplayground/luci-app-poweroff" "main"
#UPDATE_PACKAGE "luci-app-tailscale" "asvow/luci-app-tailscale" "main"
#UPDATE_PACKAGE "openwrt-gecoosac" "lwb1978/openwrt-gecoosac" "main"
UPDATE_PACKAGE "luci-app-homeproxy" "immortalwrt/homeproxy" "master"
#UPDATE_PACKAGE "luci-app-ddns-go" "sirpdboy/luci-app-ddns-go" "main"
#UPDATE_PACKAGE "luci-app-alist" "sbwml/luci-app-alist" "main"
UPDATE_PACKAGE "luci-app-openlist2" "sbwml/luci-app-openlist2" "main"



#small-package
#UPDATE_PACKAGE "xray-plugin dns2tcp dns2socks haproxy hysteria \
#        naiveproxy v2ray-geoview v2ray-plugin \
#        tuic-client chinadns-ng ipt2socks tcping trojan-plus simple-obfs shadowsocksr-libev \
 #       luci-app-passwall v2dat \
  #      taskd luci-lib-xterm luci-lib-taskd luci-app-ssr-plus luci-app-passwall2 \
   #     quickstart luci-app-quickstart luci-app-cloudflarespeedtest \
    #    luci-theme-argon netdata luci-app-netdata mihomo \
    #    luci-app-nikki frp" "kenzok8/jell" "main" "pkg"
#echo "CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_NONE_Server=n" >> .config
#echo "CONFIG_PACKAGE_xray-core=n" >> .config
#luci-app-onliner
UPDATE_PACKAGE "luci-app-onliner" "https://github.com/kiddin9/op-packages.git" "main" "pkg"
UPDATE_PACKAGE "luci-app-tcpdump" "https://github.com/kiddin9/op-packages.git" "main" "pkg"
UPDATE_PACKAGE "ddnsto" "https://github.com/kiddin9/op-packages.git" "main" "pkg"
UPDATE_PACKAGE "luci-app-ddnsto" "https://github.com/kiddin9/op-packages.git" "main" "pkg"
#raurora配置
UPDATE_PACKAGE "luci-app-aurora-config" "https://github.com/eamonxg/luci-app-aurora-config.git" "master"

#UPDATE_PACKAGE "luci-app-mini-diskmanager" "https://github.com/4IceG/luci-app-mini-diskmanager.git" "main" "pkg"

#speedtest
#UPDATE_PACKAGE "luci-app-netspeedtest" "https://github.com/sbwml/openwrt_pkgs.git" "main" "pkg"
#UPDATE_PACKAGE "speedtest-cli" "https://github.com/sbwml/openwrt_pkgs.git" "main" "pkg"

#UPDATE_PACKAGE "luci-app-adguardhome" "https://github.com/sirpdboy/luci-app-adguardhome.git" "main" "pkg"
#UPDATE_PACKAGE "luci-app-tailscale" "asvow/luci-app-tailscale" "main"
#podman 类似docker
#UPDATE_PACKAGE "openwrt-podman" "https://github.com/breeze303/openwrt-podman" "main"
#文件管理
#UPDATE_PACKAGE "luci-app-quickfile" "https://github.com/sbwml/luci-app-quickfile" "main"
#sed -i 's|$(INSTALL_BIN) $(PKG_BUILD_DIR)/quickfile-$(ARCH_PACKAGES) $(1)/usr/bin/quickfile|$(INSTALL_BIN) $(PKG_BUILD_DIR)/quickfile-aarch64_generic $(1)/usr/bin/quickfile|' package/luci-app-quickfile/quickfile/Makefile

#UPDATE_PACKAGE "frp" "https://github.com/ysuolmai/openwrt-frp.git" "main"

# bandix
UPDATE_PACKAGE "openwrt-bandix" "timsaya/openwrt-bandix" "main"
UPDATE_PACKAGE "luci-app-bandix" "timsaya/luci-app-bandix" "main"

UPDATE_PACKAGE "luci-app-igmpproxy" "xiaren2/luci-app-igmp" "main"
UPDATE_PACKAGE "luci-app-wifihistory" "kenzok8/jell" "main" "pkg"
##########################################
# 替换 immortalwrt 自带 Athena LED
##########################################

echo "替换 emortal Athena LED"

rm -rf package/emortal/luci-app-athena-led
rm -rf package/emortal/athena-led

git clone --depth=1 \
https://github.com/xiaren2/JDC-AX6600-Athena-LED-Controller.git \
package/_athena_tmp

mv package/_athena_tmp/athena-led package/emortal/
mv package/_athena_tmp/luci-app-athena-led package/emortal/

rm -rf package/_athena_tmp

# 启用新包
echo "CONFIG_PACKAGE_luci-app-athena-led=y" >> .config
#echo "CONFIG_PACKAGE_athena-led=y" >> .config

# 只删除这个设备里的 i18n，不删除整行
sed -i '/define Device\/jdcloud_re-cs-02/,/endef/ s/\s*luci-i18n-athena-led-zh-cn//g' \
target/linux/qualcommax/image/ipq60xx.mk

# 确保 .config 里没有旧的 i18n
sed -i '/luci-i18n-athena-led-zh-cn/d' .config

##########################################
# 添加 rtp2httpd 流媒体转发服务器 (feed 模式)
##########################################

# 添加 feed 源（可选锁定版本）
# 使用 main 最新代码：
echo "src-git rtp2httpd https://github.com/stackia/rtp2httpd.git" >> feeds.conf.default
# 或者固定版本（推荐稳定）：
# echo "src-git rtp2httpd https://github.com/stackia/rtp2httpd.git;v3.1.1" >> feeds.conf.default

# 更新并安装 rtp2httpd feed
./scripts/feeds update rtp2httpd
./scripts/feeds install -a -p rtp2httpd

# 启用 luci-app-rtp2httpd 与主程序 rtp2httpd
echo "CONFIG_PACKAGE_rtp2httpd=y" >> .config
echo "CONFIG_PACKAGE_luci-app-rtp2httpd=y" >> .config
echo "✅ 已启用 rtp2httpd 流媒体转发服务器 (通过 feed 方式集成)"

# Add tailscale-community
git clone https://github.com/tokisaki-galaxy/luci-app-tailscale-community --branch=master --depth=1 /tmp/luci-app-tailscale-community
mkdir -p package/luci-app-tailscale-community
cp -r /tmp/luci-app-tailscale-community/luci-app-tailscale-community package/
# Fix luci-app-tailscale-community recursive dependency (select + depends cycle)
sed -i 's/LUCI_DEPENDS:=+tailscale/LUCI_DEPENDS:=tailscale/' package/luci-app-tailscale-community/Makefile

git clone https://github.com/GuNanOvO/openwrt-tailscale --branch=main --depth=1 /tmp/openwrt-tailscale
mkdir -p package/tailscale-community
cp -r /tmp/openwrt-tailscale/package/tailscale/* package/tailscale-community/

TAILSCALE_MK="package/tailscale-community/Makefile"
sed -i '/^include \$(TOPDIR)\/rules.mk/a DISABLE_UPX:=1' "$TAILSCALE_MK"
sed -i "s/(OpenWrt-UPX)/(OpenWrt)/" "$TAILSCALE_MK"
sed -i 's/Zero config VPN (UPX Compressed)/Zero config VPN/' "$TAILSCALE_MK"
sed -i '/mkdir -p.*bin\/packages.*base/d' "$TAILSCALE_MK"
sed -i '/\$(CP).*base\/tailscaled/d' "$TAILSCALE_MK"

echo "CONFIG_PACKAGE_tailscale=y" >> .config
echo "CONFIG_PACKAGE_luci-app-tailscale-community=y" >> .config

echo "========== Tailscale Ready =========="



#######################################
#DIY Settings
#######################################
WRT_IP="192.168.68.1"
WRT_NAME="OWRT"
WRT_WIFI="OWRT"
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")

WIFI_SH=$(find ./target/linux/{mediatek/filogic,qualcommax}/base-files/etc/uci-defaults/ -type f -name "*set-wireless.sh")
WIFI_UC="./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc"
if [ -f "$WIFI_SH" ]; then
	#修改WIFI名称
	sed -i "s/BASE_SSID='.*'/BASE_SSID='$WRT_SSID'/g" $WIFI_SH
	#修改WIFI密码
	sed -i "s/BASE_WORD='.*'/BASE_WORD='$WRT_WORD'/g" $WIFI_SH
elif [ -f "$WIFI_UC" ]; then
	#修改WIFI名称
	sed -i "s/ssid='.*'/ssid='$WRT_SSID'/g" $WIFI_UC
	#修改WIFI密码
	sed -i "s/key='.*'/key='$WRT_WORD'/g" $WIFI_UC
	#修改WIFI地区
	sed -i "s/country='.*'/country='CN'/g" $WIFI_UC
	#修改WIFI加密
	sed -i "s/encryption='.*'/encryption='psk2+ccmp'/g" $WIFI_UC
fi

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE


#补齐依赖
#sudo -E apt-get -y install $(curl -fsSL https://raw.githubusercontent.com/ophub/amlogic-s9xxx-armbian/main/compile-kernel/tools/script/ubuntu2204-make-openwrt-depends)

keywords_to_delete=(
    "xiaomi_ax3600" "xiaomi_ax9000" "xiaomi_ax1800" "glinet" "linksys" "link_nn6600" "kucat"
    "mr7350" "uugamebooster" "luci-app-wol" "luci-i18n-wol-zh-cn" "CONFIG_TARGET_INITRAMFS" "ddns" "luci-app-advancedplus" "mihomo" "nikki"
    "smartdns" "kucat" "luci-app-attendedsysupgrade"
)

[[ $WRT_CONFIG == *"WIFI-NO"* ]] && keywords_to_delete+=("usb" "wpad" "hostapd")
[[ $WRT_CONFIG != *"EMMC"* ]] && keywords_to_delete+=("samba" "autosamba" "disk")
[[ $WRT_CONFIG == *"EMMC"* ]] && keywords_to_delete+=("cmiot_ax18" "qihoo_v6" "qihoo_360v6" "redmi_ax5=y" "zn_m2")

for keyword in "${keywords_to_delete[@]}"; do
    sed -i "/$keyword/d" ./.config
done

# Configuration lines to append to .config
provided_config_lines=(
  # "CONFIG_PACKAGE_luci-app-zerotier=y"
 #   "CONFIG_PACKAGE_luci-i18n-zerotier-zh-cn=y"
    "CONFIG_PACKAGE_luci-app-adguardhome=n"
    "CONFIG_PACKAGE_luci-i18n-adguardhome-zh-cn=n"
  #  "CONFIG_PACKAGE_luci-app-poweroff=y"
   # "CONFIG_PACKAGE_luci-i18n-poweroff-zh-cn=y"
   # "CONFIG_PACKAGE_cpufreq=y"
  #  "CONFIG_PACKAGE_luci-app-cpufreq=y"
   # "CONFIG_PACKAGE_luci-i18n-cpufreq-zh-cn=y"
    "CONFIG_PACKAGE_luci-app-ttyd=y"
    "CONFIG_PACKAGE_luci-i18n-ttyd-zh-cn=y"
    "CONFIG_PACKAGE_ttyd=y"
  #  "CONFIG_PACKAGE_luci-app-homeproxy=y"
  #  "CONFIG_PACKAGE_luci-i18n-homeproxy-zh-cn=y"
  #  "CONFIG_PACKAGE_luci-app-ddns-go=y"
    #"CONFIG_PACKAGE_luci-i18n-ddns-go-zh-cn=y"
  #  "CONFIG_PACKAGE_luci-app-argon-config=y"
    "CONFIG_PACKAGE_luci-app-argon=n"
    "CONFIG_PACKAGE_nano=y"
    "CONFIG_BUSYBOX_CONFIG_LSUSB=n"
 #  "CONFIG_PACKAGE_luci-app-netspeedtest=y"
   # "CONFIG_PACKAGE_luci-app-vlmcsd=y"
    "CONFIG_COREMARK_OPTIMIZE_O3=y"
    "CONFIG_COREMARK_ENABLE_MULTITHREADING=y"
    "CONFIG_COREMARK_NUMBER_OF_THREADS=6"
    #"CONFIG_PACKAGE_luci-theme-design=y"
    "CONFIG_PACKAGE_luci-app-filetransfer=y"
    "CONFIG_PACKAGE_openssh-sftp-server=y"
   # "CONFIG_PACKAGE_luci-app-frpc=y" 
   #apk还是opkg
  #  "CONFIG_OPKG_USE_CURL=y"
  #  "CONFIG_PACKAGE_opkg=y"   
   "CONFIG_USE_APK=y"
    "CONFIG_PACKAGE_apk-openssl=y"
	
   # "CONFIG_PACKAGE_luci-app-tailscale=y"
    #"CONFIG_PACKAGE_luci-app-msd_lite=y"
   # "CONFIG_PACKAGE_luci-app-lucky=y"
   # "CONFIG_PACKAGE_luci-app-gecoosac=y"
	"CONFIG_PACKAGE_kmod-wireguard=y"
    "CONFIG_PACKAGE_wireguard-tools=y"
	"CONFIG_PACKAGE_luci-proto-wireguard=y"
  # "CONFIG_PACKAGE_luci-app-cifs-mount=y"
	"CONFIG_PACKAGE_kmod-fs-cifs=y"
    "CONFIG_PACKAGE_cifsmount=y"
    "CONFIG_PACKAGE_luci-app-onliner=y"
    "CONFIG_PACKAGE_luci-theme-bootstrap=y"
	 "CONFIG_PACKAGE_luci-app-tcpdump=y"
	 "CONFIG_PACKAGE_luci-app-tcpdump-zh-cn=y"
	 "CONFIG_PACKAGE_ddnsto=y"
	  "CONFIG_PACKAGE_luci-app-ddnsto=y"
	 "CONFIG_PACKAGE_luci-app-ddnsto-zh-cn=y"
	  "CONFIG_PACKAGE_luci-app-aurora-config=y"
	#  "CONFIG_PACKAGE_luci-app-mini-diskmanager=y"
)
# 修改"CONFIG_USE_APK=n"和WRT-core里的，会将apk源替换为ipk，如用apk，opkg相关也应删除

#[[ $WRT_CONFIG == *"WIFI-NO"* ]] && provided_config_lines+=("CONFIG_PACKAGE_hostapd-common=n" "CONFIG_PACKAGE_wpad-openssl=n")
if [[ $WRT_CONFIG == *"WIFI-NO"* ]]; then
  provided_config_lines+=("CONFIG_PACKAGE_hostapd-common=n" "CONFIG_PACKAGE_wpad-openssl=n")
fi


# 只有 WRT_CONFIG 不包含 'EMMC' 且包含 'WIFI-NO' 时执行删除命令
if [[ "$WRT_CONFIG" != *"EMMC"* && "$WRT_CONFIG" == *"WIFI-NO"* ]]; then
    sed -i 's/\s*kmod-[^ ]*usb[^ ]*\s*\\\?//g' ./target/linux/qualcommax/Makefile
    echo "已删除 Makefile 中的 USB 相关 package"
fi

[[ $WRT_CONFIG == *"EMMC"* ]] && provided_config_lines+=(
    #"CONFIG_PACKAGE_luci-app-diskman=y"
    #"CONFIG_PACKAGE_luci-i18n-diskman-zh-cn=y"
	
#	docker相关内容
  #  "CONFIG_PACKAGE_luci-app-docker=m"
  #  "CONFIG_PACKAGE_luci-i18n-docker-zh-cn=m"
 #   "CONFIG_PACKAGE_luci-app-dockerman=m"
 #   "CONFIG_PACKAGE_luci-i18n-dockerman-zh-cn=m"
    #"CONFIG_PACKAGE_luci-app-podman=y"
    #"CONFIG_PACKAGE_podman=y"
 #   "CONFIG_PACKAGE_iptables-mod-extra=y"
 #   "CONFIG_PACKAGE_ip6tables-nft=y"
 #   "CONFIG_PACKAGE_ip6tables-mod-fullconenat=y"
 #   "CONFIG_PACKAGE_iptables-mod-fullconenat=y"
  #  "CONFIG_PACKAGE_libip4tc=y"
  #  "CONFIG_PACKAGE_libip6tc=y"
  #   "CONFIG_PACKAGE_kmod-ip6tables=y"
 #    "CONFIG_PACKAGE_kmod-ipt-conntrack=y"
   #  "CONFIG_PACKAGE_kmod-ipt-extra=y"
   #  "CONFIG_PACKAGE_kmod-ipt-nat=y"
   #  "CONFIG_PACKAGE_kmod-ipt-nat6=y"
    # "CONFIG_PACKAGE_kmod-ipt-physdev=y"
  #   "CONFIG_PACKAGE_kmod-nf-ipt6=y"
   #  "CONFIG_PACKAGE_kmod-nf-ipvs=y"
  #   "CONFIG_PACKAGE_kmod-nf-nat6=y"
 # "CONFIG_PACKAGE_iptables-mod-conntrack-extra=y"
 #    "CONFIG_PACKAGE_kmod-br-netfilter=y"
 	# "CONFIG_PACKAGE_kmod-dummy=y"
 	"CONFIG_PACKAGE_kmod-veth=y"
	
	 # "CONFIG_PACKAGE_luci-app-openlist2=y"
 #   "CONFIG_PACKAGE_luci-i18n-openlist2-zh-cn=y"
    #"CONFIG_PACKAGE_fdisk=y"
    #"CONFIG_PACKAGE_parted=y"
	"CONFIG_PACKAGE_luci-app-homeproxy=y"
#    "CONFIG_PACKAGE_luci-app-passwall=y"
#    "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_Libev_Client=y"
    "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_Libev_Server=n"
    "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR_Libev_Client=n"
    "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Simple_Obfs=n"
    "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_SingBox=n"
    "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_Plus=n"
    "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray_Plugin=n"
    "CONFIG_PACKAGE_htop=y"
    #"CONFIG_PACKAGE_fuse-utils=y"
    "CONFIG_PACKAGE_tcpdump=y"
    #"CONFIG_PACKAGE_sgdisk=y"
    "CONFIG_PACKAGE_openssl-util=y"
    #"CONFIG_PACKAGE_resize2fs=y"
    "CONFIG_PACKAGE_qrencode=y"
    "CONFIG_PACKAGE_smartmontools-drivedb=y"
    "CONFIG_PACKAGE_usbutils=y"
    "CONFIG_PACKAGE_default-settings=y"
    "CONFIG_PACKAGE_default-settings-chn=y"
   
  
   

    #"CONFIG_PACKAGE_automount=y"
 #   "CONFIG_PACKAGE_luci-app-frps=y"
    #"CONFIG_PACKAGE_luci-app-ssr-plus=y"
    #"CONFIG_PACKAGE_luci-app-passwall2=y"
    "CONFIG_PACKAGE_luci-app-samba4=y"
    "CONFIG_PACKAGE_libicu=y"
    "CONFIG_PACKAGE_icu=y"
  #  "CONFIG_PACKAGE_luci-app-openclash=y"
    #"CONFIG_PACKAGE_luci-app-quickfile=y"
    #"CONFIG_PACKAGE_quickfile=y"
)

[[ $WRT_CONFIG == "IPQ"* ]] && provided_config_lines+=(
    "CONFIG_PACKAGE_sqm-scripts-nss=y"
 #   "CONFIG_PACKAGE_luci-app-sqm=y"
  #  "CONFIG_PACKAGE_luci-i18n-sqm-zh-cn=y"
)

# Append configuration lines to .config
for line in "${provided_config_lines[@]}"; do
    echo "$line" >> .config
done


#./scripts/feeds update -a
#./scripts/feeds install -a

#find ./ -name "cascade.css" -exec sed -i 's/#5e72e4/#6fa49a/g; s/#483d8b/#6fa49a/g' {} \;
#find ./ -name "dark.css" -exec sed -i 's/#5e72e4/#6fa49a/g; s/#483d8b/#6fa49a/g' {} \;


find ./ -name "cascade.css" -exec sed -i 's/#5e72e4/#31A1A1/g; s/#483d8b/#31A1A1/g' {} \;
find ./ -name "dark.css" -exec sed -i 's/#5e72e4/#31A1A1/g; s/#483d8b/#31A1A1/g' {} \;
find ./ -name "cascade.less" -exec sed -i 's/#5e72e4/#31A1A1/g; s/#483d8b/#31A1A1/g' {} \;
find ./ -name "dark.less" -exec sed -i 's/#5e72e4/#31A1A1/g; s/#483d8b/#31A1A1/g' {} \;

#修改ttyd为免密
install -Dm755 "${GITHUB_WORKSPACE}/Scripts/99_ttyd-nopass.sh" "package/base-files/files/etc/uci-defaults/99_ttyd-nopass"

install -Dm755 "${GITHUB_WORKSPACE}/Scripts/99_set_argon_primary" "package/base-files/files/etc/uci-defaults/99_set_argon_primary"

# 增加全局ULA脚本
#install -Dm755 "${GITHUB_WORKSPACE}/Scripts/12_network-generate-ula" "package/base-files/files/etc/uci-defaults/12_network-generate-ula"






#修改软件源地址，当是opkg的时候
#install -Dm755 "${GITHUB_WORKSPACE}/Scripts/99-distfeeds.conf" "package/emortal/default-settings/files/99-distfeeds.conf"
#sed -i '/define Package\/default-settings\/install/a \
#\t$(INSTALL_DIR) $(1)/etc\n\t$(INSTALL_DATA) ./files/99-distfeeds.conf $(1)/etc/99-distfeeds.conf' \
#package/emortal/default-settings/Makefile
#sed -i "/exit 0/i\\
#[ -f \'/etc/99-distfeeds.conf\' ] && mv \'/etc/99-distfeeds.conf\' \'/etc/opkg/distfeeds.conf\'\n\
#sed -ri \'/check_signature/s@^[^#]@#&@\' /etc/opkg.conf\n" "package/emortal/default-settings/files/99-default-settings"


#解决 dropbear 配置的 bug
install -Dm755 "${GITHUB_WORKSPACE}/Scripts/99_dropbear_setup.sh" "package/base-files/files/etc/uci-defaults/99_dropbear_setup"

#if [[ "$WRT_CONFIG" == *"EMMC"* ]]; then
#    #解决 nginx 的问题
#    install -Dm755 "${GITHUB_WORKSPACE}/Scripts/99_nginx_setup.sh" "package/base-files/files/etc/uci-defaults/99_nginx_setup"
#fi


find ./ -name "getifaddr.c" -exec sed -i 's/return 1;/return 0;/g' {} \;

#fix makefile for apk
if [ -f ./package/v2ray-geodata/Makefile ]; then
    sed -i 's/VER)-\$(PKG_RELEASE)/VER)-r\$(PKG_RELEASE)/g' ./package/v2ray-geodata/Makefile
fi
if [ -f ./package/luci-lib-taskd/Makefile ]; then
    sed -i 's/>=1\.0\.3-1/>=1\.0\.3-r1/g' ./package/luci-lib-taskd/Makefile
fi
if [ -f ./package/luci-app-openclash/Makefile ]; then
    sed -i '/^PKG_VERSION:=/a PKG_RELEASE:=1' ./package/luci-app-openclash/Makefile
fi
if [ -f ./package/luci-app-quickstart/Makefile ]; then
    # 把 PKG_VERSION:=x.y.z-n 拆成 PKG_VERSION:=x.y.z 和 PKG_RELEASE:=n
    sed -i -E 's/PKG_VERSION:=([0-9]+\.[0-9]+\.[0-9]+)-([0-9]+)/PKG_VERSION:=\1\nPKG_RELEASE:=\2/' ./package/luci-app-quickstart/Makefile
fi
if [ -f ./package/luci-app-store/Makefile ]; then
    # 把 PKG_VERSION:=x.y.z-n 拆成 PKG_VERSION:=x.y.z 和 PKG_RELEASE:=n
    sed -i -E 's/PKG_VERSION:=([0-9]+\.[0-9]+\.[0-9]+)-([0-9]+)/PKG_VERSION:=\1\nPKG_RELEASE:=\2/' ./package/luci-app-store/Makefile
fi

#自定义的初始化脚本替换原来的脚本ddns-go
#if [ -f ./package/luci-app-ddns-go/ddns-go/file/ddns-go.init ]; then
#    cp ${GITHUB_WORKSPACE}/Scripts/ddns-go.init ./package/luci-app-ddns-go/ddns-go/file/ddns-go.init
#	chmod +x ./package/luci-app-ddns-go/ddns-go/file/ddns-go.init
#	echo "ddns-go.init has been replaced successfully."
#fi


#sed -i 's/"admin\/services\/openlist"/"admin\/nas\/openlist"/' package/luci-app-openlist/luci-app-openlist/root/usr/share/luci/menu.d/luci-app-openlist.json

#修复 rust 编译
RUST_FILE=$(find ./feeds/packages/ -maxdepth 3 -type f -wholename "*/rust/Makefile")
if [ -f "$RUST_FILE" ]; then
	echo " "

	sed -i 's/ci-llvm=true/ci-llvm=false/g' $RUST_FILE
    patch $RUST_FILE ${GITHUB_WORKSPACE}/Scripts/rust-makefile.patch
	
	echo "rust has been fixed!"
fi


# 修复 OpenWrt 包里不合规（非数字开头）的 PKG_VERSION，
# 搜索范围：传入目录（默认 .）向下最多 3 层的所有 Makefile
fix_openwrt_apk_versions() {
  local ROOT="${1:-.}"
  local MAX_DEPTH="${2:-3}"   # 可选：第二个参数可改最大深度，默认 3

  log() { printf '[fix-apk] %s\n' "$*" >&2; }

  process_file() {
    local f="$1"

    # 读取首个 PKG_VERSION
    local line ver_raw
    line="$(grep -m1 -E '^[[:space:]]*PKG_VERSION:=' "$f" || true)" || true
    [[ -z "$line" ]] && return 0

    ver_raw="$(sed -E 's/^[[:space:]]*PKG_VERSION:=[[:space:]]*//; s/[[:space:]]+$//' <<<"$line")"
    ver_raw="${ver_raw%\"}"; ver_raw="${ver_raw#\"}"

    # 已经是数字开头就无需修复
    if [[ "$ver_raw" =~ ^[0-9] ]]; then
      return 0
    fi

    # 提取数字（可含点）的第一段作为包版本
    local ver_num
    ver_num="$(grep -oE '[0-9]+([.][0-9]+)*' <<<"$ver_raw" | head -n1 || true)"
    if [[ -z "$ver_num" ]]; then
      log "WARN: $f 的 PKG_VERSION='$ver_raw' 无法提取数字，跳过。"
      return 0
    fi

    log "修复 $f: PKG_VERSION '$ver_raw' -> '$ver_num'"
    cp -n "$f" "$f.bak" 2>/dev/null || true

    # 1) 替换首个 PKG_VERSION 为数字版本
    sed -i -E "0,/^[[:space:]]*PKG_VERSION:=/ s//PKG_VERSION:=${ver_num}/" "$f"

    # 2) 若无 PKG_SOURCE_VERSION，则在第一处 PKG_VERSION 行之后插入
    if ! grep -qE '^[[:space:]]*PKG_SOURCE_VERSION:=' "$f"; then
      awk -v raw="$ver_raw" '
        BEGIN{added=0}
        {
          print $0
          if (!added && $0 ~ /^[[:space:]]*PKG_VERSION:=/) {
            print "PKG_SOURCE_VERSION:=" raw
            added=1
          }
        }' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    fi

    # 3) 若无 PKG_BUILD_DIR，则在 PKG_SOURCE_VERSION 后面补一行
    if ! grep -qE '^[[:space:]]*PKG_BUILD_DIR:=' "$f"; then
      awk '
        BEGIN{added=0}
        {
          print $0
          if (!added && $0 ~ /^[[:space:]]*PKG_SOURCE_VERSION:=/) {
            print "PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_SOURCE_VERSION)"
            added=1
          }
        }' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    fi

    # 4) 让 PKG_SOURCE / PKG_SOURCE_URL 里的 $(PKG_VERSION) 指向 $(PKG_SOURCE_VERSION)
    sed -i -E '/^[[:space:]]*PKG_SOURCE:=/ s/\$\((PKG_VERSION)\)/$(PKG_SOURCE_VERSION)/g' "$f"
    sed -i -E '/^[[:space:]]*PKG_SOURCE_URL:=/ s/\$\((PKG_VERSION)\)/$(PKG_SOURCE_VERSION)/g' "$f"
  }

  # 在 ROOT 下最多 3 层（或自定义 MAX_DEPTH）寻找所有 Makefile
  while IFS= read -r -d '' mk; do
    process_file "$mk"
  done < <(find "$ROOT" -maxdepth "$MAX_DEPTH" -type f -name Makefile -print0)

  log "扫描与修复完成。"
}

fix_openwrt_apk_versions package


#fix cmake minimum version issue
if ! grep -q "CMAKE_POLICY_VERSION_MINIMUM" include/cmake.mk; then
  echo 'CMAKE_OPTIONS += -DCMAKE_POLICY_VERSION_MINIMUM=3.5' >> include/cmake.mk
fi

# 修复 luci-app-ddnsto 的 apk 版本号（双 r 问题）
DDNSTO_MK="package/luci-app-ddnsto/Makefile"
if [ -f "$DDNSTO_MK" ]; then
    echo "Fixing luci-app-ddnsto Makefile for apk version format"
    sed -i \
        -e 's/^PKG_VERSION:=\(.*\)-r[0-9]\+$/PKG_VERSION:=\1/' \
        "$DDNSTO_MK"
fi


