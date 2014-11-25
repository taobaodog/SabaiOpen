location="Pacific/Wake"
zone=$(cat /www/libs/timezones.data | grep -w "$location" | awk '{print $2}')
echo $location
echo $zone

