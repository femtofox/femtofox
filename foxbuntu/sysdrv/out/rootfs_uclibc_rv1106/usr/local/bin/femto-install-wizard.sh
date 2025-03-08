#!/bin/bash
export NCURSES_NO_UTF8_ACS=1
export TERM=xterm-256color
export LANG=C.UTF-8

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  echo "Try \`sudo femto-install-wizard\`."
  exit 1
fi

loading() {
  dialog --no-collapse --infobox "$1" 5 45
}

title="Install Wizard"

wizard() {

  femto-set-time.sh

  new_hostname=$(dialog --title "Hostname" --cancel-label "Skip" --inputbox "Enter hostname:" 8 40 $(hostname) 3>&1 1>&2 2>&3)
  if [ $? -eq 0 ]; then #unless cancel/no
    femto-network-config.sh -n "$new_hostname"
    dialog --title "Hostname" --msgbox "\nFemtofox is now reachable at\n$new_hostname.local" 8 40
  fi

  dialog --title "$title" --yesno "Configure Wi-Fi settings?" 6 40
  if [ $? -eq 0 ]; then #unless cancel/no
    femto-config -w
  fi

  dialog --title "$title" --yesno "Configure Meshtastic?" 6 40
  if [ $? -eq 0 ]; then #unless cancel/no
    if femto-config -c; then
      while true; do
        meshtastic_menu_choice=$(dialog --no-collapse --colors --cancel-label "Continue" --default-item "$meshtastic_menu_choice" --title "Meshtastic Configuration" --item-help --menu "Currently configured LoRa radio:\n$(femto-utils.sh -R "$(femto-meshtasticd-config.sh -k)")" 16 40 5 \
          1 "Set LoRa radio model" "" \
          2 "Set configuration URL" "" \
          3 "Set private key" "" \
          4 "Set public key" "" \
          " " "" "" \
          5 "Full Meshtastic settings menu" "" \
          " " "" "" \
          6 "Continue" "" 3>&1 1>&2 2>&3)
        [ $? -eq 1 ] && break # Exit the loop if the user selects "Cancel" or closes the dialog
          case $meshtastic_menu_choice in
            1) # Set LoRa radio model)
              femto-config -l
            ;;
            2) # Configure automatically with URL)
              femto-config -c && (
                femto-config -u
              )
            ;;
            3) # view/change private key)
              femto-config -c && (
                key=$(dialog --no-collapse --colors --title "Meshtastic Private Key" --cancel-label "Cancel" --inputbox "The private key of the device, used to create a shared key with a remote device for secure communication.\n\n\Z1This key should be kept confidential.\nSetting an invalid key will lead to unexpected behaviors.\Zn\n\nPrivate key  (default: random)" 15 60 3>&1 1>&2 2>&3)
                if [ $? -eq 0 ] && [[ -n "$key" ]]; then #unless cancel/no
                  loading "Sending command..."
                  dialog --no-collapse --colors --title "Meshtastic Private Key" --msgbox "$(femto-meshtasticd-config.sh -R "$key" && echo -e "\n\Z4Command successful!\Zn\n" || echo -e "\n\Z1Command failed.\Zn\n")" 0 0
                fi
              )
            ;;
            4) # view/change public key)
              femto-config -c && (
                key=$(dialog --no-collapse --colors --title "Meshtastic Public Key" --cancel-label "Cancel" --inputbox "The public key of the device, shared with other nodes on the mesh to allow them to compute a shared secret key for secure communication.\n\n\ZuGenerated automatically\Zn to match private key.\n\n\Z1Don't change this if you don't know what you're doing.\Zn\n\nPublic key  (default: generated from private key)" 16 60 3>&1 1>&2 2>&3)
                if [ $? -eq 0 ] && [[ -n "$key" ]]; then #unless cancel/no
                  loading "Sending command..."
                  dialog --no-collapse --colors --title "Meshtastic Public Key" --msgbox "$(femto-meshtasticd-config.sh -U "$key" && echo -e "\n\Z4Command successful!\Zn\n" || echo -e "\n\Z1Command failed.\Zn\n")" 0 0
                fi
              )
            ;;
            5) # Full Meshtastic settings menu)
              femto-config -c && (
                dialog --no-collapse --infobox "Loading Meshtastic settings menu...\n\nStopping conflicting services, will restart after exit...\n\nThis can take up to a minute." 9 50
                femto-utils.sh -A stop
                python /opt/control/main.py --host
                femto-utils.sh -A start
              )
            ;;
            6) # return to previous menu)
              break
            ;;            
          esac
      done
    fi
  fi

  dialog --title "$title" --msgbox "Setup wizard complete!" 6 40
}

dialog --title "$title" --yesno "\
The install wizard will allow you to configure all the settings necessary to run your Femtofox.\n\
\n\
The wizard takes several minutes to complete and will overwrite some current settings.\n\n\
Proceed?" 12 60
if [ $? -eq 0 ]; then #unless cancel/no
  wizard
fi