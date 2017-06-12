#!/bin/bash
# generate openvpn server and client config file

#-----------------------------------------
# Debug variable
step=3

#-----------------------------------------
# Global variables
mode="unknown"
work_path="./"
easyrsa_path="unknown"
log_path="${work_path}log"
client_name="client1"

head_text="openvpn_config:"

###### Functions
#-----------------------------------------
# Generate Diffie Hellman parameters
function func_generate_DH_parameters()
{
	echo "${head_text} Generating Diffie Hellman parameters..."

	source ./vars
	./build-dh

	status=$?
	if [ $status != 0 ]; then
		echo "${head_text} Failed to generate Diffie Hellman parameters"
		exit 1
	fi
	echo "${head_text} Success"
}

# Generate the master Certificate Authority (CA) certificate & key
function func_generate_master_CA()
{
	echo "${head_text} Generating master Certificate Authority..."

	source ./vars
	./clean-all
	./build-ca

	status=$?
	if [ $status != 0 ]; then
		echo "${head_text} Failed to generate master Certificate Authority"
		exit 1
	fi
	echo "${head_text} Success"
}

# Generate certificate & key for server
function func_generate_cert_server()
{
	echo "${head_text} Generating certificate & key for server..."

	./build-key-server server

	status=$?
	if [ $status != 0 ]; then
		echo "${head_text} Failed to generate certificate & key for server"
		exit 1
	fi
	echo "${head_text} Success"
}

# Generate certificate & key for client
# $1 client name
function func_generate_cert_client()
{
	client_name=$1

	echo "${head_text} Generating certificate & key for client..."

	./build-key $1

	status=$?
	if [ $status != 0 ]; then
		echo "${head_text} Failed to generate certificate & key for client"
		exit 1
	fi
	echo "${head_text} Success"
}


###### Main
#-----------------------------------------
# Step 1
if [ $step -lt 1 ]; then
	exit 0
fi

# Command line parser
# See this link for details: 
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
#help_message="usage: $0 -m/--mode MODE [-p/--path openvpn install path]\narguments:\n\t-m/--mode {server, client}"

read -r -d '' help_message <<- EOM
usage: $0 -m/--mode MODE [-p/--path easy-rsa path]\n
arguments:\n
\t-m/--mode {server, client, dh, ca}\n
\t-p/--path easy-rsa path\n
EOM

while [[ $# -gt 0 ]]
do
key="$1"

case $key in

    -m|--mode)
    mode="$2"
    shift # past argument
    ;;

    -p|--path)
    easyrsa_path="$2"
    shift # past argument
    ;;

    -n|--name)
    client_name="$2"
    shift # past argument
    ;;

    -h|--help)
    echo -e ${help_message}
    exit 0
    ;;

    *) # Unknown option
    echo "Unknown option: $1"
    echo -e ${help_message}
    exit 1    
    ;;
esac
shift # past argument or value
done
# echo mode = "${mode}"
# echo SEARCH PATH     = "${SEARCHPATH}"
# echo LIBRARY PATH    = "${LIBPATH}"


#-----------------------------------------
# Step 2
if [ $step -lt 2 ]; then
	exit 0
fi

# Check if easy-rsa is in working directory
echo "${head_text} Checking easy-rsa in working directory: ${work_path}..."

if [ -d "${work_path}easy-rsa" ]; then
	echo "${head_text} easy-rsa found!"
	easyrsa_path=${work_path}easy-rsa
else

	# Check if easy-rsa is installed
	echo "${head_text} Checking if easy-rsa is installed..."
	install_script="openvpn_install-ubuntu.sh"

	dpkg -s easy-rsa > ${log_path}
	status=$?
	if [ $status != 0 ] && [ $easyrsa_path == "unknown" ]; then
		echo "${head_text} easyrsa is not installed or cannot be found. "
		echo "${head_text} Please install it using <${install_script}>. Or give the path of easy-rsa using -p"
		echo -e "\nIf it is Mac OS, please install openvpn USING Tunnelblick (NOT use the script <${install_script}>)"
		echo "On Mac, easyrsa path can be get using Tunnelblick -> [Utilities] -> [Open easy-rsa in terminal]"
		exit 1
	fi

	# Set easyrsa installation path if not given
	if [ $easyrsa_path == "unknown" ]; then
		easyrsa_path="/usr/share/easy-rsa"
	fi
	

	# Check if easy-rsa exists
	if [ ! -d "$easyrsa_path" ]; then
		echo "${head_text} Invalid easy-rsa path: ${easyrsa_path}"
		echo "${head_text} It does exists or is not named like this: easy-rsa"
		echo "${head_text} Please give the path of easy-rsa like /usr/share/easy-rsa"
		exit 1
	fi

	# Copy easy-rsa to working path
	echo "${head_text} copying easy-rsa to working directory..."
	cp -r $easyrsa_path $work_path
	status=$?
	if [ $status != 0 ]; then
		echo "${head_text} Failed to copy easy-rsa directory. Please check if you have the write privilege on path: ${work_path}"
		exit 1
	fi

	# Set easyrsa path to the copied one
	easyrsa_path=${work_path}easy-rsa
fi



#-----------------------------------------
# Step 3
if [ $step -lt 3 ]; then
	exit 0
fi

cd $easyrsa_path

# Create config file according to mode
case "$mode" in
	"dh") 
	func_generate_DH_parameters
   	;;

	"server_cert")
	func_generate_cert_server
	;;

	"client_cert")
	func_generate_cert_client $client_name
   	;;

   	"ca")
	func_generate_master_CA
   	;;

   	"server_cfg")
	# TODO
   	;;

   	"client_cfg")
	# TODO
   	;;

   	*) # Unknown option
    echo "Unknown option: $1"
    echo -e ${help_message}
    exit 1    
    ;;


esac








