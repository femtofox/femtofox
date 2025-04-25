#!/bin/bash

### For package maintainer:
# Fill the following fields and choose the options that are in use by this package
# Populate the install, uninstall and upgrade functions
# Remember that this script may be launched in terminal, via web UI or another method, so inputs aren't always possible
# This system supports both interactive and non-interactive installs. For non-interactive installs, $interactive="false". In this cause special instructions to the user should be given as user_message, such as `After installation, edit /opt/software/config.ini`
# Successful operations should `exit 0`, fails should `exit 1`
# Messages to the user (such as configuration instructions, explanatory error messages, etc) should be given as: `echo "user_message: text"`
# Everything following `user_message: ` will be displayed prominently to the user, so it must the last thing echoed

name="Contact"   # software name
author="pdxlocations"   # software author - OPTIONAL
description="A Text-Based Console UI for Meshtastic Nodes. Formerly called Curses Client.\nAfter install, run \`contact\` to launch."   # software description - OPTIONAL (but strongly recommended!)
URL="https://pypi.org/project/contact/"   # software URL. Can contain multiple URLs - OPTIONAL
options="xiuglNADUOLGTCI"   # script options in use by software package. For example, for a package with no service, exclude `edsrS`
launch="echo \"Stopping conflicting services (if any), will restart after exit...\" && sudo femto-utils.sh -A stop && sudo -u ${SUDO_USER:-$(whoami)} env LANG=$LANG TERM=$TERM NCURSES_NO_UTF8_ACS=$NCURSES_NO_UTF8_ACS python /opt/contact/main.py --host && echo \"Restarting conflicting services (if any)...\" && sudo femto-utils.sh -A start"   # command to launch software, if applicable
service_name=""   # the name of the service/s, such as `chrony`. REQUIRED if service options are in use. If multiple services, separate by spaces "service1 service2"
license_name="GPL3"             # license name, such as MIT, GPL3, custom, whatever. short text string.
conflicts="\"Full control\" Meshtastic software, such as TC²-BBS and Meshing Around - but only while running."   # comma delineated plain-text list of packages with which this package conflicts. Blank if none. Use the name as it appears in the $name field of the other package. Extra plaintext is allowed, such as "packageA, packageB, any other software that uses the Meshtastic CLI"


if [ $# -eq 0 ]; then
  echo "No arguments provided."
  echo -e "$help"
  exit 1
fi


# install script
install() {
  pipx install --global contact
}

# uninstall script
uninstall() {
  pipx uninstall --global contact
}

#upgrade script
upgrade() {
  pipx upgrade --global contact
}

# Check if already installed. `exit 0` if yes, `exit 1` if no
check() {
  pipx list --global --short | grep contact
}

# display license
license() {
  echo "GNU General Public License v3.0"
}

# parse arguments
source /usr/local/bin/packages/femto_argument_parse.sh "$@"

exit 0