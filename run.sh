#!/bin/bash
#set -e

CONFIG_PATH=/data/options.json
USER="$(jq --raw-output '.user' $CONFIG_PATH)"
PASSWORD="$(jq --raw-output '.password' $CONFIG_PATH)"

cd /node_modules/node-screenlogic

while [ 1 ]; do
PAYLOAD=`mosquitto_sub -u ${USER} -P ${PASSWORD} -v -t /pentair/# -W 10 -C 1`
if [ $? -gt 0 ]; then
  echo "MQTT Client exited with non-zero status"
  sleep 10
else
  TOPIC=`echo $PAYLOAD | awk '{print $1}'`
  MESSAGE=`echo $PAYLOAD | awk '{print $2}'`

  case $TOPIC in
    "/pentair/pool/command")
    if [ "${MESSAGE}" == "ON" ]; then
      ./pool_on
    elif [ "${MESSAGE}" == "OFF" ]; then
      ./pool_off
    fi
    ;;
    "/pentair/spa/command")
    if [ "${MESSAGE}" == "ON" ]; then
      ./spa_on
    elif [ "${MESSAGE}" == "OFF" ]; then
      ./spa_off
    fi
  esac
fi

node send_state_to_ha.js | awk -v user="$USER" -v password="$PASSWORD" -F, '{print "mosquitto_pub -u " user " -P " password " -t " $1 " -m " $2}' | bash -s

done
