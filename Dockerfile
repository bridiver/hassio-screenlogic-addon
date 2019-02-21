ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

RUN apk add npm jq mosquitto-clients && npm install node-screenlogic smart-buffer

COPY run.sh /
COPY send_state_to_ha.js /node_modules/node-screenlogic/

COPY pool_on  /node_modules/node-screenlogic/
COPY pool_off /node_modules/node-screenlogic/

COPY spa_on  /node_modules/node-screenlogic/
COPY spa_off /node_modules/node-screenlogic/

RUN chmod a+x /node_modules/node-screenlogic/*
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]

