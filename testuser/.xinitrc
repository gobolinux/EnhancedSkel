# Workaround for broken input device detection
[ -e /bin/udevadm ] && udevadm trigger
# Workaround for DBus not launching udisksd and upowerd
[ -e /lib/udisks2/udisksd ] && /lib/udisks2/udisksd --no-debug &
[ -e /lib/upower/upowerd ] && /lib/upower/upowerd &
# Workaround for DBus not launching polkitd
[ -e /lib/polkit-1/polkitd ] && /lib/polkit-1/polkitd &

[ -x /bin/startkde ] && exec dbus-launch --exit-with-session startkde
[ -x /bin/wmaker ] && exec wmaker
[ -x /bin/twm    ] && { 
   xsetroot -solid '#203040' -cursor_name 'left_ptr'
   exec twm
}   
