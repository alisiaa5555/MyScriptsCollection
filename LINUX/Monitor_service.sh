#!/bin/bash

#The following script verifies if the apache service is active. First, the script clears the /monitor_service_logs log file.
#If the condition is met, so the service is active, the information is written to the log file (pic 1).
#If the condition is not met, the script tries to start the service. In case of an issue, it tries to start the service. In case of an error, a standard error is redirected to the log file as well as service's status and journalctl logs (last 30 lines) (pic2). If the service is started, the same information is writted (pic 3).

SERVICE="apache2.service"
STATUS="active"
SYSCTL_PATH="/usr/bin/systemctl"
OUTPUT=$($SYSCTL_PATH is-active $SERVICE)
LOGS_PATH="/XXXXXXXX/monitor_service_logs.txt"
date=$(date +%Y.%m.%d::%H:%M)

#Clear the logs file
>$LOGS_PATH


if [[ $OUTPUT == $STATUS ]]; then
        echo "$date: Service is $OUTPUT">$LOGS_PATH
else
        echo -e "\n$date: Service is $OUTPUT at the moment. Trying to start the service...">>$LOGS_PATH
        $($SYSCTL_PATH start $SERVICE 2>>$LOGS_PATH)
        OUTPUT=$($SYSCTL_PATH is-active $SERVICE)
        echo "Service is $OUTPUT">>$LOGS_PATH
        echo -e "\nCURRENT STATUS OF $SERVICE IS $($SYSCTL_PATH status $SERVICE)" >>$LOGS_PATH
        echo -e "\nJOURNALCTL LOGS: $(/usr/bin/journalctl -xeu $SERVICE | tail -n 30)" >>$LOGS_PATH

fi
