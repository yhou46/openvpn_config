#!/bin/bash
# openvpn server installation

echo "NOTE: This script is to install openvpn server on ubuntu machine."

# Debug variable
step=2

# Global variable
work_path="./"
head_text="openvpn_install:"

#----------------------------------------
# Step 1 Done
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
# Step 2 Install necessary packages
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

# Install python3 if not there
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

# ## Backup file to working directory
# file_path="/etc/sysctl.conf"
# file_name="sysctl.conf"

# cp $file_path "$work_path$file_name.copy"
# status=$?
# if [ $status != 0 ]; then
# 	echo "Failed to copy $file_path, make sure you have the right previlege on working path"
# 	exit
# fi

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
status=$?
if [ $status != 0 ]; then
	echo "Failed to enable ip forwarding!"
	exit
fi


#cp ./abc ./abc.copy
#status=$?
#echo "Copy Code: $status - Successful"
#if [ $status != 0 ]; then
#   echo "Copy Code: $status - Unsuccessful"
#fi

