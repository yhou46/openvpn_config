#!/bin/bash

# Stop server
function stop_vpn_server()
{
    # Check if openvpn is running
    if [[ $(pgrep openvpn) ]]; then

        echo "Stopping vpn server: openvpn..."
        sudo killall -SIGINT openvpn

        # Sleep for 2 seconds and waiting for server to stop
        sleep 2

        # Check if it is stopped
        if [[ $(pgrep openvpn) ]]; then
                echo "Error: Failed to stop openvpn server..."
                exit 1
        fi

    else
        echo "Openvpn server is already down..."
    fi
}


# Start server
# $1 path to server config file
function start_vpn_server()
{
    config_path=$1

    # Stop server first
    stop_vpn_server

    # Start server
    echo "Starting openvpn server..."
    sudo openvpn ${config_path}
    status=$?
    if [ $status != 0 ]; then
        echo "Failed to start openvpn server, exit..."
        exit 1
    fi
}

# -------------
#### Main

# Cannot add "" to the path variable, don't know why???
config_path=~/bin/openvpn_cfg/default/server/openvpn_server1.conf

if [ $# -gt 0 ] && [ $1 == "stop" ]; then
    stop_vpn_server
else
    start_vpn_server $config_path
fi



