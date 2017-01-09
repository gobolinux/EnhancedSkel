xsetroot -solid '#000000' -cursor_name 'left_ptr'

# Load user preferences
[ -e ~/.Xresources ] && xrdb -merge ~/.Xresources

# Update the MIME database
[ -e /bin/update-mime-database ] && \
    update-mime-database /Data/Variable/xdg/mime & &> /dev/null

[ -x /bin/awesome ] && {
   [ -x /bin/compton ] && {
      compton -bcf \
         --fade-delta 5 \
         --shadow-radius 11 \
         --shadow-green 1.0 \
         --shadow-blue 1.0 \
         --no-dock-shadow \
         --clear-shadow \
         --no-dnd-shadow \
         --shadow-exclude '!focused'
   }
   exec awesome
}
[ -x /bin/enlightenment_start ] && exec dbus-launch --exit-with-session enlightenment_start
[ -x /bin/startkde ] && exec dbus-launch --exit-with-session startkde
[ -x /bin/wmaker ] && exec wmaker
[ -x /bin/twm    ] && { 
   xsetroot -solid '#203040' -cursor_name 'left_ptr'
   exec twm
}   
