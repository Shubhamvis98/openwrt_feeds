#!/bin/sh
# Copyright (C) 2026 Shubham Vishwakarma <shubhamvis98@fossfrog.in>

# Variables
all_leds="mesh_blue mesh_yellow net_blue net_yellow wifi_blue"
upgrade_leds="mesh_blue net_blue wifi_blue"
factory_leds="mesh_yellow net_yellow"
GW_STATE=/tmp/gateway_state
FA_STATE=/tmp/factory_state

# Functions
check_mesh_iface() {
	MESH_IF="$(iw dev | awk '$1=="Interface"{i=$2} $1=="type"&&$2=="mesh"{print i; exit}')"
	echo $MESH_IF
}

led_timer() {
	[ -n "$1" ] && LED=/sys/class/leds/$1 || return
	[ -n "$2" ] && DELAY=$2 || DELAY=500
	if [ -e "$LED" ]; then
		if ! grep -qF "[timer]" $LED/trigger; then
			echo timer > $LED/trigger
			for i in $LED/delay_*; do echo $DELAY > $i; done
		fi
	fi
}

delay() {
	if [ -n "$1" ]; then
		usleep $(awk -v del="$1" 'BEGIN { printf "%.0f\n", del * 1000000 }')
	fi
}

led_off() {
	case $1 in
		all)
			for i in $all_leds; do
				led_off $i
			done
			;;
		*)
			[ -n "$1" ] && LED=/sys/class/leds/$1 || return
			if [ -e "$LED" ]; then
				echo none > $LED/trigger
				echo 0 > $LED/brightness
			fi
			;;
	esac
}

led_on() {
	[ -n "$1" ] && LED=/sys/class/leds/$1 || return
	if [ -e "$LED" ]; then
		grep -qF "[default-on]" $LED/trigger ||
			echo default-on > $LED/trigger
	fi
}

check_net() {
	netstat -a | grep $(jsonfilter -i /etc/ucentral/gateway.json -e '@.port') | grep -q 'ESTABLISHED'
	if [ $? -eq 0 ]; then
		echo online > $GW_STATE
	else
		echo offline > $GW_STATE
	fi
}

led_state() {
case $1 in
	upgrade)
		led_off all
		for i in $upgrade_leds; do
			led_timer $i
		done
		;;
	factory)
		for i in $factory_leds; do
			led_off $i
		done
		for i in $factory_leds; do
			led_timer $i
		done
		;;
	internet)
		ping -W3 -w3 google.com >/dev/null 2>&1
		if [ $? -eq 0 ]; then
			led_on net_blue
			led_off net_yellow
		else
			led_on net_yellow
			led_off net_blue
		fi
		;;
	gateway)
		if [ -f "$GW_STATE" ]; then
			if grep -q online "$GW_STATE"; then
				led_timer mesh_blue
				led_off net_yellow
			else
				led_timer net_yellow
				led_off net_blue
			fi
		fi
		;;
	mesh)
		if grep -q mesh /etc/ucentral/ucentral.active; then
			MIFACE=$(check_mesh_iface)
			if [ $(iw "$MIFACE" station dump | grep Station | wc -l) -gt 0 ]; then
				led_on mesh_blue
				led_off mesh_yellow
			else
				led_on mesh_yellow
				led_off mesh_blue
			fi

			if grep -q online "$GW_STATE"; then
				if [ ! $(iw "$MIFACE" station dump | grep Station | wc -l) -gt 0 ]; then
					led_timer mesh_blue
					led_off mesh_yellow
				fi
			fi
		else
			led_off mesh_blue
			led_on mesh_yellow
		fi
		;;
	wifi)
		if iwinfo | grep ESSID | grep -vq 'ESSID: unknown'; then
			led_on wifi_blue
		else
			led_off wifi_blue
		fi
		;;
	init)
		for i in $GW_STATE $FA_STATE; do
			[ ! -e "$i" ] && touch $i
		done
		check_net

		# Check for factory (no/expired cert)
		CERT=/etc/ucentral/cert.pem
		openssl x509 -checkend 0 -noout -in $CERT >/dev/null 2>&1 && FACTORY=0 || FACTORY=1
		if [ $FACTORY -eq 1 ]; then
			echo $FACTORY > $FA_STATE
			led_state factory
			led_state wifi
		else
			if [ -e "$FA_STATE" ] && [ $(cat "$FA_STATE") -eq 1 ]; then
				for i in $factory_leds; do
					led_off $i
				done
			fi
			echo $FACTORY > $FA_STATE
		fi

		# Check gateway status
		if [ $FACTORY -eq 0 ] && [ -f "$GW_STATE" ]; then
			led_state internet
			led_state gateway
			led_state mesh
		fi

		# Check if wifi ssid broadcasting
		led_state wifi
		;;
esac
}

