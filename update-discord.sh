#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "please, run this file with sudo";
    exit 1;
fi

LOGFILE="/var/log/install-discord.log";
touch $LOGFILE;

if [ -f $LOGFILE ]; then
    rm $LOGFILE;
fi

CHECKLOGFILE="run \`cat $LOGFILE\` to check the logs";
INSTALLPATH="/tmp/discord.deb";

which curl &> /dev/null || {
    apt install curl -y &>> $LOGFILE
    if [ $? -ne 0 ]; then
        echo -e "Failed to install curl, $CHECKLOGFILE";
        exit 1;
    fi
}

echo "updating...";

curl -L "https://discord.com/api/download/stable?platform=linux&format=deb" -o $INSTALLPATH &>> $LOGFILE;

dpkg -i $INSTALLPATH &>> $LOGFILE &&

rm -f $INSTALLPATH &&

echo "discord updated, you may open discord now." ||
echo "there was an error while updating discord, $CHECKLOGFILE";
