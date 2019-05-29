#!/bin/bash

rm -f mn-check*
rm -f MasternodeCheck*

clear

PS3='What we do: '
options=("Uninstall" "Install")
select opt in "${options[@]}"
do
    case $opt in
        "Install")
                clear
                echo
                echo "Ok, let's roll !"
                sleep 2
                clear
                break
                ;;
        "Uninstall")

                clear
                echo "We will remove service from this machine."
                sleep 1

		systemctl stop MasternodeCheck.service
		sleep 3
		systemctl disable MasternodeCheck.service
		sleep 3
		killall -I -q MasternodeCheck
		sleep 1

		rm /usr/local/bin/mn-check*
		rm /etc/systemd/system/MasternodeCheck*

		exit
                ;;
                *) echo "invalid option $REPLY";;
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
echo "Are you sure ? "
echo
echo $TOKEN
echo
echo $CHAT_ID
echo

	printf "Press any key to continue or 'CTRL+C' to exit "

	(tty_state=$(stty -g)
	stty -icanon
	LC_ALL=C dd bs=1 count=1 >/dev/null 2>&1
	stty "$tty_state"
	) </dev/tty

clear
echo
echo "Now lets check Telegram Bot connection"
echo

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
echo Sending message to your channel ...
sleep 1

clear

echo Can you confirm your connections ?
echo

# confirmation menue

PS3='Did you receive message: '
options=("Yes" "No")
select opt in "${options[@]}"
do
    case $opt in
        "Yes")
		clear
		echo
        	echo "Ok, cool, lets continue ..."
		sleep 2
		clear
		break
        	;;
	"No")
		clear
        	echo "Please try to obtain right data"
        	echo "for your bot, something is missing"
        	echo "or incorrect."
		sleep 2
		exit
		;;
        	*) echo "invalid option $REPLY";;
    	esac
done

# building main script body

echo '#!/bin/bash' > config.tmp
echo >> config.tmp
echo TOKEN=$TOKEN >> config.tmp
echo CHAT_ID=$CHAT_ID >> config.tmp

wget -q https://raw.githubusercontent.com/matsuro-hadouken/mn-status-check/master/main.sh

cat config.tmp main.sh > mn-check.sh

rm config.tmp
rm main.sh

# service

chmod a+x mn-check.sh

mv mn-check.sh /usr/local/bin

wget -q https://raw.githubusercontent.com/matsuro-hadouken/mn-status-check/master/MasternodeCheck.service

chmod 0644 MasternodeCheck.service

mv MasternodeCheck.service /etc/systemd/system

echo "Starting service please wait ..."

systemctl enable MasternodeCheck.service

sleep 3

systemctl start MasternodeCheck.service

sleep 3

clear

echo
echo "Let's check if service started"

sleep 3

clear

systemctl status MasternodeCheck.service

sleep 1

exit
