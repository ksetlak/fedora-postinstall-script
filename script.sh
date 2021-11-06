# TODO: Error handling
# TODO: Make this script a noecho
# TODO: Progress bar with a "spinner" and "Step 5 of 16: Installing packages..."
# TODO: Codecs? (partially already there, but make sure it's an all inclusive ;) )
# TODO: Configure Transmission
# TODO: Enable software repositories (rpmfusion is done, but some other like fedora-updates)
# TODO: (Challenge ;) ) Install Pycharm automatically + configure to be the preview version + create a launcher.
# TODO: Set keyboard shortcuts
# TODO: Install Chrome unstable
# TODO: Install atom Nightly
# TODO: Configure Atom Nightly to use Ctrl+Alt+↑, Ctrl+Alt+↓ for cursor cloning
# TODO: Install skype-preview
# TODO: VLC & set as the default video player
# TODO: Set gthumb as the default image viewing program
# TODO: gsettings enable touch-to-click touchpad behavior
# TODO: Move software installed in the UNPACKAGED section to /opt
# TODO: Merge all TODOs from the separate .odt file
# TODO: System-wide install of the VT220 font (https://github.com/svofski/glasstty)
# TODO: Load CRT configuration
# TODO: Set up bash clipboard shorthands based on https://stackoverflow.com/a/27456981/5306048
# TODO: Add some gitconfig setup: email, name, default editor
# TODO: Add cool git aliases (salvage from company laptop)
# TODO: Window controls and other stuff normally set using tweaks
# TODO: Nautilus settings:
#* Diminish the size of icons by two scroll “clicks”
#* Settings:
#* Views: sort folders before files
#* Behavior: Executable text files > Ask what to do
#* Search and preview: Loosest settings possible

##############
## FOREWORD ##
##############
# All the things that should be checked and done before we start to make any changes.

if [ $EUID != 0 ]; then
    echo "You've run this script without elevated privileges and since"
    echo "it installs stuff and does a lot  of other super-userey stuff"
    echo "you have to grant it this ultimate power by typing in your password..."
    echo "... or press Ctrl-C to abort!"
    sudo "$0" "$@"
    exit $?
fi

################
## UNPACKAGED ##
################
# Section for programs installed outside of package management

mkdir -p ~/Programs
cd ~/Programs
# Firefox Nightly
wget --show-progress --max-redirect=1 -o /dev/null -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-nightly-latest-ssl&os=linux64&lang=en-US" # -o /dev/null/ is only a workaround for wget bug #51181
tar -xf firefox.tar.bz2
rm firefox.tar.bz2
echo -e "[Desktop Entry]\nName=Firefox Nightly\nExec=$HOME/Programs/firefox/firefox-bin %u\nComment=\nTerminal=false\nIcon=$HOME/Programs/firefox/browser/chrome/icons/default/default128.png\nType=Application" > "$HOME/.local/share/applications/Firefox Nightly.desktop"
cd ~/Programs
cd ~/

#########
## DNF ##
#########
# Section for everything related to package management.

# Start with updating everything
dnf -y upgrade
# Enable RPM Fusion
dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# [DISABLED] Enable wine repo
# dnf config-manager --add-repo https://dl.winehq.org/wine-builds/fedora/$(rpm -E %fedora)/winehq.repo
# Disabled as Fedora is current enough not to make this worth the hassle.
# [DISABLED] Install Skype preview
# cd ~/Downloads
# wget --show-progress -o /dev/null "https://repo.skype.com/latest/skypeforlinux-64-insider.rpm"
# dnf -y localinstall ./skypeforlinux-64-insider.rpm
# rm skypeforlinux-64-insider.rpm
# cd ~/
# Disabled as recently I'm simply not using it.
# Install all the packages
dnf -y groupupdate core # To install Appstream Metadata (package name: appstream-data)
dnf -y groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
dnf -y groupupdate sound-and-video\
dnf -y install gnome-power-manager transmission x264 fuse-exfat exfat-utils\
snapd dnfdragora paprefs pavucontrol gthumb discord slack
# Disabled packages:
# * alacarte - for editing desktop entries in the app menu. I used it mostly to
#   add the desktop entry for Firefox, but curently it generates automatically.
#   Nevertheless it's a neat little app.
# * winehq-staging - when you need your wine to be built from the most bleeding,
#   cutting edge code possible!
#   But for now - you don't.

##########
## SNAP ##
##########
# Section for everything snap-related.

# Enable snap classic confinement
ln -s /var/lib/snapd/snap /snap
# Install Spotify
snap install spotify

###################
## CONFIGURATION ##
###################
# Section for automatic configuration (gsettings, config files and such).

# Set favorite apps
gsettings set org.gnome.shell favorite-apps "['Firefox Nightly.desktop', 'org.gnome.Nautilus.desktop']"

## Atom
echo \'atom-text-editor\': > ~/.atom/keymap.cson
echo -ne \\t >> ~/.atom/keymap.cson; echo \'ctrl-alt-up\': \'editor:add-selection-above\' >> ~/.atom/keymap.cson
echo -ne \\t >> ~/.atom/keymap.cson; echo \'ctrl-alt-down\': \'editor:add-selection-below\' >> ~/.atom/keymap.cson
echo >> ~/.atom/keymap.cson


#############
## STARTUP ##
#############
# Section that configures startup jobs that manage all the quirks
# of my crappy old HP 250 G3.

# (I) Don't spin the HDD until its needed.
# Command: `hdparm -y /dev/sdb`
# Path: `/etc/systemd/system/secondary_hdd_powersave.service`

echo [Unit] >> /etc/systemd/system/secondary_hdd_powersave.service
echo Description=Spin down the secondary HDD on startup so it\'s on standby until actually needed  >> /etc/systemd/system/secondary_hdd_powersave.service
echo  >> /etc/systemd/system/secondary_hdd_powersave.service
echo [Service] >> /etc/systemd/system/secondary_hdd_powersave.service
echo ExecStart=hdparm -y /dev/sdb >> /etc/systemd/system/secondary_hdd_powersave.service
echo Type=oneshot >> /etc/systemd/system/secondary_hdd_powersave.service
echo RemainAfterExit=yes >> /etc/systemd/system/secondary_hdd_powersave.service
echo  >> /etc/systemd/system/secondary_hdd_powersave.service
echo [Install] >> /etc/systemd/system/secondary_hdd_powersave.service
echo WantedBy=multi-user.target >> /etc/systemd/system/secondary_hdd_powersave.service
echo  >> /etc/systemd/system/secondary_hdd_powersave.service

systemctl daemon-reload
systemctl enable secondary_hdd_powersave.service

# (II) Disable the PCI WiFi card


############
## FINISH ##
############
# Section for anything that may be approppriate as a part of the epilogue
# for this script.

echo "ALL SET!"
echo
echo "Your fresh Fedora install is now customized to your liking and ready to rock!"
echo "Now, there are a few things you have to do manually. See the list below!"
echo
echo "1. Reboot to fully enable snap support."
echo "2. Log in to Firefox Sync."
echo "3. Restore files from backup."

line_containing_wget_bug_status=$(curl https://savannah.gnu.org/bugs/?51181 | grep "Most basic status of the item: is the item considered as dealt with or not." -A1 | tail -n1)
if [[ "$line_containing_wget_bug_status" == *"Closed"* ]]; then
  echo "By the way, bug #51181 in wget is marked as \"Closed\". This means you can probably modify the script wherever it uses wget, so go check it out at https://savannah.gnu.org/bugs/?51181"
fi


read -n 1 -rsp $'OK, we\'re done. Press any key to exit.\n'
