#!/bin/bash

#-----------------------------------------
# Global variables
output_path="." # Where the output compressed files should be
client_name="unknown" # Client name; All cfg files are named after client name

openvpn_name="default" 
install_path="${HOME}/bin/openvpn_cfg/${openvpn_name}" # Path of all config files

script_path="./install_client.sh" # Path of this script. Used when copy this script to compressed file
#-----------------------------------------
# Functions

# Fetch config files from installation path and compress them into 1 file
# $1 client name
# $2 path: where should the compressed file be put into
function fetch_files_from_path()
{

	# Get client name, all files will be named by client name
	if [ $# -gt 0 ] && [ $client_name != "unknown" ]; then
		client_name=$1
	else
		echo "Error: please give client name!"
		exit 1
	fi

	# Get output path if 2nd argument is given
	if [ $# -gt 1 ]; then
		output_path=$2
	fi

	# Make a temp directory to hold files
	## Check if temp directory exists
	temp_path="${output_path}/${client_name}"

	if [ -d ${temp_path} ]; then
  		echo "There is already a directory named <temp> in path: ${temp_path}"
  		while true; do
		    read -p "Continue will remove all contents in this directory: ${temp_path}. yes/no? (y/n): " yn
		    case $yn in
		        [Yy]* ) break;;
		        [Nn]* ) exit 1;;
		        * ) echo "$head_text Please answer y(yes) or n(no).";;
		    esac
		done
		echo "Cleaning up temp directory: ${temp_path}"
		rm -rf ${temp_path}
		echo "Done"
	fi

	## Create temp directory
	mkdir -p "${temp_path}"

	status=$?
	if [ $status != 0 ]; then
		echo "${head_text} Failed to create install path: ${install_path}. Please check if you have the privilege"
		exit 1
	fi

	# Copy all files to temp directory
	echo "Copying necessary files to temp directory..."
	
	## ca.crt,  ca.key
	cp "${install_path}/common/ca.crt" "${temp_path}/"
	status=$?
	if [ $status != 0 ]; then
		echo "Failed to copy file: ${install_path}/common/ca.crt"
		exit 1
	fi

	cp "${install_path}/common/ca.key" "${temp_path}/"
	status=$?
	if [ $status != 0 ]; then
		echo "Failed to copy file: ${install_path}/common/ca.key"
		exit 1
	fi

	## client.key, client.crt client.conf
	cp "${install_path}/client/${client_name}.key" "${temp_path}/"
	status=$?
	if [ $status != 0 ]; then
		echo "Failed to copy file: ${install_path}/client/${client_name}.key"
		exit 1
	fi

	cp "${install_path}/client/${client_name}.crt" "${temp_path}/"
	status=$?
	if [ $status != 0 ]; then
		echo "Failed to copy file: ${install_path}/client/${client_name}.crt"
		exit 1
	fi

	cp "${install_path}/client/${client_name}.conf" "${temp_path}/"
	status=$?
	if [ $status != 0 ]; then
		echo "Failed to copy file: ${install_path}/client/${client_name}.conf"
		exit 1
	fi

	# copy this script
	cp "${script_path}" "${temp_path}/"
	status=$?
	if [ $status != 0 ]; then
		echo "Failed to copy file: ${script_path}"
		exit 1
	fi
	
	# Compress temp directory
	echo "Compressing files and generate package..."
	tar -czvf "${output_path}/${client_name}.tar.gz" "${temp_path}"
	status=$?
	if [ $status != 0 ]; then
		echo "Failed to compress folder: ${temp_path}"
		exit 1
	fi

	# Remove temp directory
	rm -rf ${temp_path}
	status=$?
	if [ $status != 0 ]; then
		echo "Failed to remove temporary folder: ${temp_path}"
		exit 1
	fi

	# Indicate success
	echo "Success!. Fetching files done."
	echo "Generated compressed file is in path: ${output_path}/${client_name}.tar.gz"

}



#-----------------------------------------
# Main

## Define help_message
read -r -d '' help_message <<- EOM
usage: $0 -m/--mode MODE [-c/--client_name] [-o/--output_path]\n
arguments:\n
\t-m/--mode: {fetch}\n
\t\t fetch: get all client config files and compress them into one, used with -c(required), -o(optional)\n

\t-c/--client_name: client name\n
\t-o/--output_path: output file path\n
\t-h/--help: show this help page\n

EOM

# Get the path of the script
script_path=$0

# Check if no arguments are given
if [ $# -lt 1 ]; then
	echo "Error: no arguments given!"
	echo -e ${help_message}
fi

## Parse command line arguments
while [[ $# -gt 0 ]]
do
key="$1"

case $key in

    -m|--mode) # mode
    mode="$2"
    shift # past argument
    ;;

    -c|--client_name) # Where to save all related files: cert, key, config...
    client_name="$2"
    shift # past argument
    ;;

    -o|--output_path) # Where to save all related files: cert, key, config...
    output_path="$2"
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

# Run according to mode
case "$mode" in
	
	"fetch")
		if [ $client_name == "unknown" ]; then
			echo "Error: please give client name using -c"
			echo -e ${help_message}
			exit 1
		fi
		fetch_files_from_path ${client_name} ${output_path}
   	;;

	"install")
		# Need to add function
	;;

	"reset")
		# Need to add function
	;;

	"uninstall")
		# Need to add function
	;;

   	*) # Unknown option
    echo "Unknown option: $1"
    echo -e ${help_message}
    exit 1    
    ;;


esac






