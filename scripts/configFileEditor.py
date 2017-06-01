
# Replace the line including the keyword with the new line, 
# Comment line will not be affected;
def replaceLineInFile(filename, keyword, newLine, commentSign=""):
    pass

# Check if the line is a comment
# Comment means the first symbol(s) is the comment sign (doesn't count white spaces)
def isComment(line, commentSign):
    pass

# Add the line to the beginningof the file
# If skipComment is true, then will add the new line after the first group of comments (comments without any effective statement, e.g. multiple lines of comment)
def addLineToBeginning(filename, newLine, skipComment = True):
    pass

# Add line to the end of the file
# If skipComment is true, then will add the new line right before the last group of comments
def addLineToEnd(filename, newLine, skipComment = True):
    pass
