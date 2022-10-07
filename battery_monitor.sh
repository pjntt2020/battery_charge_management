#!/bin/bash

binfolder=$(cd "$(dirname "$0")";pwd);
confFile="$binfolder/blcm.conf"
if [ -f "$confFile" ]; then
    Batterymin=`sed '/^Batterymin=/!d;s/.*=//' $confFile`  #删除掉不相等,再替换掉等号前的内容,剩下就是数字
    Batterymax=`sed '/^Batterymax=/!d;s/.*=//' $confFile`
    switchcommand=`sed '/^switchcommand=/!d;s/.*=//' $confFile`
else
     touch $confFile
     Batterymin=40
     Batterymax=80
     switchcommand="conf"
fi
#日期时间
BatteryDrainDate=$(date "+%Y-%m-%d %H:%M:%S")
#当前电池电量
BatteryPercentage=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
#当前SMC设置数值
BatteryCapacity=$($binfolder/bclm read | grep -Eo "\d+")

if [ "$1" = "conf" ];then
switchcommand=$1
fi

case $switchcommand in
"conf")
#配置充电最大,最小阀值,选择工作模式
read -p "Please enter the minimum battery level[40-70]:" inputmin
read -p "Please enter the maximum battery level[80-100]:" inputmax
read -p "Please select a working mode [1]:formulate mode,[2]:complete mode:" selectcommand
if [ $inputmax -lt 80 ] || [ $inputmin -lt 40 ] && [ $inputmin -lt $inputmax ]; then
echo "The parameters are incorrect, please reconfigure."
exit 0
fi

case $selectcommand in 
"1")
inputcommand='formulate';
;;
"2")
inputcommand='complete';
;;
esac

if [ $inputmin -lt $inputmax ]; then

  e1=`cat $confFile|grep Batterymin|wc -l`
  e2=`cat $confFile|grep Batterymin|wc -l`
  e3=`cat $confFile|grep switchcommand|wc -l`

  if [ $e1 -gt 0 ]; then 
      sed -i '.bak' '/^Batterymin*/d' $confFile
  fi

  if [ $e2 -gt 0 ]; then
     sed -i '.bak' '/^Batterymax*/d' $confFile
  fi

  if [ $e3 -gt 0 ]; then
     sed -i '.bak' '/^switchcommand*/d' $confFile
  fi

  if [ $inputcommand == "formulate" ]; then
    if [ $BatteryPercentage -ge $Batterymax ]; then
         $binfolder/bclm write $Batterymin
         echo "$BatteryDrainDate Change Battery charge to $Batterymin" >> /var/log/batteryPercentage.log
    fi  

    if [ $BatteryPercentage -le $Batterymin ]; then
        $binfolder/bclm write $Batterymax
        echo "$BatteryDrainDate Change Battery charge to $Batterymax" >> /var/log/batteryPercentage.log
    fi
  fi 

fi
echo "Batterymin="$inputmin >> $confFile
echo "Batterymax="$inputmax >> $confFile
echo "switchcommand="$inputcommand >> $confFile


echo "Configuration saved successfully."
;;
"formulate")
#如果当前充电量小于最小值,则设置为最大充电阈值,如果当前充电阈值等于最大充电阈值,则不修改.
#如果当前充电量大于最大充电阈值,则设置为最小充电阈值,如果当前充电阈值等于最小充电阈值,则不修改.


if [ $BatteryPercentage -le $Batterymin ]; then
     if [ $BatteryCapacity -eq $Batterymin ]; then
      $binfolder/bclm write $Batterymax
      echo "$BatteryDrainDate Change Battery charge max to $Batterymax" >> /var/log/batteryPercentage.log
     fi 
     echo "$BatteryDrainDate Battery percentage is below $Batterymin ,start charging" >> /var/log/batteryPercentage.log   

elif [ $BatteryPercentage -ge $Batterymax ]; then
    if [ $BatteryCapacity -eq $Batterymax ]; then
      $binfolder/bclm write $Batterymin
      echo "$BatteryDrainDate Change Battery charge min to $Batterymin" >> /var/log/batteryPercentage.log
     fi 
    echo "$BatteryDrainDate Battery percentage is above $Batterymax ,stop charging" >> /var/log/batteryPercentage.log
else
    echo "$BatteryDrainDate Current power $BatteryPercentage . " >> /var/log/batteryPercentage.log
fi
;;
"complete")
#运行完全充电模式.判断充电阈值如果不是100,则改成100.
if [ $BatteryCapacity -lt 100 ];then 
   $binfolder/bclm write 100 
fi
echo "$BatteryDrainDate Battery needs to be fully charged" >> /var/log/batteryPercentage.log
;;
*)
  echo "use $0 (conf)"
;;
esac
