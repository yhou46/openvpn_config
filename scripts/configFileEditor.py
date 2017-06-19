#!/usr/bin/python3
import codecs
import argparse
import sys


# Replace the line including the keyword with the new line
# Comment line will not be affected
# 
# arguments:
# @filename: input file name
# @keyword: the word use for search in file, if found, will replace the target line with new line
# @newLine: the new line of string used for replacement, note a "\n" is needed
# @commentSign: the comment sign used to mark the line as comment, empty string means no comments in files
# @count: number of replacements. The replacement will perform <count> times, counting from start of the file; 
#         count = -1 means replace all of them; count = 0 means no replacement
#
# return:
# return the number of replacement happened
def replaceLineInFile(filename, keyword, newLine, commentSignList=[], count = -1):
    
    replacedCount = 0

    with codecs.open(filename, "r+", "utf-8") as file:
        lines = file.readlines()

        newFileLines = []
        for line in lines:
            if ( not isComment(line, commentSignList) ) and (keyword in line) and (count != 0):
                
                newFileLines.append( newLine + "\n" )
                count -= 1
                replacedCount += 1
                
            else:
                newFileLines.append(line)

    # Write to file
    with codecs.open(filename, "w", "utf-8") as file:
        file.writelines(newFileLines)

    return replacedCount


# Check if the line is a comment
#
# arguments:
# @line: the input line of text
# @commentSignList: the comment sign list used to mark the line as comment, empty list means no comments in files
#               <commentSign> in <commentSignList> will be trimmed first(empty spaces of the beginning and end will be removed)
#               e.g. ["#",";"]
def isComment(line, commentSignList):
    newLine = line.strip() # remove white spaces

    for commentSign in commentSignList:

        commentSign = commentSign.strip() # remove white spaces

        if len(commentSign) == 0:
            continue

        commentSignLength = len(commentSign)

        if newLine[0: commentSignLength] == commentSign:
            return True
    return False

# Skip the comment and add the <newLine> to the first non-comment line of the file
# 
# arguments:
# @filename: input file name
# @newLine: the new line of string used for replacement, note a "\n" is needed
# @commentSign: the comment sign used to mark the line as comment, empty string means no comments in files
def addLineToBeginning(filename, newLine, commentSignList = ["#"]):
    
    lines = []
    with codecs.open(filename, "r+", "utf-8") as file:
        lines = file.readlines()

        newFileLines = []

        isNewLineInserted = False
       
        for line in lines:

            # if not comment, insert the line
            if ( not isComment(line, commentSignList) ) and ( not isNewLineInserted ):
                newFileLines.append( newLine + "\n" )
                isNewLineInserted = True
            newFileLines.append(line)

        if not isNewLineInserted:
            newFileLines.append( newLine + "\n" )

    # Write to file
    with codecs.open(filename, "w", "utf-8") as file:
        file.writelines(newFileLines)

    return

# From end to beginning, skip the comment and add the <newLine> to the last non-comment line of the file
# 
# arguments:
# @filename: input file name
# @newLine: the new line of string used for replacement, note a "\n" is needed
# @commentSign: the comment sign used to mark the line as comment, empty string means no comments in files
def addLineToEnd(filename, newLine, commentSign = "#"):
    pass




