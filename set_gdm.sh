#! /bin/bash
#
#


if [ "$DBUS_SESSION_BUS_ADDRESS" != "" ]
then
NEW_BUS=false
else
`dbus-launch | sed "s/^/export /"`
NEW_BUS=true
fi

parameter_name=""
parameter_value=""

function print_help {
	echo "	using :"
	echo "	set_gdm.sh -n {name} -v {value}, to set a gdm3 parameter "
	echo "	or	set_gdm.sh -h, to print this the help"
}

echo ""
while getopts "v:n:h" opt; do
	case $opt in
		n)
			parameter_name=$OPTARG
			;;
		v)
			parameter_value=$OPTARG
			;;
		h)
			print_help
			exit
			;;
		\?)
			print_help
			exit
			;;
	esac
done

can_be_empty () {
	case $parameter_name in
		WALLPAPER|SHELL_LOGO|BANNER_TEXT)
			return 0;;
		*)
			return 1;;
	esac
}

if [ -z "$parameter_name" ]
then
	echo name can not be empty
else
	if [ -z "$parameter_value" ] && ! can_be_empty
	then
		echo value can not be empty
	else

		case $parameter_name in
			GTK_THEME)
				echo "$parameter_name = $parameter_value"
				gsettings set org.gnome.desktop.interface gtk-theme "$parameter_value"
				;;
			FONT)
				echo "$parameter_name = $parameter_value"
				gsettings set org.gnome.desktop.interface font-name "$parameter_value"
				;;
			ICON_THEME)
				echo "$parameter_name = $parameter_value"
				gsettings set org.gnome.desktop.interface icon-theme "$parameter_value"
				;;
			CURSOR_THEME)
				echo "$parameter_name = $parameter_value"
				gsettings set org.gnome.desktop.interface cursor-theme "$parameter_value"
				gconftool-2 --type string --set /desktop/gnome/peripherals/mouse/cursor_theme "$parameter_value"
				;;
			WALLPAPER)
				echo "$parameter_name = $parameter_value"
				gsettings set org.gnome.desktop.background picture-uri "'file://"$parameter_value"'"
				;;
			LOGO_ICON)
				echo "$parameter_name = $parameter_value"
				gconftool-2 --type string --set /apps/gdm/simple-greeter/logo_icon_name "$parameter_value"
				;;
			FALLBACK_LOGO)
				echo "$parameter_name = $parameter_value"
				gsettings set org.gnome.login-screen fallback-logo "$parameter_value"
				;;
			SHELL_LOGO)
				echo "$parameter_name = $parameter_value"
				gsettings set org.gnome.login-screen logo "$parameter_value"
				;;
			USER_LIST)
				echo "$parameter_name = $parameter_value"
				gconftool-2 --type bool --set /apps/gdm/simple-greeter/disable_user_list $parameter_value
				gsettings set org.gnome.login-screen disable-user-list $parameter_value
				;;
			MENU_BTN)
				echo "$parameter_name = $parameter_value"
				gconftool-2 --type bool --set /apps/gdm/simple-greeter/disable_restart_buttons $parameter_value
				gsettings set org.gnome.login-screen disable-restart-buttons $parameter_value
				;;
			BANNER)
				echo "$parameter_name = $parameter_value"
				gconftool-2 --type bool --set /apps/gdm/simple-greeter/banner_message_enable $parameter_value
				gsettings set org.gnome.login-screen banner-message-enable $parameter_value
				;;
			BANNER_TEXT)
				echo "$parameter_name = $parameter_value"
				gconftool-2 --type string --set /apps/gdm/simple-greeter/banner_message_text "$parameter_value"
				gconftool-2 --type string --set /apps/gdm/simple-greeter/banner_message_text_nochooser "$parameter_value"
				gsettings set org.gnome.login-screen banner-message-text $parameter_value
				;;
			CLOCK_DATE)
				echo "$parameter_name = $parameter_value"
				gsettings set org.gnome.shell.clock show-date "$parameter_value"
				gsettings set org.gnome.desktop.interface clock-show-date "$parameter_value"
				;;
			CLOCK_SECONDS)
				echo "$parameter_name = $parameter_value"
				gsettings set org.gnome.shell.clock show-seconds "$parameter_value"
				gsettings set org.gnome.desktop.interface clock-show-seconds  "$parameter_value"
				;;
			*)
				echo "Uknown GDM3 Parameter !"
				;;
		esac
	fi
fi

if $NEW_BUS 
then
kill -SIGTERM $DBUS_SESSION_BUS_PID
fi
