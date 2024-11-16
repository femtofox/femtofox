sudo mount -t tmpfs tmpfs /run -o remount,size=32M,nosuid,noexec,relatime,mode=755   #Embiggen tmpfs - prevents problems.
sudo sh -c 'echo "tmpfs /run tmpfs size=32M,nosuid,noexec,relatime,mode=755 0 0" >> /etc/fstab'   #Embiggen tmpfs - for future boots.
echo "\n[1;32m*** Enlarged tmpfs ***\e[0m\n"

sudo timedatectl set-timezone UTC   #Set timezone to UTC.
date -d "$(wget --method=HEAD -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f4-10)"   #Set time/date.
echo "\n[1;32m*** Changed timezone to UTC and got network time ***\e[0m\n"

#update system and install dependencies
echo "\n[1;32m*** Updating and upgrading Ubuntu... ***\e[0m\n"
sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y update && sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y upgrade
echo "\n[1;32m*** Ubuntu upgrade / update complete ***\e[0m\n"
echo "\n[1;32m*** Installing necessary packages... ***\e[0m\n"
sudo apt-get install linux-firmware wireless-tools git python3.10-venv libgpiod-dev libyaml-cpp-dev libbluetooth-dev openssl libssl-dev libulfius-dev liborcania-dev -y
echo "\n[1;32m*** Necessary packages installed ***\e[0m\n"
echo "\n[1;32m*** Installing pip packages... ***\e[0m\n"
pip3 install pytap2 meshtastic pypubsub
echo "\n[1;32m*** Pip packages installed ***\e[0m\n"

#get latest meshtasticd beta
echo "\n[1;32m*** Getting latest Meshtasticd beta... ***\e[0m\n"
URL=$(wget -qO- https://api.github.com/repos/meshtastic/firmware/releases/latest | grep -oP '"browser_download_url": "\K[^"]*armhf\.deb' | head -n 1); FILENAME=$(basename $URL); wget -O /tmp/$FILENAME $URL && sudo apt install /tmp/$FILENAME -y && sudo rm /tmp/$FILENAME
echo "\n[1;32m*** Installed latest Meshtasticd beta ***\e[0m\n"

echo "\n[1;32m*** Getting custom FemtoFox files... ***\e[0m\n"
sudo cp ../liborcania_2.3_armhf/* /usr/lib/arm-linux-gnueabihf/
sudo mv /etc/meshtasticd/config.yaml /etc/meshtasticd/config.yaml.bak
sudo cp ../meshtasticd/config.yaml /etc/meshtasticd/
sudo cp /etc/update-motd.d/00-header /etc/update-motd.d/00-header.bak
sudo mv 00-header /etc/update-motd.d/
sudo chmod +x /etc/update-motd.d/00-header
sudo mv /etc/update-motd.d/10-help-text /etc/update-motd.d/10-help-text.bak
sudo mv /etc/update-motd.d/60-unminimize /etc/update-motd.d/60-unminimize.bak
echo "\n[1;32m*** Copied custom FemtoFox files ***\e[0m\n"

#serial port permissions
sudo usermod -a -G tty $USER
sudo usermod -a -G dialout $USER
echo "\n[1;32m*** Set serial port permissions ***\e[0m\n"

#disable redundant services
echo "\n[1;32m*** Disabling redundant services... ***\e[0m\n"
sudo systemctl disable vsftpd.service
sudo systemctl disable ModemManager.service
sudo systemctl disable polkit.service
sudo systemctl disable getty@tty1.service
sudo systemctl disable alsa-restore.service
echo "\n[1;32m*** Disabled redundant services ***\e[0m\n"

#change luckfox system config
echo "\n[1;32m*** Changing Luckfox system config ***\e[0m\n"
sudo mv luckfox.cfg /etc/
sudo luckfox-config load
echo "\n[1;32m*** Set Luckfox system config ***\e[0m\n"

sudo hostname femtofox
echo "\n[1;32m*** Set hostname to femtofox ***\e[0m\n"

#edit /etc/network/interfaces
sudo chmod +x networkinterfaces.sh
sudo ./networkinterfaces.sh

#replace /etc/rc.local
sudo cp /etc/rc.local /etc/rc.local.bak
sudo cp ./rc.local /etc/rc.local
sudo chmod +x /etc/rc.local
echo "\n[1;32m*** Replaced /etc/rc.local ***\e[0m\n"

#replace /etc/issue
sudo cp /etc/issue /etc/issue.bak
sudo cp ./issue /etc/issue
echo "\n[1;32m*** Replaced /etc/issue ***\e[0m\n"

#add daily reboot to cron
echo -e "# reboot pi every 7. Default timezone is GMT. To change timezone run \`sudo tzselect\`\n0 6 * * * /sbin/reboot\n\n# restart bbs server script every odd hour\n#0 23/2 * * * sudo systemctl restart mesh-bbs.service" | sudo tee -a /var/spool/cron/crontabs/root > /dev/null
echo "\n[1;32m*** Scheduled daily reboot at 06:00 UTC ***\e[0m\n"

#wifi support
echo "\n[1;32m*** Adding wifi support... ***\e[0m\n"
sudo mkdir /lib/modules
sudo mkdir /lib/modules/5.10.160
sudo find /oem/usr/ko/ -name '*.ko' ! -name 'ipv6.ko' -exec cp {} /lib/modules/5.10.160/ \;
sudo touch /lib/modules/5.10.160/modules.order
sudo touch /lib/modules/5.10.160/modules.builtin
sudo depmod -a 5.10.160
ead -p "Enter your SSID: " SSID
read -sp "Enter your password: " PASSWORD
# Append to wpa_supplicant.conf
sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null <<EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US # Change to your country code
network={
    ssid="$SSID"
    psk="$PASSWORD"
    key_mgmt=WPA-PSK
}
EOF
echo 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?", ATTR{type}=="1", KERNEL=="wl*", NAME="wlan%n"' | sudo tee /etc/udev/rules.d/70-network.rules > /dev/null
sudo ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager
echo "\n[1;32m*** Added wifi support ***\e[0m\n"

sudo rm -rf ~/femtofox
echo "\n[1;32m*** Cleaning up... ***\e[0m\n"

echo "\n[1;32m*** Configuration complete, rebooting... ***\e[0m\n"

sudo sleep 5 && sudo reboot