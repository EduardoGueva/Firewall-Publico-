#! /bin/sh
#para poder demonizar este archivo se tienes que copiar el archivo a /etc/init.d y darle permisos de jecucion con 
#chmod  +x /etec/init.d/montajedemonizado.sh y despues asignarle los runlevels con el comando  
# sudo update-rc.d montajedemonizdo default y reiniciar el equipo
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="montaje demonizado"
NAME=montajed
DAEMON=/usr/sbin/$NAME

PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME


[ -x "$DAEMON" ] || exit 0


[ -r /etc/default/$NAME ] && . /etc/default/$NAME


. /lib/init/vars.sh


. /lib/lsb/init-functions

do_start()
{

	start-stop-daemon --start --quiet --make-pidfile --pidfile $PIDFILE --exec $DAEMON --test > /dev/null \
		|| return 1
	start-stop-daemon --start --quiet --make-pidfile --pidfile $PIDFILE --exec $DAEMON --
		|| return 2


while [ $CONTROL=0 ] ; do
	cat /etc/mtab | grep media >> /dev/null
	if [ $? -ne 0 ]; then
		CONTROL=0
	else
		CONTROL=1
		for USBDEV in `df | grep media | awk -F / {'print $5'}` ;
		do
			USBSIZE=`df | grep $USBDEV | awk {'print $2'}`
			USBSER=`df | grep media | awk -F / {'print $3'} `
			if [ $USBSIZE -lt 15664800 ]; then
				USBNAME=`echo $USBDEV | awk -F / {'print $3'}`
				if [ -d /media/usb1/ ]; then
				echo " "
				else
				mkdir /media/usb1
				fi


				sleep 5s
				opc=0

				lb=`grep -c "$USBSER" blanco.txt`
				ln=`grep -c "$USBSER" negra.txt`

				if [ $lb -ne 0 ]; then
				opc=1
				fi

				if [ $ln -ne 0 ]; then
				opc=3
				fi

				if [ $opc -eq 0 ];then
				opc=$(zenity --width=320 --height=230 --title=Firewall --entry --text=" USB detectada, selecciona una opcion
		1)Montar
		2)Montar y agregar a lista blanca
		3)Desmontar
		4)Desmontar y agregar a lista negra"
					)
				fi

				case $opc in
				"1") echo "Montando USB"
				mount -t vfat /dev/sda1 /media/usb1
				sleep 2s
				zenity --notification --text="USB montada"
				exit 0
				;;
				"2") echo $USBSER >> blanco.txt
				echo "Montando USB"
				mount -t vfat /dev/sda1 /media/usb1
				zenity --notification --text="USB montada y guardada en lista blanca"
				sleep 2s
				exit 0
				;;
				"3") umount /media/usb1/
				zenity --notification --text="USB desmontada"
				exit 0
				;;
				"4") echo $USBSER >> negra.txt
				umount /media/usba1/
				zenity --notification --text="USB desmontada y guardada en lista negra"
				exit 0
				;;
				esac
			fi
		done
	fi
	sleep 1

done

}


do_stop()
{

	start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --pidfile $PIDFILE --name $NAME
	RETVAL="$?"
	[ "$RETVAL" = 2 ] && return 2

	start-stop-daemon --stop --quiet --oknodo --retry=0/30/KILL/5 --exec $DAEMON
	[ "$?" = 2 ] && return 2

	rm -f $PIDFILE
	return "$RETVAL"
}


do_reload() {

	start-stop-daemon --stop --signal 1 --quiet --pidfile $PIDFILE --name $NAME
	return 0
}

case "$1" in
  start)
	[ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
	do_start
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  stop)
	[ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
	do_stop
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  status)
	status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
	;;

  restart|force-reload)

	log_daemon_msg "Restarting $DESC" "$NAME"
	do_stop
	case "$?" in
	  0|1)
		do_start
		case "$?" in
			0) log_end_msg 0 ;;
			1) log_end_msg 1 ;;
			*) log_end_msg 1 ;;
		esac
		;;
	  *)

		log_end_msg 1
		;;
	esac
	;;
  *)

	echo "Usage: $SCRIPTNAME {start|stop|status|restart|force-reload}" >&2
	exit 3
	;;
esac
exit 0
