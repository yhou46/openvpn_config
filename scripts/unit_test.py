import configFileEditor

def test_isComment():

	# Test 1
	count = 1
	# input
	line = "# jaklsfjklsdjfa;l"
	commentSymbol = ["#"]

	# output
	result = configFileEditor.isComment(line, commentSymbol)

	if result == True:
		print("TEST ", count, " passed")
	else:
		print("\nError Test ", count, ":\ninput: ", line, ", ", commentSymbol, "\noutput: ", result, "\nexpected: ", str(True), "\n")
	count += 1

	# Test 2
	# input
	line = "   # jaklsfjklsdjfa;l"
	commentSymbol = [" #"]

	# output
	result = configFileEditor.isComment(line, commentSymbol)

	if result == True:
		print("TEST ", count, " passed")
	else:
		print("\nError Test ", count, ":\ninput: ", line, ", ", commentSymbol, "\noutput: ", result, "\nexpected: ", str(True), "\n")
	count += 1

	# Test 3
	# input
	line = "# jaklsfjklsdjfa;l"
	commentSymbol = ["//"]

	# output
	result = configFileEditor.isComment(line, commentSymbol)

	if result != True:
		print("TEST ", count, " passed")
	else:
		print("\nError Test ", count, ":\ninput: ", line, ", ", commentSymbol, "\noutput: ", result, "\nexpected: ", str(False), "\n")
	count += 1

	# Test 4
	# input
	line = "// jaklsfjklsdjfa;l"
	commentSymbol = ["//"]

	# output
	result = configFileEditor.isComment(line, commentSymbol)

	if result == True:
		print("TEST ", count, " passed")
	else:
		print("\nError Test ", count, ":\ninput: ", line, ", ", commentSymbol, "\noutput: ", result, "\nexpected: ", str(True), "\n")
	count += 1

	# Test 5
	# input
	line = "/* jaklsfjklsdjfa;l"
	commentSymbol = ["//"]

	# output
	result = configFileEditor.isComment(line, commentSymbol)

	if result != True:
		print("TEST ", count, " passed")
	else:
		print("\nError Test ", count, ":\ninput: ", line, ", ", commentSymbol, "\noutput: ", result, "\nexpected: ", str(False), "\n")
	count += 1


	# Test 6
	# input
	line = "/* jaklsfjklsdjfa;l"
	commentSymbol = [""]

	# output
	result = configFileEditor.isComment(line, commentSymbol)

	if result != True:
		print("TEST ", count, " passed")
	else:
		print("\nError Test ", count, ":\ninput: ", line, ", ", commentSymbol, "\noutput: ", result, "\nexpected: ", str(False), "\n")
	count += 1

	# Test 7
	# input
	line = "/; jaklsfjklsdjfa;l"
	commentSymbol = ["//", ";"]

	# output
	result = configFileEditor.isComment(line, commentSymbol)

	if result != True:
		print("TEST ", count, " passed")
	else:
		print("\nError Test ", count, ":\ninput: ", line, ", ", commentSymbol, "\noutput: ", result, "\nexpected: ", str(False), "\n")
	count += 1


def test_addLineToBeginning():

	configFileEditor.addLineToBeginning("../test/test.doc", "hello\n", 
										commentSignList = ["#", ";"])

def test_replaceLineInFile():

	configFileEditor.replaceLineInFile("../test/test_doc.txt", 
										keyword = "replaced", 
										newLine = "replaced again", commentSign="", count = 2)



if __name__ == "__main__":
	
	#test_isComment() 

	test_addLineToBeginning()

	#test_replaceLineInFile()




