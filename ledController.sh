#!/bin/bash

gpio -g mode 18 pwm
 
hcitool lescan --duplicates &

while true; do
    rm -f hex_dump.txt
    timeout 0.1s hcidump --raw > hex_dump.txt &
    kill `ps -U root -u root u | awk '/hcidump --raw/{print $2}'` >& /dev/null
    packet=`cat hex_dump.txt | tr -d '\n ' | sed -n 's/.*\(61A907ADD1172FA1C44BF573F4390A[A-F0-9][A-F0-9]\).*/\1/p'`
    value=`cat hex_dump.txt | tr -d '\n ' | sed -n 's/.*\(61A907ADD1172FA1C44BF573F4390A[A-F0-9][A-F0-9]\).*/\1/p'| cut -c31-32`
    if [[ -n $value ]]; then
		echo $value;
		ledLevel=$((16#$value*4 + 3))
		echo $ledLevel
		gpio -g pwm 18 $ledLevel
    fi
done

kill `ps -U root -u root u | awk '/hcitool lescan --duplicates/{print $2}'` >& /dev/null
