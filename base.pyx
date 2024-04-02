# Second 4.0 source code
# 
# Filename: base.pyx
# Brief description: Contains all functional commands and base of the program, the 
#                    Second4 class, inherited from the Cmd class of cmd module.
# 
# This software is a product of Infinite, Inc., and was written by
# CPythonist (http://cpythonist.github.io/) of the development team of Infinite, Inc.
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
# Please report any bugs at using the email address in https://cpythonist.github.io/contact.html.
# 

# Version declaration
__version__ = "4.0" # Defined as <class 'str'> so as to be compatible for parse function of packaging.version module.
                    # It accepts only string, not integers and floats.

# Imports
from cmd import Cmd
from datetime import datetime as dt
from os import chdir, getcwd, getlogin, getpid, makedirs, mkdir, remove as removeFile, sep as osSeparator, scandir, startfile, system, walk
from os.path import basename, expanduser, getctime, getmtime, getsize, isdir, isfile, join
from pathlib import Path
from psutil import Process, process_iter, NoSuchProcess
from re import search, compile
from shutil import copy2, copytree, rmtree, which as shutilWhich
from subprocess import run, PIPE, CalledProcessError
from sys import exit as sysExit
import ctypes
import globalNamespace as gn
import printStrings

system('')

# Main class of the program
class Second4(Cmd):
    def __init__(self):
        super().__init__()
        self.path = expanduser('~')
        if not gn.ANSI:
            self.ANSIRemoved = compile(br'(?:\x1B[@-Z\\-_]|[\x80-\x9A\x9C-\x9F]|(?:\x1B\[|\x9B)[0-?]*[ -/]*[@-~])')
            gn.PROMPT = (self.ANSIRemoved.sub(b'', gn.PROMPT.encode("utf-8"))).decode("utf-8")
        self.realPrompt = gn.PROMPT
    
    def default(self, line): # Overwrite default method for parsing terminal and invalid commands
        line = [i for i in line.split() if not (i == '' or i.isspace())]
        gn.customPrint(f"&&SECOND4:## ??Error:## Unknown command: ??{line[0]}## -> {' '.join(line)}\n")
    
    def emptyline(self): # Overwrite default method for emptyline
        pass

    def onecmd(self, line): # Used to make the program access the command when input in any case
        """
        Used from cmd.py module of standard library of CPython 3.11.6.
        Used for adding functionality of uppercase and mixed case commands.
        """
        cmd, arg, line = self.parseline(line)
        if not line:
            return self.emptyline()
        if cmd is None:
            return self.default(line)
        self.lastcmd = line
        if line == 'EOF' :
            self.lastcmd = ''
        if cmd == '':
            return self.default(line)
        else:
            try:
                func = getattr(self, 'do_' + cmd.lower()) # Edited here. Added .lower() to variable cmd.
            except AttributeError:
                return self.default(line)
            return func(arg)

    def preloop(self): # Dynamic prompt to be updated once at the start of the program
        if not gn.ANSI:
            self.realPrompt = (self.ANSIRemoved.sub(b'', self.realPrompt.encode("utf-8"))).decode("utf-8")
        self.prompt = gn.promptUpdater(self.path, self.realPrompt)

    def postcmd(self, stop: bool, line: str) -> bool: # Dynamic prompt updated at the end of each loop
        self.prompt = gn.promptUpdater(self.path, self.realPrompt)
        return super().postcmd(stop, line)
    
    def do_cd(self, args): # Change directory method
        """
        Changes the current working directory.
        Syntax:
            CD path
            
            ^^path##    Directory to change into.
        """
        if (temp:=search('"(.*?)"', args)) or search("'(.*?)'", args): # Detecting quotation marks
            args = [i for i in (args.split('"') if temp else args.split("'")) if not (i == '' or i.isspace())][0]

            if (temp:=isdir(self.path + '\\' + args)) or isdir(args):
                self.path = (str(Path(self.path + '\\' + args).resolve()) if temp else str(Path(args).resolve()))
                gn.customPrint("&&CD:## !!Success:## Current working directory changed.\n")
            else:
                gn.customPrint("&&CD:## ??Error##: Directory not found.\n")
        
        else: # If quotation marks are not used, use space as delimiters
            args = [i for i in args.split() if not (i == '' or i.isspace())]

            if len(args) == 1:
                args = args[0]
                if (temp1:=isdir(self.path + '\\' + args)) or isdir(args):
                    self.path = (str(Path(self.path + '\\' + args).resolve()) if temp1 else str(Path(args).resolve()))
                    gn.customPrint("&&CD:## !!Success:## Current working directory changed.\n")
                else:
                    gn.customPrint(f"&&CD:## ??Error##: Directory \"{args}\" not found.\n")
            elif len(args) == 0:
                gn.customPrint("&&CD:## ??Error:## Directory to change to was not specified.\n")
            else:
                gn.customPrint("&&CD:## ??Error:## Too many arguments given.\n")

    def do_cls(self, args): # Clear screen method
        """
        Clears the output screen.
        Syntax:
            CLS
        """
        system("cls")
        print()
    
    def do_command(self, args):
        """
        Runs terminal commands on Second.
        Originally, this feature was written in default method of this class, so that commands that 
        are not present in Second 4 could be executed as terminal commands. But this was later removed 
        to prevent accidental execution of terminal commands, and thus a new command called COMMAND was 
        created in Second 4 to accomodate the feature.
        Syntax:
            COMMAND command
            ^^command## -> Command to execute in terminal.
        """
        gn.customPrint("&&COMMAND:## **Terminal output:##")
        pathTemp = getcwd()
        chdir(self.path)
        system(args)
        chdir(pathTemp)
        gn.customPrint()
        

    def do_copy(self, args): # File or directory copy method
        """
        Copies a file/directory to another directory.
        Syntax:
            COPY source dest

            source -> Path of source file/directory on the computer.
            dest -> Destination directory for copying source into.
        """
        if (temp:=search('"(.*?)\\s+"(.*?)"', args)) or search("'(.*?)'\\s+'(.*?)'", args): # Check for use of quotation marks
            args = [i for i in (args.split('"') if temp else args.split("'")) if not (i == '' or i.isspace())]
            src, dest = args
        else: # If no quotation marks, use space as delimiters
            args = args.split()
            if len(args) == 2: # No argument support yet
                src, dest = args
            else:
                gn.customPrint(f"&&COPY:## ??Error##: Format of the command is incorrect. For help, please type **HELP COPY##.\n")
                return None # Get out of loop ASAP!
        
        if (temp1:=isfile(self.path + '\\' + src)) or isfile(src): # Is source a file?
            src = str(Path(self.path + '\\' + src).resolve()) if temp1 else str(Path(src).resolve())

            try:
                if (temp2:=isdir(self.path + '\\' + dest)) or isdir(dest): # Check destination existance
                    dest = str(Path(self.path + '\\' + dest).resolve()) if temp2 else str(Path(dest).resolve())

                    if isfile(dest + '\\' + basename(src)): # If file already exists
                        gn.customPrint(f"&&COPY:## **Info:## File \"{src}\" already exists. Do you want to overwrite it [y/n] (default y)? -> ", end='')
                        overwrite = input().lower() # Overwrite permission

                        if overwrite in ('', 'y', 'yes'):
                            copy2(src, dest)
                            gn.customPrint(f"&&COPY:## !!Success##: File \"{src}\" overwrite was successful.\n")
                        elif overwrite in ('n', 'no'):
                            gn.customPrint(f"&&COPY:## ?!Info:## File \"{src}\" was NOT copied.\n")
                    else: # File DOES NOT exist
                        copy2(src, dest)
                        gn.customPrint(f"&&COPY:## !!Success##: File \"{src}\" copied successfully.\n")
                else: # Oops, destination does not exist
                    gn.customPrint(f"&&COPY:## ??Error##: Destination directory \"{str(Path(dest).resolve())}\" not found.\n")
            except PermissionError: # No permission to write
                gn.customPrint(f"&&COPY:## ??Error##: Access is denied.\n")
            except EOFError: # Process stopped in middle (like during overwrite input)
                gn.customPrint(f"&&COPY:## ??EOF:## Operation terminated.\n")
            except Exception as e: # Any other unknown exceptions so that program does not crash
                gn.customPrint("&&COPY:## ??UnknownError##: " + str(e.__class__.__name__) + str(e))
        
        elif (temp3:=isdir(self.path + '\\' + src)) or isdir(src): # Or is source a directory?
            src = str(Path(self.path + '\\' + src).resolve()) if temp3 else str(Path(src).resolve())
            
            try:
                if (temp4:=(isdir(self.path + '\\' + dest)) or isdir(dest)): # Check directory existance
                    dest = str(Path(self.path + '\\' + dest).resolve()) if temp4 else str(Path(dest).resolve())
                    gn.customPrint(f"""&&COPY:## **Info##: Destination directory "{str(Path(dest).resolve())}" exists.
&&COPY:## **Input:## Do you want to copy into "{dest}" (some files can be overwritten) [y/n] (default y)? -> """, end='')
                    overwrite = input().lower() # Overwrite permission

                    if overwrite in ('', 'y', 'yes'):
                        copytree(src, dest, symlinks=True, dirs_exist_ok=True)
                        gn.customPrint(f"&&COPY:## !!Success##: Directory copy was successful.\n")
                    elif overwrite in ('n', 'no'):
                        gn.customPrint(f"&&COPY:## ?!Info##: Directory copy was NOT performed.\n")
                    else:
                        gn.customPrint(f"&&COPY:## ??Info##: Invalid option. Directory copy was NOT performed.\n")
                else:
                    try:
                        pathTemp = getcwd()
                        chdir(self.path)
                        makedirs(dest)
                        copytree(src, dest, symlinks=True, dirs_exist_ok=True)
                        gn.customPrint(f"&&COPY:## !!Success##: Directory \"{str(Path(dest).resolve())}\" was created and copy from \"{src}\" was successful.\n")
                    except Exception as e:
                        gn.customPrint(f"&&COPY:## ??UnknownError:## {e.__class__.__name__}: {e}\n")
                    finally:
                        chdir(pathTemp)
            except PermissionError:
                gn.customPrint(f"&&COPY:## ??Error##: Access is denied for source directory.\n")
            except EOFError:
                gn.customPrint(f"&&COPY:## ??EOF:## Operation terminated.\n")
            except Exception as e:
                gn.customPrint(f"&&COPY:## ??UnknownError##: {e.__class__.__name__}: {e}\n")
        
        else:
            gn.customPrint(f"&&COPY:## ??Error##: Source file not found.\n")
    
    def do_copyright(self, args):
        """
        Displays the copyright information on Second.
        Syntax:
            COPYRIGHT
        """
        gn.customPrint(printStrings.Base.copyright)
    
    def do_credits(self, args):
        """
        Displays the copyright information on Second.
        Syntax:
            COPYRIGHT
        """
        gn.customPrint(printStrings.Base.credits)
    
    def do_date(self, args):
        """
        Displays the current system date.
        Syntax:
            DATE
        """
        gn.customPrint(f"&&DATE:## **Info:## Date today: {dt.today().strftime('%d.%m.%Y (%d %B %Y)')} (dd.mm.yyyy).\n")
    
    def do_del(self, args):
        """
        Deletes a file/directory.
        Syntax:
            DEL path
            path -> Path of file/directory to be deleted.
        """
        if (temp:=search('"(.*?)"', args)) or search("'(.*?)'", args): # Manipulate the arguments given to interpret
            args = [i for i in (args.split('"') if temp else args.split("'")) if not (i == '' or i.isspace())][0]
        else:
            if len(temp:=[i for i in args.split() if not (i == '' or i.isspace())]) == 1: # One argument present
                args = temp[0]
            else: # Oops! Many arguments present
                gn.customPrint(f"&&DEL:## ??Error##: Format of the command is incorrect. For help, please type **HELP START##.\n")
                return None # Get out of loop ASAP!

        try:
            pathTemp = getcwd() # I'm tired of writing comments for this particular thingy. It is present like four/five times.
                                # Kindly check the others, I have written the comments for one of them.
            chdir(self.path)
            if (temp:=isfile(args)) or isdir(args): # Check if file or directory, and store that data in temp
                if temp:
                    removeFile(args)
                    gn.customPrint(f"&&DEL:## !!Success:## File \"{Path(args).resolve()}\" was successfully deleted.\n")
                else:
                    rmtree(args)
                    gn.customPrint(f"&&DEL:## !!Success:## Directory \"{Path(args).resolve()}\" was successfully deleted.\n")
            else: # File/Directory not found
                gn.customPrint(f"&&DEL:## ??Error:## No file/directory named \"{args}\".\n")
        except PermissionError:
            gn.customPrint(f"&&DEL:## ??Error:## Atleast one file/directory in the tree is read-only or permissions unavailable for the operation.\n")
        except Exception as e: # Unknown Exception occured
            gn.customPrint(f"&&DEL:## ??UnknownError:## {e.__class__.__name__}: {e}\n")
        finally:
            chdir(pathTemp) # Change to recorded directory
    
    def do_dir(self, args):
        """
        Displays the files and directories one level inside a directory.
        Syntax:
            DIR path
            path -> Directory which needs to be examined.
        """
        try:
            if isdir(args): path = args
            elif isdir(self.path + "\\" + args): path = self.path + "\\" + args
            else: gn.customPrint(f"&&DIR:## ??Error:## No directory named \"{args}\".\n"); return None
            gn.customPrint(f"&&DIR:## **Info:## Command DIR on directory \"{Path(path).resolve()}\".\n")
            maxSize = 0
            for j in scandir(path):
                if len(str(j.stat().st_size)) > maxSize: maxSize = len(str(j.stat().st_size))
            gn.customPrint(f"{'DATE CREATED':<19}   {'DATE MODIFIED':<19}   TYPE   " + "{size:<{maximumSize}}   NAME".format(size="SIZE", maximumSize=maxSize))
            for i in scandir(path):
                print(f"{dt.fromtimestamp(getctime(join(path, i.name))).strftime(r'%d-%m-%Y %H:%M:%S')}   {dt.fromtimestamp(getmtime(join(path, i.name))).strftime(r'%d-%m-%Y %H:%M:%S')}   {'FILE' if isfile(join(path, i.name)) else 'DIR '}   " + "{size:<{maximumSize}}   {name}".format(size=getsize(join(path, i.name)), maximumSize=maxSize, name=i.name))
            gn.customPrint()
        except PermissionError:
            gn.customPrint("&&DIR:## ??Error:## Permissions unavailable for accessing the path given.\n")
    
    def do_eof(self, args):
        """
        Exits the program.
        Syntax:
            ^Z (CTRL+Z)
        """
        gn.customPrint(f"&&SECOND4:## !!Success:## Program second4.exe (PID:{getpid()}) exited successfully.\n{'-'*(65+len(str(getpid())))}\n")
        sysExit(0)
    
    def do_exit(self, args):
        """
        Exits the program.
        Syntax:
            EXIT
        """
        gn.customPrint(f"&&SECOND4:## !!Success:## Program second4.exe (PID:{getpid()}) exited successfully.\n{'-'*(65+len(str(getpid())))}\n")
        sysExit(0)

    def do_greet(self, args):
        """
        Greets the user.
        Syntax:
            GREET [option]
            option -> Specify option to greet the user.
                1 - Greet option 1 (default)
                2 - Greet option 2
        """
        if (args in ('', '1')) or args.isspace(): # Default and mode 1
            greetStr = f"Hello,"
        elif args == '2': # Mode 2
            time = int(dt.now().strftime("%H"))
            if time in range(12):
                greetStr = f"Good morning,"
            elif time in range(12, 4):
                greetStr = f"Good afternoon,"
            elif time in range(4,24):
                greetStr = f"Good evening,"
        else: # That's mode 3, or INVALID!
            greetStr = "??That's invalid syntax,##"
        gn.customPrint(str(greetStr) + f" **{getlogin()}!##\n")
    
    def do_help(self, args):
        """
        Displays help menu.
        Syntax:
            HELP [command]
            command -> Displays help for command with the name "command".
        """
        if len(args:=[i for i in args.split() if not (i == '' or i.isspace())]) == 0: # No argument(s) specified, just print the thing
            gn.customPrint(printStrings.Base.help, end='')
        elif len(args) == 1: # Argument specified?
            try:
                temp = getattr(printStrings.Base, "help"+args[0].lower().capitalize()) # Try to get the value of the variable
                gn.customPrint(f"&&HELP:## **{args[0].upper()}:##\n{temp}")
            except AttributeError: # If not found (the variable)
                gn.customPrint(f"&&HELP:## ??Error:## No command named \"{args[0]}\".\n")
        else: # Oops! Too many arguments go against the rules!
            gn.customPrint(f"&&HELP:## ??Error:## Too many arguments: {str(args)[1:-1]}.\n")
    
    def do_kill(self, args):
        """
        Kills the specified process.
        Syntax:
            KILL process [-f] [-c]
            process -> Process name or process ID to be killed
            -f      -> Kill the process forcefully
            -c      -> Kill the process and all of its child processes
        """
        # Parse input
        if args == '':
            gn.customPrint("&&KILL:## ??Error:## Required data to terminate a process not given.\n"); return None
        if (temp:=search('"(.*?)"', args)) or search("'(.*?)'", args):
            args = (temp:=[i.strip() for i in (args.split('"') if temp else args.split("'")) if not (i == '' or i.isspace())])[0]
        else:
            args = (temp:=[i.strip() for i in args.split() if not (i == '' or i.isspace())])[0]
        
        remainingArgs = temp[1:]

        # Main command
        if args.isnumeric(): call = ["taskkill", "/pid", f"{args}"]; typ = "pid"
        else: call = ["taskkill", "/im", f"{args}"]; typ = "name"

        if len(remainingArgs) != 0: # Arguments
            if len(remainingArgs) in (1,2):
                if remainingArgs[0] == '-c': call += ["/t"]
                elif remainingArgs[0] == '-f': call += ["/f"]
                else: gn.customPrint(f"&&KILL:## ??Error:## Unknown argument given: {remainingArgs[0]}.\n"); return None
            else:
                gn.customPrint(f"&&KILL:## ??Error:## Too many arguments given: {remainingArgs}.\n"); return None
        
        try:
            if typ == "name":
                name = args; pid = []
                for proc in process_iter():
                    if name.lower() in proc.name().lower():
                        pid.append(str(proc.pid))
            elif typ == "pid":
                pid = args; process = Process(pid=int(pid))
                name = process.name()
        except NoSuchProcess: # Don't worry will be caught in CalledProcessError catch.
            pass

        try:
            result = run(call, stdin=PIPE, stderr=PIPE, stdout=PIPE) # Kill command
            if result.stderr == b'':
                if typ == "name":
                    gn.customPrint(f"&&KILL:## !!Success:## Process \"{name}\" with PID(s) ", end='')
                    gn.customPrint(*pid, sep=', ', end='')
                    gn.customPrint(" terminated successfully.\n")
                elif typ == "pid":
                    gn.customPrint(f"&&KILL:## !!Success:## Process with PID {pid} named \"{name}\" was terminated successfully.\n")
            else:
                raise CalledProcessError(1, "_CMD")
        except CalledProcessError:
            if typ == "name":
                gn.customPrint(f"&&KILL:## ??Error:## Process \"{name}\" was not found.\n")
            elif typ == "pid":
                gn.customPrint(f"&&KILL:## ??Error:## Process with PID {pid} was not found.\n")
    
    def do_mkdir(self, args):
        """
        Creates a new directory.
        Syntax:
            MKDIR newdir
            newdir -> Directory name for the new directory (relative or full path, or just directory name)
        """
        if args == '':
            gn.customPrint("&&MKDIR:## ??Error:## Data required for directory creation not given. For more information, use **HELP MKDIR##.\n")
            return None
        if (temp:=search('"(.*?)"', args)) or search("'(.*?)'", args):
            args = [i.strip() for i in (args.split('"') if temp else args.split("'")) if not (i == '' or i.isspace())][0]
        else:
            args = [i for i in args.split() if not (i == '' or i.isspace())][0]
        pathTemp = getcwd() # Record current working directory (expected to be installation folder unless 
                            # some bug/external interference had caused it to be something else)
        chdir(self.path) # Change to the self.path directory (as os.mkdir() works with absolute and relative paths)
        try:
            mkdir(args) # Try to make new directory
            gn.customPrint(f"&&MKDIR:## !!Success:## Directory \"{Path(args).resolve()}\" successfully created.\n")
        except FileExistsError: # Directory exists
            gn.customPrint(f"&&MKDIR:## ??Error:## Directory \"{Path(args).resolve()}\" already exists.\n")
        except OSError: # Illegal character in directory name
            gn.customPrint(f"&&MKDIR:## ??Error:## Invalid character in directory name \"{args}\".\n")
        except Exception as e: # Unknown Exception occured
            gn.customPrint(f"&&MKDIR:## ??UnknownError:## {e.__class__.__name__}: {e}\n")
        finally: # Always execute
            chdir(pathTemp) # Change to the recorded directory
    
    def do_prompt(self, args):
        """
        Changes the prompt variable of the program.
        Syntax:
            PROMPT prompt
            prompt -> New prompt for Second
                %U - Username
                %S - OS name
                %R - Release number
                %P - Path (current working directory)
                %% - Percentage sign
        
        Note: If the program is running in a terminal WITHOUT ANSI support, 
              ANSI escape codes are removed from the given data to the PROMPT command.
        
        Known bugs:
            1. When the new prompt is given as one of the formatting symbols of the property of the font of the prompt 
               changes to the corresponding escape code (e.g., "!!" gives the prompt in green colour). The colour becomes 
               nomal after the program is restarted. Tried to resolve the issue but was unsuccessful.
        """
        self.realPrompt = args # self.realprompt is used for storing the unformatted prompt for 
                               # being dynamic (like current working directories)

        if args == '': # If no arguments, restore original prompt of the program
            self.realPrompt = f"{gn.BLUE}%U{gn.RESET}->{gn.BLUE}%S%R{gn.RESET}&&{gn.GREEN}%P{gn.RESET}(S4):~ {gn.YELLOW}${gn.RESET}"
            gn.customPrint(f"&&PROMPT:## !!Success:## Original prompt variable restored.")
        
        try:
            f = open("settings.dat", 'rb+') # Open to load the data
            data = gn.loadBin(f)
            f.close()
            f = open("settings.dat", 'wb') # Overwrite the file
            data["prompt"] = self.realPrompt
            gn.dumpBin(data, f)
            f.close()
            gn.customPrint(f"&&PROMPT:## !!Success:## Prompt variable successfully changed and stored as \"{self.realPrompt}\".\n")
        
        except FileNotFoundError: # settings.dat not found!
            gn.customPrint("&&PROMPT:## ??Error:## File settings.dat was not found.")
            gn.customPrint("&&PROMPT:## **Info:## Prompt variable will be temporarily changed. To resolve this issue, please restart the program.\n")
        
        except (gn.UnpicklingError, KeyError): # Invalid data in settings.dat
            gn.customPrint("&&PROMPT:## ??Error:## Empty/Invalid data in file settings.dat.")
            gn.customPrint("&&PROMPT:## ??Info:## Prompt variable will be temporarily changed. To resolve this issue, please restart the program.\n")
        
        except PermissionError: # Permissions unavailable for settings.dat
            gn.customPrint("&&PROMPT:## ??Error:## Access is denied for settings.dat.")
            gn.customPrint("&&PROMPT:## ??Info:## Prompt variable will be temporarily changed. To resolve this issue, please restart the program.\n")
        
        except Exception as e: # Unknown Exception occured
            gn.customPrint(f"&&PROMPT:## ??UnknownError:## {e.__class__.__name__}: {e}\n")
        
        if not gn.ANSI:
            self.realPrompt = (self.ANSIRemoved.sub(b'', self.realPrompt.encode("utf-8"))).decode("utf-8")

    def do_quit(self, args):
        """
        Quits the program.
        Syntax:
            QUIT
        """
        gn.customPrint(f"&&SECOND4:## !!Success:## Program second4.exe (PID:{getpid()}) exited successfully.\n{'-'*(65+len(str(getpid())))}\n")
        sysExit(0)
    
    def do_second(self, args):
        """
        Displays the developer and operating system information of Second 4.
        Syntax:
            SECOND [-c]
            -c -> Copies the command output to clipboard
        """
        args = [i for i in args.split() if not (i == '' or i.isspace())] # Manipulate args to interpret
        if not len(args): # Arguments not given
            gn.customPrint(printStrings.Base.secondFormatted)
        
        elif len(args) == 1: # If number of arguments is one and argument is 'c'
            if args[0] == '-c':
                gn.customPrint(printStrings.Base.secondFormatted)
                run(["clip.exe"], input=printStrings.Base.secondUnformatted.encode('utf-8'), check=True)
                gn.customPrint("&&SECOND:## !!Success:## Successfully copied output to clipboard.\n")
            elif (args[0].replace('.', '', 1).isnumeric()) and (float(args[0]) == int(__version__.split('.')[0]) + 1):
                gn.customPrint("&&SECOND5:## !!You got to wait!## Check at __http://cpythonist.github.io/second.html## or __http://github.com/cpythonist##!\n")
            else: # Else print error message
                gn.customPrint(f"&&SECOND:## ??Error:## Unknown argument(s): {str(args)[1:-1]}.\n")
        
        elif len(args) > 1: # Too many arguments given
            gn.customPrint(f"&&SECOND:## ??Error:## Too many argument(s): {str(args)[1:-1]}.\n")
          
    
    def do_shutdown(self, args):
        """
        Shuts down the computer.
        Syntax:
            SHUTDOWN [options]
            options -> Customise options for shutdown.
                -s - Option for shutdown.
                -r - Option for restart.
                -t - Sets countdown for SHUTDOWN operation.
                -h - Enables hybrid mode while startup.
        If only '-h' and/or '-t' options are used, then by default '-s' argument will be executed.
        """
        args = [i for i in args.split() if not (i == '' or i.isspace())]
        command = ''
        for i in args:
            if i == '-s':
                command += " /s"
            elif i == '-r':
                command += " /r"
            elif i.startswith('-t') and i[1:].isnumeric():
                command += f" /t {int(i[1:]):03d}"
            elif i == '-h':
                command += " /hybrid"
            else:
                gn.customPrint(f"&&SHUTDOWN:## ??Error:## Unknown argument: {i}\n")
        
        if ('-s' not in command) and ('-r' not in command):
            command += " /s"
        
        try:
            gn.customPrint("&&SHUTDOWN:## !!Success:## Shutdown command activated.\n")
            system("shutdown" + command)
        except Exception as e:
            gn.customPrint(f"&&SHUTDOWN:## ??UnknownError:## {e.__class__.__name__}: {e}\n")
    
    def do_start(self, args):
        """
        Starts a file, directory or executable.
        Syntax:
            START name [-admin]
            name   -> Relative/Full path of file/directory, or name of program present in the PATH variable.
            -admin -> Run as Administrator.
        """
        isAdminMode = False
        if (temp:=search('"(.*?)"(.*?)', args)) or search("'(.*?)'(.*?)", args):
            args = (temp1:=[i.strip() for i in (args.split('"') if temp else args.split("'")) if not (i == '' or i.isspace())])[0]
            optArgs = temp1[1:]
            if len(optArgs) == 0: pass
            elif len(optArgs) == 1:
                if optArgs[0] == "-admin":
                    isAdminMode = True
                else:
                    gn.customPrint(f"&&START:## ??Error:## Invalid argument: '{optArgs[0]}'.\n")
                    return None
            else:
                gn.customPrint(f"&&START:## ??Error##: Too many arguments {', '.join(i for i in optArgs)}.\n")
                return None
        else:
            if len(temp:=[i.strip() for i in args.split() if not (i == '' or i.isspace())]):
                args = temp[0]
                optArgs = temp[1:]
                if len(optArgs) == 0: pass
                elif len(optArgs) == 1:
                    if optArgs[0] == "-admin":
                        isAdminMode = True
                    else:
                        gn.customPrint(f"&&START:## ??Error:## Invalid argument: '{optArgs[0]}'.\n")
                        return None
                else:
                    gn.customPrint(f"&&START:## ??Error##: Too many arguments: {temp}.\n")
                    return None
            else:
                gn.customPrint(f"&&START:## ??Error##: Format of the command is incorrect. For help, please type **HELP START##.\n")
                return None # Get out of loop ASAP!
        
        try:
            pathTemp = getcwd() # There is exactly the same block of code in do_mkdir, I guess. Please see that documentation.
            chdir(self.path)
            if isfile(args) or isdir(args):
                startfile(args, 'runas') if isAdminMode else startfile(args)
                gn.customPrint(f"&&START:## !!Success:## File/Directory \"{Path(args).resolve()}\" opened successfully.\n")
            else:
                startfile(args, 'runas') if isAdminMode else startfile(args)
                gn.customPrint(f"&&START:## !!Success:## Executable \"{shutilWhich(args)}\" opened successfully {'with administrator previlages' if isAdminMode else ''}.\n")
        
        except FileNotFoundError as e:
            gn.customPrint(f"&&START:## ??Error:## \"{args}\" is not a file, directory or executable, or the file is not accessible as requested.\n")
        
        except OSError as e:
            gn.customPrint("&&START:## ??Error:## The process was aborted by the user, or the file is not accessible by the Administrator account.\n")
        
        except Exception as e:
            gn.customPrint(f"&&START:## ??UnknownError:## {e.__class__.__name__}: {e}\n")
        
        finally:
            chdir(pathTemp)
    
    def do_time(self, args):
        """
        Displays the current system time.
        Syntax:
            TIME
        """
        gn.customPrint(f"&&TIME:## **Info:## Time now is: {dt.now().strftime('%H:%M.%S [%f]')} (hh:mm.ss [microseconds]).\n")
    
    def do_title(self, args):
        """
        Changes the title of the console window.
        Syntax:
            TITLE title
            title -> New title for the Second window.
        """
        try:
            ctypes.windll.kernel32.SetConsoleTitleW(args) # Try to change the title
            gn.customPrint(f"&&TITLE:## !!Success:## Title successfully changed to \"{args}\".\n")
        except Exception as e: # If any error (I've never see any), then print it.
            gn.customPrint(f"&&TITLE:## ??UnknownError:## {e.__class__.__name__}: {e}\n")
    
    def do_tree(self, args):
        """
        Displays a tree of all files and subdirectories inside a directory.
        Syntax:
            TREE dir
            dir -> Directory which needs to be examined.
        """
        pathTemp = getcwd()
        chdir(self.path)
        if args == '' or args.isspace(): args = '.'
        if isdir(args):
            gn.customPrint(f"&&TREE: **Info:## Command TREE on directory \"{Path(args).resolve()}\".\n")
            for root, dirs, files in walk(args):
                level = root.replace(args, '').count(osSeparator)
                indent = ('-' * 3 * (level-1)) + '→ '
                print('{}{}/'.format(indent, basename(root)))
                subindent = ' ' * 3 * (level + 1)
                for f in files:
                    print('{}{}'.format(subindent, f))
            gn.customPrint()
        else: gn.customPrint(f"&&TREE:## ??Error:## No directory named \"{args}\".\n")
        chdir(pathTemp)
