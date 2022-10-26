#!/bin/sh
function run {
   if (command -v $1 && ! pgrep $1); then
     $@&
   fi
}

## run (only once) processes which spawn with different name
if (command -v gnome-keyring-daemon && ! pgrep gnome-keyring-d); then
    gnome-keyring-daemon --daemonize --login &
fi
if (command -v /usr/lib/mate-polkit/polkit-mate-authentication-agent-1 && ! pgrep polkit-mate-aut) ; then
    /usr/lib/mate-polkit/polkit-mate-authentication-agent-1 &
fi
if (command -v  xfce4-power-manager && ! pgrep xfce4-power-man) ; then
    xfce4-power-manager &
fi
# System-config-printer-applet is not installed in minimal edition
if (command -v system-config-printer-applet && ! pgrep applet.py ); then
  system-config-printer-applet &
fi

run xcape -e 'Super_L=Super_L|Control_L|Escape'
run pa-applet
run blueman-applet
run telegram-desktop
run redshift-gtk -l 60.0:30.3 -m vidmode -t 6500:5500
run discord
run kdeconnect-indicator
if (command -v picom && ! pgrep picom); then
    picom -b &
fi
if (command -v signal-desktop && ! pgrep signal-desktop); then
    signal-desktop --use-tray-icon &
fi
run deluge &
sleep 1
dex --environment Awesome --autostart --search-paths "$XDG_CONFIG_DIRS/autostart:$XDG_CONFIG_HOME/autostart"
#xscreensaver-command -lock &
#dm-tool lock
