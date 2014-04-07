# Workaround for broken input device detection
[ -e /bin/udevadm ] && udevadm trigger
# Update the MIME database
[ -e /bin/update-mime-database ] && \
    update-mime-database /Data/Variable/xdg/mime | grep -v Unknown

[ -x /bin/startkde ] && exec dbus-launch --exit-with-session startkde
[ -x /bin/wmaker ] && exec wmaker
[ -x /bin/twm    ] && { 
   xsetroot -solid '#203040' -cursor_name 'left_ptr'
   exec twm
}   
