#!/bin/bash
# generate openvpn server and client config file

#-----------------------------------------
# Debug variable
step=4

#-----------------------------------------
# Global variables

## Default variable
client_name="client1"
server_name="server"
head_text="openvpn_config:"
mode="unknown"
openvpn_name="default"
host_name="unknown"
port="unknown"

## Paths:
work_path="." # The path of all the scripts, temporary file location
easyrsa_path="unknown" # easy-rsa install path
log_path="${work_path}/log" # Path of log file; Not using right now
install_path="${HOME}/bin/openvpn_cfg/${openvpn_name}" # Path of all config files
sample_cfg_path="${work_path}/../sample_config"

## Other scripts
edit_file_script="edit_file.py"


###### Functions
#-----------------------------------------
# Generate Diffie Hellman parameters and copy it to install path
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

	# Copy file to install path
	cp -i ./keys/dh*.pem "${install_path}/server"

	status=$?
	if [ $status != 0 ]; then
		echo "${head_text} Failed to copy file!"
		exit 1
	fi

	echo "${head_text} SUCCESS! dh*.pem is saved to path: ${install_path}/server"
}

# Generate the master Certificate Authority (CA) certificate & key and copy it to install path
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

	# Copy file to install path
	cp -i "./keys/ca.crt" "${install_path}/common"
	cp -i "./keys/ca.key" "${install_path}/common"

	status=$?
	if [ $status != 0 ]; then
		echo "${head_text} Failed to copy file!"
		exit 1
	fi

	echo "${head_text} SUCCESS! ca.crt/key is saved to path: ${install_path}/common"
}

# Generate certificate & key for server and copy it to install path
# $1 server name
function func_generate_cert_server()
{
	server_name=$1

	echo "${head_text} Generating certificate & key for server..."

	source ./vars

	./build-key-server $1

	status=$?
	if [ $status != 0 ]; then
		echo "${head_text} Failed to generate certificate & key for server"
		exit 1
	fi

	# Copy file to install path
	cp -i "./keys/${server_name}.crt" "${install_path}/server"
	cp -i "./keys/${server_name}.key" "${install_path}/server"

	status=$?
	if [ $status != 0 ]; then
		echo "${head_text} Failed to copy file!"
		exit 1
	fi

	echo "${head_text} SUCCESS! ${server_name}.crt/key is saved to path: ${install_path}/server"
}

# Generate certificate & key for client and copy it to install path
# $1 client name
function func_generate_cert_client()
{
	client_name=$1

	echo "${head_text} Generating certificate & key for client..."

	source ./vars

	./build-key $1

	status=$?
	if [ $status != 0 ]; then
		echo "${head_text} Failed to generate certificate & key for client"
		exit 1
	fi

	# Copy file to install path
	cp -i "./keys/${client_name}.crt" "${install_path}/client"
	cp -i "./keys/${client_name}.key" "${install_path}/client"

	status=$?
	if [ $status != 0 ]; then
		echo "${head_text} Failed to copy file!"
		exit 1
	fi

	echo "${head_text} SUCCESS! ${client_name}.crt/key is saved to path: ${install_path}/client"
}

# Generate server cfg file according to install_path
# $1 server config file name
# $2 server name
function func_generate_server_cfg()
{
	echo "${head_text} Generating server cfg file: $1"
	echo "${head_text} This function is highly dependent on the sample config file!!!"


	# Check if sample config file exists
	if [ ! -d "${sample_cfg_path}" ]; then
		echo "${head_text} Error: sample config file: ${sample_cfg_path} cannot be found!"
		exit 1
	fi

	# Copy sample config file to install path
	cp -i "${sample_cfg_path}/openvpn-sample-config-files-server.conf" "${install_path}/server/$1"

	status=$?
	if [ $status != 0 ]; then
		echo "${head_text} Failed to copy file!"
		exit 1
	fi

	# Change file
	## ca.crt
	echo "${head_text} Changing ca crt path..."
	python3 ${work_path}/${edit_file_script} -m replace -f ${install_path}/server/$1 -o "ca " -n "ca ${install_path}/common/ca.crt"
	status=$?
	if [ $status != 0 ]; then
		echo "${head_text} Failed to changing ca crt path..."
		exit 1
	fi

	## server crt
	echo "${head_text} Changing server crt path..."
	python3 ${work_path}/${edit_file_script} -m replace -f ${install_path}/server/$1 -o cert -n "cert ${install_path}/server/$2.crt"
	status=$?
	if [ $status != 0 ]; then
		echo "${head_text} Failed to changing server crt path..."
		exit 1
	fi

	## server key
	echo "${head_text} Changing server key path..."
	python3 ${work_path}/${edit_file_script} -m replace -f ${install_path}/server/$1 -o key -n "key ${install_path}/server/$2.key # This file should be kept secret"
	status=$?
	if [ $status != 0 ]; then
		echo "${head_text} Failed to changing server key path..."
		exit 1
	fi

	## dh file
	echo "${head_text} Changing dh path..."
	dh_file=$(basename "${install_path}/server/dh*.pem")
	${work_path}/${edit_file_script} -m replace -f ${install_path}/server/$1 -o dh -n "dh ${install_path}/server/${dh_file}"
	status=$?
	if [ $status != 0 ]; then
		echo "${head_text} Failed to changing dh path..."
		exit 1
	fi


	echo "${head_text} SUCCESS! $1 is saved to path: ${install_path}/server/$1"
}

