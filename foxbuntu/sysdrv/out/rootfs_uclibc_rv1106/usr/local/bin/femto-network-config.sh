#!/bin/bash
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root. Try \`sudo femto-wifi-config\`."
  exit 1
fi

wpa_supplicant_conf="/etc/wpa_supplicant/wpa_supplicant.conf"
help=$(cat <<EOF
Options are:
-h             This message
-x "up"        Set wifi state (options are "up" or "down")
-T             Toggle wifi state
-s "SSID"      Set Wi-Fi SSID
-p "PSK"       Set Wi-Fi PSK (password)
-c "COUNTRY"   Set Wi-Fi 2-letter country code (such as US, DE)
-r             Restart Wi-Fi
-e             Get ethernet settings
-i             Get IPv4 addresses
-w             Get Wi-Fi settings
-n "HOSTNAME"  Change hostname
-t             Test internet connection

To set Wi-Fi settings, use -r as last argument to trigger reset after wpa_supplicant.conf is modified.
EOF
)

# Initialize variables
verbose="false"
updated_wifi="false"
ssid=""
psk=""
country=""

if [ $# -eq 0 ]; then
  echo "No arguments provided."
  echo -e "$help"
  exit 1
fi

# Parse options
while getopts ":hx:Ts:p:c:eiwn:tr" opt; do
  case ${opt} in
    h) # Option -h (help)
      echo -e "$help"
      ;;
    x) # Option -x (set wifi state)
      if [ $OPTARG = "up" ]; then
        logger "Setting wifi to up"
        ip link set wlan0 up
      elif [ $OPTARG = "down" ]; then
        logger "Setting wifi to up"
        ip link set wlan0 down
      fi
      ;;
    T) # Option -T (toggle wifi state)
      if [ "$(cat /etc/wifi_state.txt)" == "up" ]; then
        logger "Toggling wifi off"
        femto-network-config.sh -x "up"
      else
        logger "Toggling wifi on"
        femto-network-config.sh -x "down"
      fi
      ;;
    s) # Option -s (ssid)
      sed -i "/ssid=/s/\".*\"/\"$OPTARG\"/" "$wpa_supplicant_conf"
      echo "Setting SSID to $OPTARG."
      updated_wifi="true"
      ;;
    p)  # Option -p (psk)
      sed -i "/psk=/s/\".*\"/\"$(echo "$OPTARG" | sed 's/&/\\&/g')\"/" "$wpa_supplicant_conf"
      echo "Setting PSK to (hidden)."
      updated_wifi="true"
      ;;
    c) # Option -c (country)
      sed -i "/country=/s/=[^ ]*/=$OPTARG/" "/etc/wpa_supplicant/wpa_supplicant.conf"
      echo "Setting country to $OPTARG."
      updated_wifi="true"
      ;;
    e) # Option -e (ethernet settings)
status=$(ip link show eth0 | grep -o 'state [A-Za-z]*' | awk '{print $2}')
echo -e "\
Eth status:$([ "$status" == "UP" ] && echo -e "\033[4m\033[0;34mconnected\033[0m" || echo -e "\033[0;31mdisconnected\033[0m")"
if [ "$status" == "UP" ]; then
  echo -e "\
IPv4 Address:$(ifconfig eth0 | grep 'inet ' | awk '{print $2}')
IPv6 Address:$(ifconfig eth0 | grep 'inet6 ' | awk '{print $2}')"
fi
echo -e "\
MAC Address:$(ifconfig eth0 | grep 'ether ' | awk '{print $2}')\n\
Hostname:$(hostname).local"
      ;;
    w) # Option -w (wifi settings)
    wifi_settings="\
SSID:$(grep -m 1 '^\s*ssid=' "$wpa_supplicant_conf" | cut -d '"' -f 2)\n\
Password:(hidden)\n\
Country:$(grep -m 1 "^country=" "$wpa_supplicant_conf" | cut -d '=' -f 2)"

      if ip link show wlan0 2>/dev/null | grep -q "wlan0"; then
        mac_address_line="\
MAC address:$(ifconfig wlan0 | grep ether | awk '{print $2}')"
        if [ "$(cat /etc/wifi_state.txt)" = "up" ]; then
            echo -e "\
Wi-Fi status:\033[4m\033[0;34menabled\033[0m\n\
Connected to:$(iwconfig 2>/dev/null | grep -i 'ESSID' | awk -F 'ESSID:"' '{print $2}' | awk -F '"' '{print $1}' | sed 's/^$/none/')\n\
Sig. strength:$(iwconfig 2>/dev/null | grep -i 'Signal level' | awk -F 'Signal level=' '{print $2}' | awk '{print $1}')\n\
Current IP:$(ip addr show wlan0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)\n
Hostname:$(hostname).local\n\
$mac_address_line"
        else
          if ip link show wlan0 &>/dev/null; then # if wlan0 exists
            echo -e "\
Wi-Fi status:\033[0;31mdisabled\033[0m\n\
\n\
$wifi_settings"
          fi
        fi
      else
        echo -e "\
Wi-Fi status:\033[0;31mwlan0 not detected\033[0m\n\
\n\
$wifi_settings"
      fi
      ;;
    i) # Option -i (Get all IPv4 addresses)
      hostname -I | awk '{for(i=1; i<=NF; i++) {if(i>1) printf ", "; printf $i} print ""}'
      ;;
    t) # Option -t (test internet connection)
      # Define ping targets and initialize counter
      targets=("1.1.1.1" "8.8.8.8")
      successful=0
      count=0
      total=0
      # Ping each target 5 times and count successful pings
      for target in "${targets[@]}"; do
        count=$(ping -c 5 -W 1 "$target" | grep -c 'time') # Count lines with successful pings
        successful=$((successful + count))
        ((total+=5))
      done
      # Use dialog to display message based on successful pings count
      if [ "$successful" -eq 0 ]; then
        echo -e "\033[0;31mNo internet connection detected.\033[0m"
      else
        echo -e "Internet connection is \033[4m\033[0;34mup\033[0m.\n\nPinged $(echo "${targets[*]}" | sed 's/ /, /g').\nReceived $successful/$total responses."
      fi
      ;;
    r) # Option -r (restart Wi-Fi)
      updated_wifi="true"
      ;;
    n) # Option -n (set hostname)
      old_hostname=$(hostname)
      sed -i "s/$(hostname)/$OPTARG/g" /etc/hosts
      hostnamectl set-hostname "$OPTARG"
      systemctl restart avahi-daemon
      echo "Regenerating web terminal ssl keys..."
      [ "$OPTARG" != "$old_hostname" ] && /usr/local/bin/packages/ttyd.sh -k
      ;;
    \?)  # Invalid option)
      echo "Invalid option: -$OPTARG"
      echo -e "$help"
      exit 1
      ;;
    :) # Missing argument for option)
      echo "Option -$OPTARG requires a setting."
      echo -e "$help"
      exit 1
      ;;
  esac
done

if [ "$updated_wifi" = true ]; then
  ip link set wlan0 up
  #systemctl restart wpa_supplicant
  wpa_cli -i wlan0 reconfigure # <-------- add watch for FAIL response, error out
  #timeout 30s dhclient -v
fi
