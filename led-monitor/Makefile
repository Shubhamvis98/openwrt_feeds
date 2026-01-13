# Copyright (C) 2026 Shubham Vishwakarma <shubhamvis98@fossfrog.in>

include $(TOPDIR)/rules.mk

PKG_NAME:=led-monitor
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/led-monitor
  SECTION:=fossfrog
  CATEGORY:=fossfrog
  TITLE:=led monitor
  MAINTAINER:=Shubham Vishwakarma <shubhamvis98@fossfrog.in>
endef

define Package/led-monitor/description
 Custom LED combinations specifically built for Indio UM-235AX
endef

define Build/Compile

endef

define Package/led-monitor/install
	$(CP) ./files/* $(1)/
	chmod +x $(1)/etc/init.d/led_monitor
	chmod +x $(1)/usr/bin/ledmonitor
endef

$(eval $(call BuildPackage,led-monitor))
