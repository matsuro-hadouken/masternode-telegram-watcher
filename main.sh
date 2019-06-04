
URL="https://api.telegram.org/bot$TOKEN/sendMessage"
NODE_IP=$(cat /root/.dogecash/dogecash.conf | grep "externalip="  | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)")

UPDATE_INTERVAL=60 # service update interval
MAX_DIF=8          # acceptable sync drift
BLOCK_SHIFT=8      # take a shift from the last block for hash test, since we can't be sure about recent one.

function test_positive(){

        LASTB_EXP=$(curl --silent https://api.dogec.io/api/getblockcount) # getting last block from EXPLORER
        LASTB_LOCAL=$(dogecash-cli getblockcount)                         # getting masternode last block

        if (( $LASTB_EXP > $LASTB_LOCAL )) ;then # find block for test

                TEST_B=$LASTB_LOCAL
                BLOCK_DIF=$( expr $LASTB_EXP - $LASTB_LOCAL )
        else
                TEST_B=$LASTB_EXP
                BLOCK_DIF=$( expr $LASTB_LOCAL - $LASTB_EXP )
        fi

        if (( $BLOCK_DIF >= $MAX_DIF )) ;then # out of sync

                SYNC_REPORT="$NODE_IP %0A Block difference $BLOCK_DIF %0A Explorer block: $LASTB_EXP %0A VPS block: $LASTB_LOCAL"

        else # otherwise in sync

                SYNC_REPORT="$NODE_IP in sync"
        fi

        TEST_BLOCK=$( expr $TEST_B - $BLOCK_SHIFT ) # apply shift for stability

        # get explorer hash

        EXPLORER_REPORT=$(curl --silent  https://api.dogec.io/api/block/$TEST_BLOCK | sed -e 's/[{}]/''/g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | grep hash | sed "s/hash//g" | tr -d '{":}')

        sleep 1

        # get VPS hash

        LOCAL_REPORT=$( dogecash-cli getblockhash $TEST_BLOCK )

        # shorten output for print

        L_SHORT=$( echo $LOCAL_REPORT | tail -c 8 )
        E_SHORT=$( echo $EXPLORER_REPORT | tail -c 8 )

                if [ -z "$EXPLORER_REPORT" ] || [ -z "$LOCAL_REPORT" ] ;then # check for BAD output

                    curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$SYNC_REPORT Can't get hash data. %0A Will try again in $UPDATE_INTERVAL seconds."

                else # if everything cool with the output

                    if [ "$EXPLORER_REPORT" != "$LOCAL_REPORT" ] ;then # if block hash NOT match, report:

                        curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$SYNC_REPORT  %0A Hash for block $TEST_BLOCK test failed ! %0A VPS: $L_SHORT %0A Explorer: $E_SHORT %0A CHAIN MISMATCH !"

                    else # if everything cool, report:

                        curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$SYNC_REPORT %0A Hash for block $TEST_BLOCK perfectly match. %0A VPS report: $L_SHORT %0A Explorer report: $E_SHORT"
                    fi

                fi

}

while :

        do
                MN_STAT=$(dogecash-cli getmasternodestatus | grep status | tr -d 'status":, ')

                if [ "$MN_STAT" != 4 ] ;then

                        curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="WARNING: %0A $NODE_IP %0A STATUS OFFLINE"
                else

                        test_positive

                fi

                sleep $UPDATE_INTERVAL
                clear
        done
