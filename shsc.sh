#!/bin/bash

#
#
#

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
				sudo mkdir /media/usb1 	
				fi 
				
				#sudo cp /sys/bus/usb/devices/1-1/serial /etc/usb/ 
				#cd /etc/usb/

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
				"2") sudo echo $USBSER >> blanco.txt 
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
				"4") sudo echo $USBSER >> negra.txt 
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

exit 0
