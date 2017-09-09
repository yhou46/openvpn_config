#!/bin/bash

#--------------
#### Global variables

# All server config files
# Cannot add "" to the path variable, don't know why???
# Just for reference
tcp_server_config_path=~/bin/openvpn_cfg/default/server/openvpn-server-aws.conf
udp_server_config_path=~/bin/openvpn_cfg/default/server/openvpn-server-aws-udp.conf

#--------------
#### All functions

# Stop all servers
function stop_all_vpn_servers()
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

# Stop openvpn server with the config file
# $1 config file path
function stop_vpn_server()
{
    config_path=$1

    # Get pid of the target process if any
    server_pid=$(pgrep -a openvpn | grep ${config_path} | awk '{ print $1; }') 

    echo "server pid is ${server_pid}"

    # Check if openvpn is running
    if [[ ! -z ${server_pid} ]]; then

        echo "Stopping vpn server with config file: ${config_path}..."
        kill -SIGINT ${server_pid}

        # Sleep for 2 seconds and waiting for server to stop
        sleep 2

        # Check if it is stopped
        if [[ $(pgrep -a openvpn | grep ${config_path}) ]]; then
            echo "Error: Failed to stop openvpn server..."
            exit 1
        fi

    else
        echo "Openvpn server is already down..."
    fi
}


# Restart server
# $1 path to server config file
function restart_vpn_server()
{
    config_path=$1

    # Stop server first
    stop_vpn_server ${config_path}

    # Start server
    echo "Starting openvpn server..."
    openvpn ${config_path} &
    status=$?
    if [ $status != 0 ]; then
        echo "Failed to start openvpn server, exit..."
        exit 1
    fi

    # Check if server is up
    if [[ $(pgrep -a openvpn | grep ${config_path}) ]]; then
        echo "Openvpn server started successfully!"
    else
        echo "Failed to start openvpn server, exit..."
        exit 1
    fi
}


#--------------
#### Main

# Read arguments and parse
if [ $# -gt 0 ]; then

    case $1 in

        "stopall")
            echo "All openvpn servers will be stopped..."
            stop_all_vpn_servers
        ;;

        "stop")
            if [ $# -gt 1 ]; then
                config_path=$2
                stop_vpn_server $config_path
            else
                echo "Missing config file path"
                echo "Please run like this: <run_server.h stop config_path>"
                echo "Please run <run_server.h help> for details"
                exit 1
            fi
        ;;

        "start")
            if [ $# -gt 1 ]; then
                config_path=$2
                restart_vpn_server $config_path
            else
                echo "Missing config file path"
                echo "Please run like this: <run_server.h start config_path>"
                echo "Please run <run_server.h help> for details"
                exit 1
            fi
        ;;

        "help")
            echo "Help page:"
            echo -e "\trun_server.sh start <config_path>: start running server with config file"
            echo -e "\trun_server.sh stop <config_path>: stop running openvpn servers with config file"
            echo -e "\trun_server.sh stopall: stop all running openvpn servers"
	    echo -e "\trun_server.sh help -> show this help page"
            exit 0
        ;;

        *) # Unknown option
            echo "Unknown command: $1"
            echo "Please run <run_server.h help> to see the available commands"
            exit 1    
        ;;

    esac
else
    echo "Missing necessary arguments"
    echo "Please run <run_server.h help> for details"
fi