# Generate client cfg file according to install_path
# $1 client config file name
# $2 client name
# $3 host name
# $4 port
function func_generate_client_cfg()
{
	echo "${head_text} Generating client cfg file: $1"
	echo "${head_text} This function is highly dependent on the sample config file!!!"
	
	# Check if host name and port is given
	if [ "$host_name" == "unknown" ] || [ "$port" == "unknown" ]; then
		echo "${head_text} Please give host name and port using -r and -p"
		exit 1
	fi

	# Check if sample config file exists
	if [ ! -d "${sample_cfg_path}" ]; then
		echo "${head_text} Error: sample config file: ${sample_cfg_path} cannot be found!"
		exit 1
	fi

	# Copy sample config file to install path
	cp -i "${sample_cfg_path}/openvpn-sample-config-files-client.conf" "${install_path}/client/$1"

	status=$?
	if [ $status != 0 ]; then
		echo "${head_text} Failed to copy file!"
		exit 1
	fi

	# Change file
	## ca.crt
	python3 ${work_path}/${edit_file_script} -m replace -f ${install_path}/client/$1 -o "ca " -n "ca ${install_path}/common/ca.crt"
	
	## client crt
	python3 ${work_path}/${edit_file_script} -m replace -f ${install_path}/client/$1 -o cert -n "cert ${install_path}/client/$2.crt"

	## client key
	python3 ${work_path}/${edit_file_script} -m replace -f ${install_path}/client/$1 -o "key client.key" -n "key ${install_path}/client/$2.key # This file should be kept secret"

	## host name and port
	python3 ${work_path}/${edit_file_script} -m replace -f ${install_path}/client/$1 -o "remote my-server-1 1194" -n "remote $3 $4"

	echo "${head_text} SUCCESS! $1 is saved to path: ${install_path}/client/$1"
}

###### Main
#-----------------------------------------
# Step 1: Command line parser
if [ $step -lt 1 ]; then
	exit 0
fi

# Command line parser
# See this link for details: 
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
#help_message="usage: $0 -m/--mode MODE [-p/--path openvpn install path]\narguments:\n\t-m/--mode {server, client}"

# Define help_message
read -r -d '' help_message <<- EOM
usage: $0 -m/--mode MODE [-e/--e_path] [-i/--i_path] [-c/--c_name]\n
arguments:\n
\t-m/--mode: {server_cert, server_cfg, client_cert, client_cfg, dh, ca}\n
\t\t server_cert: create server certificate, used with -s server name\n
\t\t server_cfg: create server configuration, used with -s server name\n
\t\t client_cert: create client certificate, used with -c client name\n
\t\t client_cfg: create client configuration, used with -c(optional), -r(required) , -p(required)\n

\t-e/--e_path: easy-rsa path\n
\t-i/--i_path: installation path\n
\t-s/--s_name: server name\n
\t-c/--c_name: client name\n
\t-r/--remote: remote host name for client connection\n
\t-p/--port: remote host port for client connection\n
\t-o/--openvpn_name: openvpn_name used in install path; default value is <default>

EOM

