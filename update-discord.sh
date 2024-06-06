#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "Please, run this file with sudo";
    exit 1;
fi

LOGFILE="/var/log/install-discord.log";
touch $LOGFILE;

if [ -f $LOGFILE ]; then
    rm $LOGFILE;
fi

CHECKLOGFILE="Run \`cat $LOGFILE\` to check the logs";
INSTALLPATH="/tmp/discord.deb";

DISCORD_OPEN=false;
FINISH_MESSAGE="Discord updated, you may open discord now.";

if [ -n "$(pidof Discord)" ]; then
    pkill -9 Discord;
    DISCORD_OPEN=true;
    FINISH_MESSAGE="Discord updated, opening..."
fi;

which curl &> /dev/null || {
    apt install curl -y &>> $LOGFILE
    if [ $? -ne 0 ]; then
        echo -e "Failed to install curl, $CHECKLOGFILE";
        exit 1;
    fi
}

ERROR=true;

echo "Updating...";

curl -L "https://discord.com/api/download/stable?platform=linux&format=deb" -o $INSTALLPATH &>> $LOGFILE;

dpkg -i $INSTALLPATH &>> $LOGFILE &&

rm -f $INSTALLPATH &&

echo $FINISH_MESSAGE && ERROR=false ||
echo "there was an error while updating discord, $CHECKLOGFILE";

if ! $ERROR && [[ "$*" == *"--install-bd"* ]]; then
    echo "Installing BetterDiscord as per user request..."

    if [ -z "$(which betterdiscordctl || : ;)" ]; then
        curl -O https://raw.githubusercontent.com/bb010g/betterdiscordctl/master/betterdiscordctl;
        chmod +x betterdiscordctl;
        sudo mv betterdiscordctl /usr/local/bin;
    fi

    sudo -u $SUDO_USER betterdiscordctl reinstall &> /dev/null ||
    sudo -u $SUDO_USER betterdiscordctl install &> /dev/null &&
    echo "BetterDiscord downloaded." ||
    echo "Error while installing BetterDiscord.";
fi

if $DISCORD_OPEN; then
    nohup sudo -u $SUDO_USER /usr/bin/discord >/dev/null 2>&1 &
fi
