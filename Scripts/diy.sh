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
#UPDATE_PACKAGE "luci-app-homeproxy" "immortalwrt/homeproxy" "master"
UPDATE_PACKAGE "luci-app-ddns-go" "OldCoding/luci-app-ddns-go" "main"
#UPDATE_PACKAGE "luci-app-alist" "sbwml/luci-app-alist" "main"
#UPDATE_PACKAGE "luci-app-openlist2" "sbwml/luci-app-openlist2" "main"



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
#UPDATE_PACKAGE "luci-app-onliner" "https://github.com/kiddin9/op-packages.git" "main" "pkg"
UPDATE_PACKAGE "luci-app-onliner-overview" "https://github.com/xiaren2/luci-app-onliner-overview.git" "new"
UPDATE_PACKAGE "luci-app-tcpdump-master" "https://github.com/xiaren2/luci.git" "main" "pkg"
#UPDATE_PACKAGE "ddnsto" "https://github.com/kiddin9/op-packages.git" "main" "pkg"
#UPDATE_PACKAGE "luci-app-ddnsto" "https://github.com/kiddin9/op-packages.git" "main" "pkg"
#raurora配置
#UPDATE_PACKAGE "luci-app-aurora-config" "https://github.com/eamonxg/luci-app-aurora-config.git" "master"

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
#UPDATE_PACKAGE "luci-app-netwiz" "https://github.com/huchd0/luci-app-netwiz.git" "master" "pkg"
# bandix
UPDATE_PACKAGE "openwrt-bandix" "timsaya/openwrt-bandix" "main"
UPDATE_PACKAGE "luci-app-bandix" "timsaya/luci-app-bandix" "main"

UPDATE_PACKAGE "luci-app-igmpproxy" "xiaren2/luci-app-igmp" "main"
#UPDATE_PACKAGE "luci-app-wifihistory" "kenzok8/jell" "main" "pkg"
##########################################
# 替换 immortalwrt 自带 Athena LED
##########################################

echo "替换 emortal Athena LED"

rm -rf package/emortal/luci-app-athena-led
rm -rf package/emortal/athena-led

#test分支
#git clone --depth=1 -b js \
#主支
git clone --depth=1 \
https://github.com/xiaren2/JDC-AX6600-Athena-LED-Controller.git \
package/_athena_tmp
#git clone --depth=1 https://github.com/xiaren2/JDC-AX6600-Athena-LED-Controller.git package/_athena_tmp

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

##########################################
# 添加 rtp2httpd 流媒体转发服务器 (package 模式，强制覆盖官方旧版)
##########################################

# 1) 直接克隆到你指定的 package 目录（编译时会优先扫 package/）
git clone --depth=1 \
  https://github.com/stackia/rtp2httpd.git \
  package/rtp2httpd

# 2) 如果后面还会执行 ./scripts/feeds install -a，先把官方 feeds 里的同名包清掉，防止被覆盖
rm -rf feeds/packages/net/rtp2httpd
rm -rf feeds/luci/applications/luci-app-rtp2httpd

# 3) 启用包
echo "CONFIG_PACKAGE_rtp2httpd=y" >> .config
echo "CONFIG_PACKAGE_luci-app-rtp2httpd=y" >> .config
echo "✅ 已启用 rtp2httpd 流媒体转发服务器 (通过 package/ 方式集成，覆盖官方旧版)"


