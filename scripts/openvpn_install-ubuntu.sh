#!/bin/bash
# openvpn server installation

# Debug variable
step=5

# Global variable
work_path="."
head_text="openvpn_install:"
log_path="${work_path}/log"

echo "$head_text NOTE: This script is to install openvpn server on ubuntu machine."
echo -e "$head_text See the following link for instructions if any problems:\n"
echo "$head_text https://openvpn.net/index.php/open-source/documentation/howto.html"
echo -e "$head_text https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-16-04\n"


###### Functions
#----------------------------------------

# Backup file to target path
# $0 should be the 1st argument, which is command
# $1 target file path
# $2 backup file path
function func_backup_file()
{
	file_path=$1
	backup_path=$2
	file_name=$(basename ${file_path})
	copy_path="${backup_path}${file_name}.copy.$(date +"%Y%m%d_%H%M%S")"

	sudo cp $file_path $copy_path
	status=$?
	if [ $status != 0 ]; then
		echo "Failed to backup file: ${file_path}. Please check error message above"
		exit 1
	fi
}

# TODO: Need to test
# Install package if not installed
# $1 package name
function func_install_package()
{
	packagename=$1

	echo "$head_text Checking if $packagename is installed..."
	dpkg -s $packagename > ${log_path}
	status=$?

	## Not there then install it
	if [ $status != 0 ]; then
		echo -e "\n$head_text $packagename will be installed on this machine now..."
		sudo apt-get update
		sudo apt-get install $packagename
		status=$?
		if [ $status != 0 ]; then
			echo "$head_text Failed to install $packagename"
			exit 1
		fi
		echo "$head_text $packagename installed success!"
	else
		echo "$head_text $packagename already installed, continue"
	fi

	exit 0
}

###### Main
#----------------------------------------
# Step 1:
# Check if user wants to install openvpn
if [ $step -lt 1 ]; then
	exit 0
fi

while true; do
    read -p "$head_text Do you wish to install openvpn on this machine? (y/n): " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 1;;
        * ) echo "$head_text Please answer y(yes) or n(no).";;
    esac
done

#----------------------------------------
# Step 2: Install necessary packages
## Install openvpn
if [ $step -lt 2 ]; then
	exit 0
fi

## Check if openvpn is installed
echo "$head_text Checking if openvpn is installed..."
dpkg -s openvpn > ${log_path}
status=$?

## Not there then install it
if [ $status != 0 ]; then
	echo -e "\n$head_text openvpn will be installed on this machine now..."
	sudo apt-get update
	sudo apt-get install openvpn
	status=$?
	if [ $status != 0 ]; then
		echo "$head_text Failed to install openvpn"
		exit 1
	fi
	echo "$head_text openvpn installed success!"
else
	echo "$head_text openvpn already installed, continue"
fi

# Check if python3 is installed
echo "$head_text Checking if python3 is installed..."
dpkg -s python3 > ./log
status=$?
if [ $status != 0 ]; then
	echo "Python is not installed. Please install python before running this script"
	exit 1
fi

# Check if easy-rsa is installed
func_install_package easy-rsa

#----------------------------------------
# Step 3
# Configure settings for openvpn
if [ $step -lt 3 ]; then
	exit 0
fi

# Create backup directory for file changes
echo "$head_text Creating path for file backup..."
backup_path="${work_path}/backup/" # backup path is $work_path + "/backup"
mkdir -p "$backup_path"
status=$?
if [ $status != 0 ]; then
	echo "Failed to create backup directory. Please check if you have the write privilege on path: ${backup_path}"
	exit 1
fi

# Enable IP forwarding
echo "$head_text Enabling ip forwarding..."
file_path="/etc/sysctl.conf"

## Backup file to working directory
echo -e "$head_text \tBacking up file: ${file_path}..."
func_backup_file ${file_path} ${backup_path}

## Change file context for enabling ip forwarding; A python script is used for this change
echo -e "$head_text \tChanging file (ip forwarding): ${file_path}..."
edit_file_script="edit_file.py"

## Run script to do the file change
sudo "${work_path}/${edit_file_script} -m ipv4 -f $file_path"
status=$?
if [ $status != 0 ]; then
	echo "Failed to edit file: ${file_path}. Please check error message above"
	exit 1
fi

## Update session change
echo -e "$head_text \tUpdating session change..."
sudo sysctl -p # update session for the changes

#----------------------------------------
# Step 4
if [ $step -lt 4 ]; then
	exit 0
fi
# Adjust UFW before rules
echo "$head_text Changing UFW before rules..."

## Find public network interface of the machine
result=$(ip route | grep default)
stringarray=($result)
public_interface=${stringarray[4]}
echo -e "$head_text \tFound public network interface name: ${public_interface}"

file_path="/etc/ufw/before.rules"

## Check if file already being changed
keyword="POSTROUTING"
sudo grep -e ${keyword} ${file_path} > ${log_path}
status=$?

if [ $status != 0 ]; then

	## not found then do the changes

	## Backup file to working directory
	echo -e "$head_text \tBacking up file: ${file_path}..."
	func_backup_file ${file_path} ${backup_path}

	## Change file context for enabling ip forwarding; A python script is used for this change
	echo -e "$head_text \tChanging file (UFW rules): ${file_path}..."
	edit_file_script="edit_file.py"

	## Run script to do the file change
	sudo "${work_path}/${edit_file_script} -m ufw_bef -f $file_path -p ${public_interface}"
	status=$?
	if [ $status != 0 ]; then
		echo "Failed to edit file: ${file_path}. Please check if you have admin privilege"
		exit 1
	fi
	
else

	echo "$head_text UFW rules already changed"
	
fi

#----------------------------------------
# Step 5
if [ $step -lt 5 ]; then
	exit 0
fi
# Enable UFW forward packets
echo "$head_text Enable UFW forward packets..."

# Enable IP forwarding
file_path="/etc/default/ufw"

## Backup file to working directory
echo -e "$head_text \tBacking up file: ${file_path}..."
func_backup_file ${file_path} ${backup_path}

## Enable UFW forward packets; A python script is used for this change
echo -e "$head_text \tChanging file (UFW forward packets): ${file_path}..."
edit_file_script="edit_file.py"

## Run script to do the file change
sudo "${work_path}/${edit_file_script} -m ufw_for -f $file_path"
status=$?
if [ $status != 0 ]; then
	echo "Failed to edit file: ${file_path}. Please check error message above"
	exit 1
fi


# End
echo "$head_text DONE. Openvpn is installed and configured successfully"
exit 0

# # Enable IP forwarding
# sudo sysctl -w net.ipv4.ip_forward=1
# status=$?
# if [ $status != 0 ]; then
# 	echo "Failed to enable ip forwarding!"
# 	exit
# fi



