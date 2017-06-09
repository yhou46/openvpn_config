#!/bin/bash
# generate openvpn server and client config file

#-----------------------------------------
# Debug variable
step=2

#-----------------------------------------
# Global variables
mode="unknown"
easyrsa_path="unknown"
work_path="./"

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
\t-m/--mode {server, client}\n
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

    # -l|--lib)
    # LIBPATH="$2"
    # shift # past argument
    # ;;

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

# Check if openvpn is installed
install_script="openvpn_install-ubuntu.sh"

which openvpn
status=$?
if [ $status != 0 ] && [ $easyrsa_path == "unknown" ]; then
	echo "Openvpn is not installed or cannot be found. "
	echo "Please install it using <${install_script}>. Or give the path of easy-rsa using -p"
	echo -e "\nIf it is Mac OS, please install openvpn USING Tunnelblick (NOT use the script <${install_script}>)"
	echo "easyrsa path can be get using Tunnelblick -> [Utilities] -> [Open easy-rsa in terminal]"
	exit 1
fi

# Set easyrsa path according to openvpn installation path
if [ $status == 0 ]; then
	$easyrsa_path="$(which openvpn)/easy-rsa"
fi

# Check if easy-rsa exists
directory=$(basename ${easyrsa_path})

if [ $directory != "easy-rsa" ] || [ ! -d "$easyrsa_path" ]; then
	echo "Invalid easy-rsa path: ${easyrsa_path}"
	echo "It does exists or is not named like this: easy-rsa"
	echo "Please give the path of easy-rsa like /usr/share/doc/packages/openvpn/easy-rsa"
	exit 1
fi

# Copy easy-rsa to working path
cp -r $easyrsa_path $work_path
status=$?
if [ $status != 0 ]; then
	echo "Failed to copy easy-rsa directory. Please check if you have the write privilege on path: ${work_path}"
	exit 1
fi

#-----------------------------------------
# Step 3
if [ $step -lt 3 ]; then
	exit 0
fi

# Create config file according to mode

echo Success







