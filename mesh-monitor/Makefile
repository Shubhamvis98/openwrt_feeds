# Copyright (C) 2026 Shubham Vishwakarma <shubhamvis98@fossfrog.in>

include $(TOPDIR)/rules.mk

PKG_NAME:=mesh-monitor
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/mesh-monitor
  SECTION:=fossfrog
  CATEGORY:=fossfrog
  TITLE:=mesh monitor
  MAINTAINER:=Shubham Vishwakarma <shubhamvis98@fossfrog.in>
endef

define Package/mesh-monitor/description
  Monitor mesh configuration for uCentral and spawn the mesh interface if it doesn’t exist.
endef

define Build/Compile

endef

define Package/mesh-monitor/install
	$(CP) ./files/* $(1)/
	chmod +x $(1)/etc/init.d/meshmonitor
	chmod +x $(1)/usr/bin/meshmonitor
endef

$(eval $(call BuildPackage,mesh-monitor))
