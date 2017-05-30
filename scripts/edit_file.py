#!/usr/bin/python3
import codecs

# TODO: cannot handle if # mark is not the 1st character of the line
# Change file content to enable ipv4 forwarding
# key is to make "net.ipv4.ip_forward=1"
def enableIpv4Forwarding(filename):

	lines = ""
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

	
# TODO: add command line parser
if __name__ == "__main__":
	
	enableIpv4Forwarding("./backup/sysctl.conf")

	#changeUfwBeforeRules("test", "eth0")




