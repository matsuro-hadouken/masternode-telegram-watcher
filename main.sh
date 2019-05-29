URL="https://api.telegram.org/bot$TOKEN/sendMessage"

while :

        do
                NODE_IP=$(dogecash-cli getmasternodestatus | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)")
                MN_STAT=$(dogecash-cli getmasternodestatus | grep status | tr -d 'status":, ')

                if [ $MN_STAT != 4 ]

                then
                        curl -s -X POST $URL -d chat_id=$CHAT_ID -d text=$NODE_IP" - doesn't feel well"
                fi

                sleep 1h
        done

