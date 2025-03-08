#!/bin/bash
### For package maintainer:
# Fill the following fields and choose the options that are in use by this package
# Populate the install, uninstall and upgrade functions
# Remember that this script may be launched in terminal, via web UI or another method, so inputs aren't always possible
# This system supports both interactive and non-interactive installs. For non-interactive installs, $interaction="false". In this cause special instructions to the user should be given as user_message, such as `After installation, edit /opt/software/config.ini`
# Successful operations should `exit 0`, fails should `exit 1`
# Messages to the user (such as configuration instructions, explanatory error messages, etc) should be given as: `echo "user_message: text"`
# Everything following `user_message: ` will be displayed prominently to the user, so it must the last thing echoed

name="Control for Meshtastic"   # software name
author="pdxlocations"   # software author - OPTIONAL
description="Control for Meshtastic is a fully-featured Meshtastic configuration tool made for running in console, utilizing Curses.\n\nControl is installed by default on Femtofox and is used for Meshtastic configuration in femto-config. Uninstallation is not recommended."       # software description - OPTIONAL (but strongly recommended!)
URL="https://github.com/pdxlocations/control"                       # software URL. Can contain multiple URLs - OPTIONAL
options="hxiuglNADUOLGTIC"       # script options in use by software package. For example, for a package with no service, exclude `edsrS`
launch="echo \"Stopping conflicting services (if any), will restart after exit...\" && sudo femto-utils.sh -A stop && sudo -u ${SUDO_USER:-$(whoami)} env LANG=$LANG TERM=$TERM NCURSES_NO_UTF8_ACS=$NCURSES_NO_UTF8_ACS python /opt/control/main.py --host && echo \"Restarting conflicting services (if any)...\" && sudo femto-utils.sh -A start"   # command to launch software, if applicable
license="/opt/control/LICENSE"  # file to cat to display license
location="/opt/control"        # install location REQUIRED if not apt installed. Generally, we use `/opt/software-name`
license="$location/LICENSE"     # file to cat to display license
license_name="GPL3"             # license name, such as MIT, GPL3, custom, whatever. short text string
conflicts="\"Full control\" Meshtastic software, such as TC²-BBS and Meshing Around - but only while running."  # comma delineated plain-text list of packages with which this package conflicts. Blank if none. Use the name as it appears in the $name field of the other package. Extra plaintext is allowed, such as "packageA, packageB, any other software that uses the Meshtastic CLI"

# install script
install() {
  if ! git clone https://github.com/pdxlocations/control.git /opt/control; then
    echo "user_message: Git clone failed. Is internet connected?"
    exit 1
  fi
  pip install -r $location/requirements.txt
  chown -R femto $location #give ownership of installation directory to $user
  git config --global --add safe.directory $location # prevents git error when updating
  echo "user_message: To launch, go to Meshtastic settings. Launching manually may conflict with \`full control\` Meshtastic software such as BBS."
  exit 0 # should be `exit 1` if operation failed
}

# uninstall script
uninstall() {
  rm -rf $location
  echo "Removed \`$location\`."
  echo "user_message: All files removed."
  exit 0 # should be `exit 1` if operation failed
}

#upgrade script
upgrade() {
  cd $location
  if ! git pull; then
    echo "user_message: Git pull failed. Is internet connected?"
    exit 1
  fi
  exit 0
}

# Check if already installed. `exit 0` if yes, `exit 1` if no
check() {
  #the following works for cloned repos, but not for apt installs
  if [ -d "$location" ]; then
    #echo "Already installed"
    exit 0
  else
    #echo "Not installed"
    exit 1
  fi
}

# display license
license() {
  echo -e "Contents of $license:\n\n   $([[ -f "$license" ]] && awk -v max=2000 -v file="$license" '{ len += length($0) + 1; if (len <= max) print; else if (!cut) { cut=1; printf "%s...\n\nFile truncated, see %s for complete license.", substr($0, 1, max - len + length($0)), file; exit } }' "$license")"
}

# parse arguments
source /usr/local/bin/packages/femto_argument_parse.sh "$@"

exit 0