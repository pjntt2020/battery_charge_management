#!/bin/bash

Batterymin=50
Batterymax=80
BatteryDrainDate=$(date +%H:%M:%S)
BatteryPercentage=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
BatteryCapacity=$(bclm read | grep -Eo "\d+")

if [ $BatteryCapacity -ne 50 && $BatteryCapacity -ne 80 ]; then 
   echo -e "\n $BatteryDrainDate Battery Init to 80%" >> BatteryPercentage.txt
   bclm write 80
fi 

if [ $BatteryPercentage -le $Batterymin ]; then
     if [ $BatteryCapacity -eq $Batterymin ]; then
      bclm wirte 80 
     fi 
     echo -e "\n $BatteryDrainDate Battery percentage is below 50% ,start charging" >> BatteryPercentage.log   

elif [ $BatteryPercentage -ge $Batterymax ]; then
    if [ $BatteryCapacity -eq $Batterymax ]; then
      bclm wirte 50 
     fi 
    echo -e "\n $BatteryDrainDate Battery percentage is above 80% ,stop charging" >> BatteryPercentage.log
fi
