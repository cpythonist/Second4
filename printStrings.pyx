# Second 4.0 source code
# 
# Filename: printStrings.pyx
# Brief description: Contains collection of large strings that are too bulky to put
#                    in the main program.
# 
# This software is a product of Infinite, Inc., and was written by
# CPythonist (cpythonist.github.io) of the development team of Infinite, Inc.
# 
# 
# Copyright 2024 Infinite Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
# 
# Please refer https://cpythonist.github.io/second/documentation/secondDoc4.0.html
# for documentation.
# Please report any bugs using the email address in https://cpythonist.github.io/contact.html.
# 


def getHelpString(helpStr: dict): # Forms the print string for HELP.
        line = f"**__COMMAND##**      __FUNCTION##"
        count = 0
        for key in helpStr:
            if not count%3:
                line += f"\n{key:<15}##{helpStr[key]}"
            elif count%3 == 1:
                line += f"\n!!{key:<15}##!!{helpStr[key]}##"
            elif count%3 == 2:
                line += f"\n**{key:<15}##**{helpStr[key]}##"
            count += 1
        return line


class Base: # Contains print strings for base.py

    helpStrings = {
        "&&CD": "Changes the current working direcory (CWD).",
        "&&CLS": "Clears the screen.",
        "&&COMMAND": "Executes a terminal command.",
        "&&COPY": "Copies file/directory to another directory",
        "&&COPYRIGHT": "Displays the copyright information of Second.",
        "&&CREDITS": "Displays the credits information of Second.",
        "&&DATE": "Displays today's date.",
        "&&DEL": "Deletes a file/directory.",
        "&&DIR": "Displays the files and directories one level inside a directory.",
        "&&EXIT": "Terminates Second.",
        "&&GREET": "Greets the user.",
        "&&HELP": "Displays this help menu and help outputs of other commands.",
        "&&KILL": "Terminates the given process(es).",
        "&&MKDIR": "Creates a new directory.",
        "&&PROMPT": "Changes the prompt variable.",
        "&&QUIT": "Quits Second.",
        "&&SECOND": "Displays version compatibility and author.",
        "&&START": "Opens a file/directory.",
        "&&TIME": "Displays current time.",
        "&&TITLE": "Changes the title of the window.",
        "&&TREE": "Displays a tree of all files and subdirectories inside a directory."
    }
    help = f"""&&HELP:## **Info:##

{getHelpString(helpStrings)}

&&**1.## In case a terminal command and Second command names clash, the Second command is given preference and executed.
&&**2.## Commands are case-insensitive.

"""
    
    secondFormatted = """&&SECOND:## **Info:##

&&**Second 4.0##
Developed by Infinite, Inc.
Developer: CPythonist (__http://cpythonist.github.io/##)
License: Apache-2.0 (__http://www.apache.org/licenses/LICENSE-2.0##)

CPython version used for development: &&!!3.11.6##
Nuitka version used for compilation to binary: &&!!2.0.6##
Inno Setup version used for installer archive: &&!!6.2.2##

Operating system: &&**Windows##
Windows version: &&**10, 11##

To get the source code, visit __http://github.com/cpythonist/Second4##.
To get the documentation, visit __http://cpythonist.github.io/second/documentation/secondDoc4.0.html##.
"""

    secondUnformatted = """Second 4.0
Developed by Infinite, Inc.
Developer: CPythonist (http://cpythonist.github.io/)
License: Apache-2.0 (http://www.apache.org/licenses/LICENSE-2.0)

Development CPython version: 3.11.6
Nuitka version used for compilation to binary: 2.0.6
Inno Setup version used for installer archive: 6.2.2

Operating system: Windows
Windows version: 10, 11
"""

    helpCd = """
!!Changes the current working directory.##

&&__Syntax:##
    CD path

    ^^path##    Directory to change into.
"""

    helpCls = """
!!Clears the output screen.##

&&__Syntax:##
    CLS
"""

    helpCommand = """
!!Runs terminal commands on Second.##

&&__Syntax:##
    COMMAND command

    ^^command## -> Command to execute in terminal.
"""

    helpCopy = """
!!Copies a file/directory to another directory.##

&&__Syntax:##
    COPY source dest

    ^^source## -> Path of source file/directory on the computer.
    ^^dest## -> Destination directory for copying source into.
"""

    helpCopyright = """
!!Displays the copyright information on Second.##

&&__Syntax:##
    COPYRIGHT
"""
    
    helpCredits = """
!!Displays the credits information on Second.##

&&__Syntax:##
    CREDITS
"""

    helpDate = """
!!Displays the current system date.##

&&__Syntax:##
    DATE
"""

    helpDel = """
!!Deletes a file/directory.##

&&__Syntax:##
    DEL path

    ^^path## -> Path of file/directory to be deleted.
"""

    helpDir = """
!!Displays the files and directories one level inside a directory.##

&&__Syntax:##
    DIR dir

    ^^dir## -> Directory which needs to be examined.
"""

    helpEof = """
!!Exits the program.##

&&__Syntax:##
    ^Z (CTRL+Z)
"""

    helpExit = """
!!Exits the program.##

&&__Syntax:##
    EXIT
"""

    helpGreet = """
!!Greets the user.##

&&__Syntax:##
    GREET [option]

    ^^option## -> Specify option to greet the user.
        1 - Greet option 1 (default)
        2 - Greet option 2
"""

    helpHelp = """
!!Displays help menu.##

&&__Syntax:##
    HELP [command]

    ^^command## -> Displays help for command with the name "command".
"""

    helpKill = """
!!Kills the specified process.##

&&__Syntax:##
    KILL process [-f] [-c]

    ^^process## -> Process name or process ID to be killed
    ^^-f##      -> Kill the process forcefully
    ^^-c##      -> Kill the process and all of its child processes
"""

    helpMkdir = """
!!Creates a new directory.##

&&__Syntax:##
    MKDIR newdir

    ^^newdir## -> Directory name for the new directory (relative or full path, or just directory name)
"""

    helpPrompt = """
!!Changes the prompt variable of the program.##

&&__Syntax:##
    PROMPT prompt*

    ^^prompt## -> New prompt for Second
        %U - Username
        %S - OS name
        %R - Release number
        %P - Path (current working directory)
        %% - Percentage sign

* **Note:## If the program is running in a terminal WITHOUT ANSI support, 
        ANSI escape codes are removed from the given data for displaying the prompt,
        but are stored in settings.dat.
"""

    helpQuit = """
!!Quits the program.##

&&__Syntax:##
    QUIT
"""

    helpSecond = """
!!Displays the developer and operating system information of Second 4.##

&&__Syntax:##
    SECOND [-c]

    ^^-c## -> Copies the command output to clipboard
"""

    helpShutdown = """
!!Shuts down the computer.##

&&__Syntax:##
    SHUTDOWN [options]

    ^^options## -> Customise options for shutdown.
        -s - Option for shutdown.
        -r - Option for restart.
        -t - Sets countdown for SHUTDOWN operation.
        -h - Enables hybrid mode while startup.

If only '-h' and/or '-t' options are used, then by default '-s' argument will be executed.
"""

    helpStart = """
!!Starts a file, directory or executable.##

&&__Syntax:##
    START name [-admin]

    ^^name##   -> Relative/Full path of file/directory, or name of program present in the PATH variable.
    ^^-admin## -> Run as Administrator.
"""

    helpTime = """
!!Displays the current system time.##

&&__Syntax:##
    TIME
"""

    helpTitle = """
!!Changes the title of the console window.##

&&__Syntax:##
    TITLE title

    ^^title## -> New title for the Second window.
"""

    helpTree = """
!!Displays a tree of all files and subdirectories inside a directory.##

&&__Syntax:##
    TREE dir

    ^^dir## -> Directory which needs to be examined.
"""

    copyright = """&&SECOND:## **Copyright:##
Copyright (c) 2024 Infinite Inc.
Written by Cpythonist (http://cpythonist.github.io/)
All rights reserved.
"""

    credits = """&&SECOND:## **Credits:##
Thanks to all the authors and contributors of the programming language and libraries used in this program:

CPython:      ^^http://python.org/##

cython:       ^^http://github.com/cython/##
fastnumbers:  ^^http://github.com/SethMMorton/##
psutil:       ^^http://github.com/giampaolo/##
requests:     ^^http://github.com/psf/##
"""