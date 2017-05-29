#!/bin/bash
# openvpn server installation

# Debug variable
step=3

# Global variable
work_path="./"
head_text="openvpn_install:"

echo "$head_text NOTE: This script is to install openvpn server on ubuntu machine."
echo -e "$head_text See the following link for instructions if any problems:\n"
echo "$head_text https://openvpn.net/index.php/open-source/documentation/howto.html"
echo -e "$head_text https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-16-04\n"


#----------------------------------------
# Step 1:
# Check if user wants to install openvpn
if [ $step -lt 1 ]; then
	exit
fi

while true; do
    read -p "$head_text Do you wish to install openvpn on this machine? (y/n): " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "$head_text Please answer y(yes) or n(no).";;
    esac
done

#----------------------------------------
# Step 2: Install necessary packages
## Install openvpn
if [ $step -lt 2 ]; then
	exit
fi

## Check if openvpn is installed
dpkg -s openvpn > ./log
status=$?

## Not there then install it
if [ $status != 0 ]; then
	echo -e "\n$head_text openvpn will be installed on this machine now..."
	sudo apt-get update
	sudo apt-get install openvpn
	status=$?
	if [ $status != 0 ]; then
		echo "$head_text Failed to install openvpn"
		exit
	fi
	echo "$head_text openvpn installed success!"
else
	echo "$head_text openvpn already installed, continue"
fi

# Check if python3 is installed
dpkg -s python3 > ./log
status=$?
if [ $status != 0 ]; then
	echo "Python is not installed. Please install python before running this script"
	exit
fi

#----------------------------------------
# Step 3
# Configure settings for openvpn
if [ $step -lt 3 ]; then
	exit
fi

# Create backup directory for file changes
backup_path="${work_path}backup/" # backup path is $work_path + "/backup"
mkdir -p "$backup_path"
status=$?
if [ $status != 0 ]; then
	echo "Failed to create backup directory. Please check if you have the write previlege on path: ${backup_path}"
	exit
fi

# Enable IP forwarding
## Backup file to working directory
file_path="/etc/sysctl.conf"
file_name="sysctl.conf"
copy_path="${backup_path}${file_name}.copy.$(date +"%Y%m%d_%H%M%S")"

cp $file_path $copy_path
status=$?
if [ $status != 0 ]; then
	echo "Failed to backup file: ${file_path}. Please check if you have the write previlege on path: ${backup_path}"
	exit
fi

## Change file context for enabling ip forwarding

# # Enable IP forwarding
# sudo sysctl -w net.ipv4.ip_forward=1
# status=$?
# if [ $status != 0 ]; then
# 	echo "Failed to enable ip forwarding!"
# 	exit
# fi



