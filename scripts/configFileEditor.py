#!/usr/bin/python3
import codecs
import argparse
import sys


# Replace the line including the keyword with the new line
# Comment line will not be affected;
# count means the number of times of replacement if found
# count = -1 means replace all of them; count = 0 means no replacement
def replaceLineInFile(filename, keyword, newLine, commentSign="", count = -1):
    
    with codecs.open(filename, "r+", "utf-8") as file:
        lines = file.readlines()

        newFileLines = []
        for line in lines:
            if ( not isComment(line, commentSign) ) and (keyword in line) and (count != 0):
                
                newFileLines.append(newLine)
                count -= 1
                
            else:
                newFileLines.append(line)

    # Write to file
    with codecs.open(filename, "w", "utf-8") as file:
        file.writelines(newFileLines)

    return


# Check if the line is a comment
# Comment means the first symbol(s) is the comment sign (doesn't count white spaces)
def isComment(line, commentSign):
    newLine = line.strip() # remove white spaces
    commentSign = commentSign.strip() # remove white spaces

    if len(commentSign) == 0:
        return False

    commentSignLength = len(commentSign)

    if newLine[0: commentSignLength] == commentSign:
        return True
    else:
        return False

# Add the newLine to the beginning of the file
# Note the newLine should include "\n"
# If skipComment is true, then will add the new line after the first group of comments (comments without any effective statement, e.g. multiple lines of comment)
def addLineToBeginning(filename, newLine, skipComment = True, commentSign = "#"):
    
    lines = []
    with codecs.open(filename, "r+", "utf-8") as file:
        lines = file.readlines()

        newFileLines = []

        isNewLineInserted = False
        if skipComment == True:
            for line in lines:

                # if not comment, insert the line
                if ( not isComment(line, commentSign) ) and ( not isNewLineInserted ):
                    newFileLines.append(newLine)
                    isNewLineInserted = True
                newFileLines.append(line)

            if not isNewLineInserted:
                newFileLines.append(newLine)

        else:
            newFileLines.append(newLine)
            newFileLines.extend(lines)

    # Write to file
    with codecs.open(filename, "w", "utf-8") as file:
        file.writelines(newFileLines)

    return


# Add line to the end of the file
# If skipComment is true, then will add the new line right before the last group of comments
def addLineToEnd(filename, newLine, skipComment = True, commentSign = "#"):
    pass