# Parse command line arguments
while [[ $# -gt 0 ]]
do
key="$1"

case $key in

    -m|--mode) # mode
    mode="$2"
    shift # past argument
    ;;

    -e|--e_path) # easy-rsa path
    easyrsa_path="$2"
    shift # past argument
    ;;

    -s|--s_name) # openvpn server name, used for naming files
    server_name="$2"
    shift # past argument
    ;;

    -c|--c_name) # openvpn client name, used for naming files
    client_name="$2"
    shift # past argument
    ;;

    -i|--i_path) # Where to save all related files: cert, key, config...
    install_path="$2"
    shift # past argument
    ;;

    -r|--remote) # Remote host/ip address for client connection
    host_name="$2"
    shift # past argument
    ;;

    -p|--port) # port for client connection
    port="$2"
    shift # past argument
    ;;

    -o|--openvpn_name) # openvpn_name; used in install path
	openvpn_name="$2"
	shift
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
# Step 2: Install easy-rsa if not found
if [ $step -lt 2 ]; then
	exit 0
fi

# Check if easy-rsa is in working directory
echo "${head_text} Checking easy-rsa in working directory: ${work_path} ..."

if [ -d "${work_path}/easy-rsa" ]; then
	echo "${head_text} easy-rsa found!"
	easyrsa_path="${work_path}/easy-rsa"
else

	# Check if easy-rsa is installed
	echo "${head_text} Checking if easy-rsa is installed..."
	install_script="openvpn_install-ubuntu.sh"

	dpkg -s easy-rsa > ${log_path}
	status=$?
	if [ $status != 0 ] && [ "$easyrsa_path" == "unknown" ]; then
		echo "${head_text} easyrsa is not installed or cannot be found. "
		echo "${head_text} Please install it using <${install_script}>. Or give the path of easy-rsa using -e"
		echo -e "\nIf it is Mac OS, please install openvpn USING Tunnelblick (NOT use the script <${install_script}>)"
		echo "On Mac, easyrsa path can be get using Tunnelblick -> [Utilities] -> [Open easy-rsa in terminal]"
		exit 1
	fi

	# Set easyrsa installation path if not given
	if [ "$easyrsa_path" == "unknown" ]; then
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
	cp -r "$easyrsa_path" "$work_path"
	status=$?
	if [ $status != 0 ]; then
		echo "${head_text} Failed to copy easy-rsa directory. Please check if you have the write privilege on path: ${work_path}"
		exit 1
	fi

	# Set easyrsa path to the copied one
	easyrsa_path="${work_path}/easy-rsa"
fi

#-----------------------------------------
# Step 3 Create installation directory for all config files
if [ $step -lt 3 ]; then
	exit 0
fi

# Check if install is already there
if [ -d "${install_path}" ]; then
	echo "$head_text ${install_path} already exists."
	echo "$head_text you can use -i to set a new install path"

	while true; do
    read -p "$head_text Continue will override the files in ${install_path}. Do you override files there?(y/n): " yn
    case $yn in
        [Yy]* )
		break
		;;

        [Nn]* )
		exit 1
		;;

        * ) 
		echo "$head_text Please answer y(yes) or n(no).";;
    esac
	done

else
	echo "$head_text Creating installation path ${install_path}"

	# Create install path
	mkdir -p "${install_path}"

	status=$?
	if [ $status != 0 ]; then
		echo "${head_text} Failed to create install path: ${install_path}. Please check if you have the privilege"
		exit 1
	fi

	mkdir -p "${install_path}/common" # ca file
	mkdir -p "${install_path}/server" # dh, ca, server.key, server.crt
	mkdir -p "${install_path}/client" # client.key, client.crt

	echo "${head_text} DONE!"


fi

#-----------------------------------------
# Step 4 Run according to $mode
if [ $step -lt 4 ]; then
	exit 0
fi


# Create config file according to mode
case "$mode" in
	"dh")
	cd $easyrsa_path
	func_generate_DH_parameters
   	;;

	"server_cert")
	cd $easyrsa_path
	func_generate_cert_server $server_name
	;;

	"client_cert")
	cd $easyrsa_path
	func_generate_cert_client $client_name
   	;;

   	"ca")
	cd $easyrsa_path
	func_generate_master_CA
   	;;

   	"server_cfg")
	func_generate_server_cfg "${server_name}.conf" ${server_name}
   	;;

   	"client_cfg")
	func_generate_client_cfg "${client_name}.conf" ${client_name} $host_name $port
   	;;

   	*) # Unknown option
    echo "Unknown option: $1"
    echo -e ${help_message}
    exit 1    
    ;;


esac








