#!/bin/bash

rm -f mn-check*
rm -f MasternodeCheck*

clear

echo -e  "\e[32mWhat we do ?"
echo -e  "\e[39m"
options=("Uninstall" "Install")
select opt in "${options[@]}"
do
    case $opt in
        "Install")
                clear
                echo
                echo -e  "\e[92mOk, let's roll !"
                sleep 2
                clear
                break
                ;;
        "Uninstall")

                clear
                echo -e "\e[31mWe will remove service from this server."
                sleep 1

		systemctl stop MasternodeCheck.service
		sleep 3
		systemctl disable MasternodeCheck.service
		sleep 3
		killall -I -q MasternodeCheck
		sleep 1

		rm /usr/local/bin/mn-check*
		rm /etc/systemd/system/MasternodeCheck*
		
		systemctl --user daemon-reload
		
		echo -e "\e[39m"
		exit
                ;;
                *) ;;
        esac
done

# menue end

clear

echo "Please enter your BOT token: "
read TOKEN
clear
echo "Please enter your chat ID here: "
read CHAT_ID

clear

echo
echo -e "\e[31mAre you sure ? "
echo -e "\e[34m"
echo $TOKEN
echo
echo $CHAT_ID
echo -e "\e[39m"

	printf "Press any key to continue or 'CTRL+C' to exit "

	(tty_state=$(stty -g)
	stty -icanon
	LC_ALL=C dd bs=1 count=1 >/dev/null 2>&1
	stty "$tty_state"
	) </dev/tty

clear
echo
echo -e "\e[32mNow lets check Telegram Bot connection."
echo -e  "\e[39m"

	printf "Press any key to continue or 'CTRL+C' to exit "

        (tty_state=$(stty -g)
        stty -icanon
        LC_ALL=C dd bs=1 count=1 >/dev/null 2>&1
        stty "$tty_state"
        ) </dev/tty
clear

URL="https://api.telegram.org/bot$TOKEN/sendMessage"
curl --silent --output -X POST $URL -d chat_id=$CHAT_ID -d text="PLEASE CONFIRM IN VPS CONSOLE"

clear

echo
echo -e "\e[91mSending message to your channel ..."
sleep 1

clear

echo "Confirm everything setup properly ..."
echo -e  "\e[39m"

# confirmation menue

echo -e "\e[32mDid you receive message ? "
echo -e "\e[39m"
options=("Yes" "No")
select opt in "${options[@]}"
do
    case $opt in
        "Yes")
		clear
		echo
        	echo -e "\e[32mOk, cool, continue ..."
		sleep 2
		echo -e "\e[39m"
		clear
		break
        	;;
	"No")
		clear
        	echo -e "\e[31mPlease try to obtain right data"
        	echo -e "\e[31mfor your bot, something is missing"
        	echo -e "\e[31mor incorrect."
		echo
		echo -e "\e[95mRefer to GitHub page for more information"
		echo -e "\e[39m"
		sleep 3
		exit
		;;
        	*) ;;
    	esac
done

# building main script body

echo '#!/bin/bash' > config.tmp
echo >> config.tmp
echo TOKEN=$TOKEN >> config.tmp
echo CHAT_ID=$CHAT_ID >> config.tmp

wget -q https://raw.githubusercontent.com/matsuro-hadouken/masternode-telegram-watcher/master/main.sh

cat config.tmp main.sh > mn-check.sh

rm config.tmp
rm main.sh

# service

chmod a+x mn-check.sh

mv mn-check.sh /usr/local/bin

wget -q https://raw.githubusercontent.com/matsuro-hadouken/masternode-telegram-watcher/master/MasternodeCheck.service

chmod 0644 MasternodeCheck.service

mv MasternodeCheck.service /etc/systemd/system

echo -e "\e[31mStarting service please wait ..."

systemctl enable MasternodeCheck.service

sleep 3

systemctl start MasternodeCheck.service

sleep 3

clear

echo -e "\e[35m"
echo "Checking service status ..."

sleep 3

echo -e "\e[39m"

clear

systemctl status MasternodeCheck.service

sleep 1

exit
