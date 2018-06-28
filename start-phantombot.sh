#!/bin/bash

# Variables to ease future substitution
BASEDIR="/data/"
BOTLOGIN_SUBPATH="config/botlogin.txt"
DB_SUBPATH="config/phantombot.db"

PHANTOMDIR="${BASEDIR}/PhantomBot"
BACKUPDIR="${BASEDIR}/backup"
BOTVERSION_PATH="${PHANTOMDIR}/version.txt"
BOTLOGIN_PATH="${PHANTOMDIR}/${BOTLOGIN_SUBPATH}"
DB_PATH="${PHANTOMDIR}/${DB_SUBPATH}"


# Download and extract current version
download_ver () { 
  curl -LO https://github.com/PhantomBot/PhantomBot/releases/download/v${version}/PhantomBot-${version}.zip
  unzip -o PhantomBot-${version}.zip -d "${BASEDIR}"
  rm -f PhantomBot-${version}.zip
}
# Get Current version
version=$(curl -s https://api.github.com/repos/PhantomBot/PhantomBot/releases/latest | grep 'tag_name' | cut -d\" -f4 | cut -c 2-)

# Initial setup
if [ ! -d /data/PhantomBot ]
then
  download_ver ${version}
  mv "${BASEDIR}/PhantomBot-${version}/" "${PHANTOMDIR}"
  echo ${version} > "${BOTVERSION_PATH}"
  mv /botlogin.txt "${BOTLOGIN_PATH}"
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
  "${BOTLOGIN_PATH}"
  chmod +x "${PHANTOMDIR}/launch-service.sh"
# Check for identical version 
else 
  # Read version file
  curr_ver=$(<"${BOTVERSION_PATH}")
  # Upgrade if needed
  if [ ${version} != $curr_ver ]
  then 
    echo upgrading
    download_ver ${version}

    # Backup config and DB
    if [ ! -d "${BACKUPDIR}" ]
    then
      mkdir "${BACKUPDIR}"
    else
      rm -R "${BACKUPDIR}"
      mkdir "${BACKUPDIR}"
    fi

    cp "${DB_PATH}" "${BACKUPDIR}/phantombot.db"
    cp "${BOTLOGIN_PATH}" "${BACKUPDIR}/botlogin.txt"
    # Move DB and config file to new version
    mv "${DB_PATH}" "${BASEDIR}/PhantomBot-${version}/${DB_SUBPATH}"
    mv "${BOTLOGIN_PATH}" "${BASEDIR}/PhantomBot-${version}/${BOTLOGIN_SUBPATH}"
    # Remove old version
    rm -R "${PHANTOMDIR}"
    # Move back to PhantomBot dir
    mv "${BASEDIR}/PhantomBot-${version}/" "${PHANTOMDIR}"
    # Create new version file
    echo ${version} > "${BOTVERSION_PATH}"
  fi
fi

# Exit condition to enable intial building
if [ -n "${1:-}" -a "${1:-}" == "dontrun" ]
then
  exit
fi

/data/PhantomBot/launch-service.sh
