#!/bin/bash

#Function to Download and extract current version
download_ver () { 
	wget -q https://github.com/PhantomBot/PhantomBot/releases/download/v$version/PhantomBot-$version.zip
	unzip -o PhantomBot-$version.zip -d /data/
	rm -f PhantomBot-$version.zip
}
#Get Current version
version=$(curl -s https://api.github.com/repos/PhantomBot/PhantomBot/releases/latest | grep 'tag_name' | cut -d\" -f4 | cut -c 2-)

# Inital setup
if [ ! -d /data/PhantomBot ]; then
	download_ver $version
	mv /data/PhantomBot-$version/ /data/PhantomBot
	touch /data/PhantomBot/version.txt
	echo $version > /data/PhantomBot/version.txt
	mv /botlogin.txt /data/PhantomBot/
	sed -i "s/\%BOT_TWITCH_USERNAME\%/${BOT_TWITCH_USERNAME}/g;
			s/\%BOT_OAUTH\%/${BOT_OAUTH}/g;
			s/\%API_OAUTH\%/${API_OAUTH}/g
			s/\%PANEL_USER\%/${PANEL_USER}/g
			s/\%PANEL_PASSWORD\%/${PANEL_PASSWORD}/g
			s/\%BOT_CHANNEL\%/${BOT_CHANNEL}/g;
			s/\%BOT_OWNER\%/${BOT_OWNER}/g;
			s/\%GAMEWISPAUTH\%/${GAMEWISPAUTH}/g;
			s/\%GAMEWISPREFRESH\%/${GAMEWISPREFRESH}/g;
			s/\%MYSQL_HOST\%/${MYSQL_HOST}/g;
			s/\%MYSQL_PORT\%/${MYSQL_PORT}/g;
			s/\%MYSQL_NAME\%/${MYSQL_NAME}/g;
			s/\%MYSQL_USER\%/${MYSQL_USER}/g;
			s/\%MSQL_PASS\%/${MYSQL_PASS}/g;
			s/\%TIME_ZONE\%/${TIME_ZONE}/g;" \
			"/data/PhantomBot/botlogin.txt"
	chmod +x "/data/PhantomBot/launch-service.sh"
#Check for newer version 
else 
	#read version file
	curr_ver=$(<"/data/PhantomBot/version.txt")
	#upgrade if needed
	if [ $version > $curr_ver ]; then 
		echo upgrading
		download_ver $version
		#Backup config and DB
		if [ ! -d /data/backup ]; then	
			mkdir /data/backup
		else
			rm -R /data/backup
			mkdir /data/backup
		fi
		cp /data/PhantomBot/phantombot.db /data/backup/phantombot.db
		cp /data/PhantomBot/botlogin.txt /data/backup/botlogin.txt
		#move DB and config file to new version
		mv /data/PhantomBot/phantombot.db /data/PhantomBot-$version/phantombot.db
		mv /data/PhantomBot/botlogin.txt /data/PhantomBot-$version/botlogin.txt
		#remove old version
		rm -R /data/PhantomBot
		#move back to PhantomBot dir
		mv /data/PhantomBot-$version/ /data/PhantomBot
		#create new version file
		touch /data/PhantomBot/version.txt
		echo $version > /data/PhantomBot/version.txt
	fi
fi

chmod +x /launch-service.sh

/data/PhantomBot/launch-service.sh