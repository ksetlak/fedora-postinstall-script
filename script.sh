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
# TODO: Install slack, skype-preview, discord
# TODO: VLC & set as the default video player
# TODO: Set gthumb as the default image viewing program

if [ $EUID != 0 ]; then
    echo "You've run this script without elevated privileges and since"
    echo "it installs stuff and does a lot  of other super-userey stuff"
    echo "you have to grant it this ultimate power by typing in your password..."
    echo "... or press Ctrl-C to abort!"
    sudo "$0" "$@"
    exit $?
fi

# Start with updating everything
dnf -y upgrade

# Enable RPM Fusion
dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Enable wine repo
# dnf config-manager --add-repo https://dl.winehq.org/wine-builds/fedora/$(rpm -E %fedora)/winehq.repo
# Disabled as Fedora is current enough not to make this worth the hassle.

# Download and install Firefox Nightly
mkdir -p ~/Programs/
cd ~/Programs/
wget --show-progress --max-redirect=1 -o /dev/null -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-nightly-latest-ssl&os=linux64&lang=en-US" # -o /dev/null/ is only a workaround for wget bug #51181
tar -xf firefox.tar.bz2
echo -en "[Desktop Entry]\nName=Firefox Nightly\nExec=/home/amarok/Programs/firefox/firefox %U\nComment=\nTerminal=false\nIcon=/home/amarok/Programs/firefox/browser/chrome/icons/default/default128.png\nType=Application\n" > "Firefox Nightly.desktop"


# Install all the packages
dnf -y install gnome-power-manager transmission x264 fuse-exfat exfat-utils snapd dnfdragora
dnf -y groupupdate core # To install Appstream Metadata (package name: appstream-data)
dnf -y groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
dnf -y groupupdate sound-and-video\
Disabled packages:
# alacarte - for editing desktop entries in the app menu

# Enable snap classic confinement
ln -s /var/lib/snapd/snap /snap

# Install Spotify
snap install spotify

# Set favorite apps
gsettings set org.gnome.shell favorite-apps "['Firefox Nightly.desktop', 'org.gnome.Nautilus.desktop']"
#  TODO: Window controls and other stuff normally set using tweaks
#  TOOD: Unmap Ctrl+Alt+↑, Ctrl+Alt+↓ from switching workspaces; it's already done using Super+PgUp, Super+PgDn and we need Ctrl+Alt+↑, Ctrl+Alt+↓ for Atom cursor cloning
#  TODO: Nautilus settings

echo "ALL SET!"
echo
echo "Your fresh Fedora install is now customized to your liking and ready to rock!"
echo "Now, there are a few things you have to do manually. See the list below!"
echo
echo "1. Reboot to fully enable snap support"
echo "2. Log in to Firefox Sync"

line_containing_wget_bug_status=$(curl https://savannah.gnu.org/bugs/?51181 | grep "Most basic status of the item: is the item considered as dealt with or not." -A1 | tail -n1)
if [[ "$line_containing_wget_bug_status" == *"Closed"* ]]; then
  echo "By the way, bug #51181 in wget is marked as \"Closed\". This means you can probably modify the script wherever it uses wget, so go check it out at https://savannah.gnu.org/bugs/?51181"
fi


read -n 1 -r -s -p $'OK, we\'re done. Press any key to exit.\n'
