#!/bin/bash
routerip="192.168.1.254"
pass='<password>'
page=$(curl -L "http://$routerip/index.cgi?active_page=9148" -H 'Cookie: rg_cookie_session_id=' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'DNT: 1' --data 'active_page=9121' --cookie-jar cookies.txt)
posttoken=$(echo $page |grep post_token |awk 'BEGIN { FS = "\"post_token\" value=\"" } ; {print $2}'|awk 'BEGIN { FS = "\"" } ; {print $1}'|xargs)
requestid=$(echo $page |grep request_id |awk 'BEGIN { FS = "\"request_id\" value=\"" } ; {print $2}'|awk 'BEGIN { FS = "\"" } ; {print $1}'|xargs)
authkey=$(echo $page |grep auth_key |awk 'BEGIN { FS = "\"auth_key\" value=\"" } ; {print $2}'|awk 'BEGIN { FS = "\"" } ; {print $1}'|xargs)
passwordid=$(echo $page |grep password_ |awk 'BEGIN { FS = "\"password_" } ; {print $2}'| awk 'BEGIN { FS = "\"" } ; {print $1}'|xargs)
pass+=$authkey
passhash=$(echo -n $pass |openssl dgst -md5|awk '{print $2}')
postvars="request_id=$requestid&active_page=9148&active_page_str=bt_login&mimic_button_field=submit_button_login_submit%3A+..&button_value=&post_token=$posttoken&password_$passwordid=&md5_pass=$passhash&auth_key=$authkey"

curl -Ls "http://$routerip/index.cgi" -H 'Content-Type: application/x-www-form-urlencoded' -H 'Cache-Control: max-age=0' -H 'Referer: http://$routerip/index.cgi?active_page=9121' -H 'Connection: keep-alive' -H 'DNT: 1' --data "$postvars" --cookie cookies.txt >/dev/null

IP=$(curl -s "http://$routerip/index.cgi?active_page=9121&nav_clear=1" -H 'DNT: 1' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: en-GB,en-US;q=0.8,en;q=0.6' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' --cookie cookies.txt --compressed | grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" |head -n 1)

echo $IP
