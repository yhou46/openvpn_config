#!/bin/bash

#-----------------------------------------
# Global variables
output_path="." # Where the output compressed files should be

client_name="unknown" # Client name; All cfg files are named after client name
is_client_name_set=false

openvpn_name="default" 
is_openvpn_name_set=false

install_path="${HOME}/bin/openvpn_cfg" # Path of all config files
is_install_path_set=false

script_path="./install_client.sh" # Path of this script. Used when copy this script to compressed file
#-----------------------------------------
# Functions

# Fetch config files from installation path and compress them into 1 file
# $1 client name; required
# $2 path: where should the compressed file be put into; optional
# $3 openvpn_name: optional
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

	# Get openvpn name if given
	if [ $# -gt 2 ]; then
		openvpn_name=$3
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
		echo "Failed to create temp path: ${temp_path}. Please check if you have the privilege"
		exit 1
	fi

	# Copy all files to temp directory
	echo "Copying necessary files to temp directory..."
	
	## ca.crt
	cp "${install_path}/${openvpn_name}/common/ca.crt" "${temp_path}/"
	status=$?
	if [ $status != 0 ]; then
		echo "Failed to copy file: ${install_path}/common/ca.crt"
		exit 1
	fi

	## client.key, client.crt client.conf
	cp "${install_path}/${openvpn_name}/client/${client_name}.key" "${temp_path}/"
	status=$?
	if [ $status != 0 ]; then
		echo "Failed to copy file: ${install_path}/client/${client_name}.key"
		exit 1
	fi

	cp "${install_path}/${openvpn_name}/client/${client_name}.crt" "${temp_path}/"
	status=$?
	if [ $status != 0 ]; then
		echo "Failed to copy file: ${install_path}/client/${client_name}.crt"
		exit 1
	fi

	# For config files for IOS openvpn app, postfix must be *.ovpn; So change the file postfix when copied
	cp "${install_path}/${openvpn_name}/client/${client_name}.conf" "${temp_path}/${client_name}.ovpn"
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

# Create installzation path if not exists
# $1 openvpn_name; optional
# $2 install_path; optional
function init_install_path()
{

	# Set openvpn_name if given
	if [ $# -gt 0 ]; then
		openvpn_name=$1
	fi

	# Set install_path if given
	if [ $# -gt 1 ]; then
		install_path=$2
	fi

	# Check if install is already there
	if [ -d "${install_path}/${openvpn_name}" ]; then
		echo "${install_path} already exists."
	else
		echo "Creating installation path ${install_path}/${openvpn_name}..."

		# Create install path
		mkdir -p "${install_path}/${openvpn_name}"

		status=$?
		if [ $status != 0 ]; then
			echo "Failed to create install path: ${install_path}/${openvpn_name}. Please check if you have the privilege"
			exit 1
		fi

		mkdir -p "${install_path}/${openvpn_name}/common" # ca file
		mkdir -p "${install_path}/${openvpn_name}/client" # client.key, client.crt

		# Below is only for server
		# mkdir -p "${install_path}/${openvpn_name}/server" # dh, ca, server.key, server.crt

		echo "Success!"
	fi
}

# Clean everything under install path
# $1 openvpn_name; required
# $2 install_path; required
function clean_install_path()
{
	# Get openvpn server name
	if [ $# -gt 0 ]; then
		openvpn_name=$1
	else
		echo "Error: please give openvpn name!"
		exit 1
	fi

	# Get install_path
	if [ $# -gt 1 ]; then
		install_path=$2
	else
		echo "Error: please give install_path name!"
		exit 1
	fi

	# Check if install path exists
	if [ -d "${install_path}/${openvpn_name}" ]; then
		
		# Confirm user with the clean up
		while true; do
		    read -p "Continue will delete all files under path: ${install_path}/${openvpn_name}. yes/no? (y/n): " yn
		    case $yn in
		        [Yy]* ) break;;
		        [Nn]* ) exit 1;;
		        * ) echo "$head_text Please answer y(yes) or n(no).";;
		    esac
		done

		# Clean
		echo "Cleaning..."
		rm -rf "${install_path}/${openvpn_name}"
		status=$?
		if [ $status != 0 ]; then
			echo "Failed to clean path: ${install_path}/${openvpn_name}"
			exit 1
		fi
		echo "Success!"

	else
		echo "${install_path}/${openvpn_name} does not exist. No need to clean."
	fi
}

# Reset: Clean install path and create path again
# $1 openvpn_name; required
# $2 install_path; required
function reset_install_path()
{
	# Get openvpn server name
	if [ $# -gt 0 ]; then
		openvpn_name=$1
	else
		echo "Error: please give openvpn name!"
		exit 1
	fi

	# Get install_path
	if [ $# -gt 1 ]; then
		install_path=$2
	else
		echo "Error: please give install_path name!"
		exit 1
	fi

	clean_install_path $openvpn_name $install_path
	init_install_path $openvpn_name $install_path

	echo "Reset success!"
}

# Install cfg files to install path
# $1 client_name; required
# $2 openvpn_name; optional
# $3 install_path; optional
function install_cfg_to_path()
{
	# Get client name
	if [ $# -gt 0 ] && [ $client_name != "unknown" ]; then
		client_name=$1
	else
		echo "Error: please give client name!"
		exit 1
	fi	

	# Get openvpn server name
	if [ $# -gt 1 ]; then
		openvpn_name=$2
	fi

	# Get install_path
	if [ $# -gt 2 ]; then
		install_path=$3
	fi

	# Confirm with user about the installation path
	while true; do
	    read -p "Continue will install files to path: ${install_path}/${openvpn_name}. yes/no? (y/n): " yn
	    case $yn in
	        [Yy]* ) break;;
	        [Nn]* ) exit 1;;
	        * ) echo "$head_text Please answer y(yes) or n(no).";;
	    esac
	done

	# Init install path
	init_install_path $openvpn_name $install_path

	# Copy file to install path;
	echo "Installing..."
	
	## ca.crt,  ca.key
	cp "./ca.crt" "${install_path}/${openvpn_name}/common/ca.crt"
	status=$?
	if [ $status != 0 ]; then
		echo "Failed to copy file: ./ca.crt to path: ${install_path}/${openvpn_name}/common/"
		exit 1
	fi

	## client.key, client.crt client.conf
	cp "./${client_name}.key" "${install_path}/${openvpn_name}/client/"
	status=$?
	if [ $status != 0 ]; then
		echo "Failed to copy file: ./${client_name}.key to path: ${install_path}/${openvpn_name}/client/"
		exit 1
	fi

	cp "./${client_name}.crt" "${install_path}/${openvpn_name}/client/"
	status=$?
	if [ $status != 0 ]; then
		echo "Failed to copy file: ./${client_name}.crt to path: ${install_path}/${openvpn_name}/client/"
		exit 1
	fi

	cp "./${client_name}.conf" "${install_path}/${openvpn_name}/client/"
	status=$?
	if [ $status != 0 ]; then
		echo "Failed to copy file: ${client_name}.conf to path: ${install_path}/${openvpn_name}/client/"
		exit 1
	fi

	echo "Success!"
}

#-----------------------------------------
# Main

## Define help_message
read -r -d '' help_message <<- EOM
usage: $0 -m/--mode MODE [-c/--client_name] [-o/--output_path]\n
arguments:\n
\t-m/--mode: {fetch, install, reset, uninstall}\n
\t\t fetch: get all client config files and compress them into one, used with -c(required), -o(optional), -s(optional)\n
\t\t install: install client config files to install_path, used with -c(required), -s(optional), -i(optional)\n
\t\t reset: remove all config files under {install_path}/{openvpn_name} and re-create the folders; Be careful!
			used with -i(required), -s(required)\n
\t\t uninstall: remove all config files under {install_path}/{openvpn_name}; Be careful! 
				used with -i(required), -s(required)\n

\t-c/--client_name: client name\n
\t-o/--output_path: output file path\n
\t-s/--openvpn_name: openvpn_name used in install path; 
					 All files belonging to this openvpn will be saved under {install_path}/{openvpn_name}\n
\t-i/--install_path: installation path for all config files\n

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

    -c|--client_name) # client name
    client_name="$2"
    is_client_name_set=true
    shift # past argument
    ;;

    -s|--openvpn_name) # group of openvpn name; Unique ca files for each group
    openvpn_name="$2"
    is_openvpn_name_set=true
    shift # past argument
    ;;

    -i|--install_path) # Install path
    install_path="$2"
    is_install_path_set=true
    shift # past argument
    ;;

    -o|--output_path) # Where the generated file is saved
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
		# Check if client name is given
		if [ $is_client_name_set == false ]; then
			echo "Error: please give client name using -c"
			echo -e ${help_message}
			exit 1
		fi
		fetch_files_from_path ${client_name} ${output_path} ${openvpn_name}
   	;;

	"install")
		# Check if client name is given
		if [ $is_client_name_set == false ]; then
			echo "Error: please give client name using -c"
			echo -e ${help_message}
			exit 1
		fi
		install_cfg_to_path $client_name $openvpn_name $install_path
	;;

	"reset")
		if [ $is_openvpn_name_set == false ] || [ $is_install_path_set == false ]; then
			echo "Error: please give openvpn_name and install_path. See -h for details"
			echo -e ${help_message}
			exit 1
		fi
		reset_install_path $openvpn_name $install_path
	;;

	"uninstall")
		if [ $is_openvpn_name_set == false ] || [ $is_install_path_set == false ]; then
			echo "Error: please give openvpn_name and install_path. See -h for details"
			echo -e ${help_message}
			exit 1
		fi
		clean_install_path $openvpn_name $install_path
	;;

   	*) # Unknown option
    echo "Unknown option: $1"
    echo -e ${help_message}
    exit 1    
    ;;


esac






