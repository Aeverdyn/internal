#!/bin/sh

. /opt/muos/script/var/func.sh

# hotkey.sh will restart it
killall muhotkey

C_BRIGHT="$(cat /opt/muos/config/brightness.txt)"
if [ "$C_BRIGHT" -lt 1 ]; then
	/opt/muos/device/current/input/combo/bright.sh U
else
	/opt/muos/device/current/input/combo/bright.sh "$C_BRIGHT"
fi

GET_VAR "global" "settings/general/colour" >/sys/class/disp/disp/attr/color_temperature

if [ "$(GET_VAR "global" "settings/general/hdmi")" -gt -1 ]; then
	killall hdmi_start.sh
	/opt/muos/device/current/script/hdmi_stop.sh
	if [ "$(GET_VAR "device" "board/hdmi")" -eq 1 ]; then
		/opt/muos/device/current/script/hdmi_start.sh &
	fi
else
	if pgrep -f "hdmi_start.sh" >/dev/null; then
		killall hdmi_start.sh
		/opt/muos/device/current/script/hdmi_stop.sh
	fi
fi

/opt/muos/script/system/usb.sh &

# Set the device specific SDL Controller Map
/opt/muos/script/mux/sdl_map.sh &

# Check to see if BGM is playing, if it is and we've disabled it, kill the script and any mpv processes
NEW_BGM_TYPE=$(GET_VAR "global" "settings/general/bgm")
OLD_BGM_TYPE=$(cat "/tmp/bgm_type" 2>/dev/null || echo 0)

printf "%s" "$NEW_BGM_TYPE" >"/tmp/bgm_type"

if [ $NEW_BGM_TYPE -eq 0 ]; then
	killall "playbgm.sh" "mpv"
else
	if [ $NEW_BGM_TYPE -ne $OLD_BGM_TYPE ]; then
		killall "playbgm.sh" "mpv"
		wait
	fi
	if ! pgrep "playbgm.sh" >/dev/null || ! pgrep "mpv" >/dev/null; then
		/opt/muos/script/mux/playbgm.sh &
	fi
fi
