URL="https://api.telegram.org/bot$TOKEN/sendMessage"

while :

        do
                NODE_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
                MN_STAT=$(dogecash-cli getmasternodestatus | grep status | tr -d 'status":, ')

                if [ "$MN_STAT" != 4 ]

                then
                curl -s -X POST $URL -d chat_id=$CHAT_ID -d text=$NODE_IP" - doesn't feel well"
                fi

                sleep 1h
        done
