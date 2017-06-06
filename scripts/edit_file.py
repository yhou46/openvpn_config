#!/usr/bin/python3
import codecs
import argparse
import sys

#-------------------------------------------------
# Constants
#-------------------------------------------------
argsMode = \
{ 
    "ipv4_mode": "ipv4", 
    "ufw_mode": "ufw",
}


#-------------------------------------------------
# Functions
#-------------------------------------------------

# TODO: cannot handle if # mark is not the 1st character of the line
# Change file content to enable ipv4 forwarding
# key is to make "net.ipv4.ip_forward=1"
def enableIpv4Forwarding(filename):

    lines = []
    with codecs.open(filename, "r+", "utf-8") as file:
        lines = file.readlines()

    enableKeyword = "net.ipv4.ip_forward=1"
    disableKeyword = "net.ipv4.ip_forward=0"

    # TODO: not a good way to do this, need to change
    newFileLines = []
    isEnableChanged = False
    for line in lines:
        if enableKeyword in line:
            if line[0] == "#":
                newFileLines.append(enableKeyword + "\n")
            else:
                newFileLines.append(line)
            isEnableChanged = True

        elif disableKeyword in line and line[0] == "#":
            newFileLines.append(line)
        else:
            newFileLines.append(line)

    # if no enableKeywork is found, add it to the end of file
    if not isEnableChanged:
        newFileLines.append(enableKeyword + "\n")

    with codecs.open(filename, "w", "utf-8") as file:
        file.writelines(newFileLines)

    return

def changeUfwBeforeRules(filename, publicInterfaceName):
    insertLine = "\n# START OPENVPN RULES\n" + \
                    "# NAT table rules\n" + \
                    "*nat\n" + \
                    ":POSTROUTING ACCEPT [0:0]\n" + \
                    "# Allow traffic from OpenVPN client to " + publicInterfaceName + "\n" + \
                    "-A POSTROUTING -s 10.8.0.0/8 -o " + publicInterfaceName + \
                    " -j MASQUERADE\n" + \
                    "COMMIT\n" + \
                    "# END OPENVPN RULES\n\n"

    lines = ""
    with codecs.open(filename, "r+", "utf-8") as file:
        lines = file.readlines()


    # Insert the new text right after the first empty new line
    newFileLines = []
    for line in lines:
        newFileLines.append(line)
        if line[0] == "\n":
            newFileLines.append(insertLine)

    with codecs.open(filename, "w", "utf-8") as file:
        file.writelines(newFileLines)

def initializeCommandParser():
    
    parser = argparse.ArgumentParser(description = "Change config files for openvpn installation")

    parser.add_argument( "-m", "--mode", type=str, required=True, choices=argsMode.values(),
                         help="Mode for this script")
    parser.add_argument( "-f", "--file", type=str, required=True, help="File name for the change")

    parser.add_argument( "-p", "--pub", type=str, help="Public Interface Name")


    # parser.add_argument('--sum', dest='accumulate', action='store_const',
    #                 const=sum, default=max,
    #                 help='sum the integers (default: find the max)')
    return parser

def main(inputArgs):

    # Initialize command line parser and parse
    parser = initializeCommandParser()
    parsedArgs = parser.parse_args(inputArgs)

    filename = ""
    publicInterfaceName = "eth0"

    if parsedArgs.file != None:
        filename = parsedArgs.file

    if parsedArgs.pub != None:
        publicInterfaceName = parsedArgs.pub

    if parsedArgs.mode == argsMode.get("ipv4_mode"):
        enableIpv4Forwarding(filename)
    elif parsedArgs.mode == argsMode.get("ufw_mode"):
        changeUfwBeforeRules(filename, publicInterfaceName)


# TODO: add command line parser
if __name__ == "__main__":
    
    
    main(sys.argv[1:])



    #enableIpv4Forwarding("./backup/sysctl.conf")

    #changeUfwBeforeRules("test", "eth0")




