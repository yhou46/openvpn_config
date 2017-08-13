#!/bin/bash

# Stop server
function stop_vpn_server()
{
    # Check if openvpn is running
    if [[ $(pgrep openvpn) ]]; then

        echo "Stopping vpn server: openvpn..."
        killall -SIGINT openvpn

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
    openvpn ${config_path} &
    status=$?
    if [ $status != 0 ]; then
        echo "Failed to start openvpn server, exit..."
        exit 1
    fi

    # Check if server is up
    if [[ $(pgrep openvpn) ]]; then
        echo "Openvpn server started successfully!"
    else
        echo "Failed to start openvpn server, exit..."
        exit 1
    fi
    
}

# -------------
#### Main

# Cannot add "" to the path variable, don't know why???
config_path=~/bin/openvpn_cfg/default/server/openvpn_server1.conf

if [ $# -gt 0 ]; then
    if [ $1 == "stop" ]; then
        stop_vpn_server
    else
        if [ $1 == "help" ]; then
            echo "Help page:"
            echo -e "\trun_server.sh -> stop running openvpn server if possible and restart"
            echo -e "\trun_server.sh stop -> stop running openvpn server"
            echo -e "\trun_server.sh help -> show this help page"
            exit 0
        else
            echo "Unknown command: $1"
            echo "Please run <run_server.h help> to see the available commands"
            exit 1
        fi
    fi

else
    start_vpn_server $config_path
fi



