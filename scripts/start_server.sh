#!/bin/bash

# Stop server
function stop_vpn_server()
{
	# Check if openvpn is running
	if [[ $(pgrep openvpn) ]]; then
    	echo "Stopping vpn server: openvpn..."
    	killall -SIGINT openvpn

    	# Check if it is stopped
    	if [[ $(pgrep openvpn) ]]; then
    		echo "Error: Failed to stop openvpn server..."
    		exit 1
    	fi

	else
	    echo "No openvpn server is running, exit..."
	fi
}

# Start server

# Main
stop_vpn_server