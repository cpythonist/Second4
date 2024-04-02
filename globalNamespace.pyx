# Second 4.0 source code
# 
# Filename: globalNamespace.pyx
# Brief description: Contains globally used functions of the program to be accessible to the whole program.
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

# Imports
from getpass import getuser
from msvcrt import getch, kbhit
from os.path import realpath, dirname
from pickle import UnpicklingError, load as loadBin, dump as dumpBin
from platform import system as platSys, release as platRel, version as platVer
from re import sub as substitute
from sys import stdout, stdin
import ctypes

# Declaration of escape codes for text-formatting
BOLD = "\033[1m"
BLINK = "\033[5m"
BLUE = "\033[94m"
CLS = "\033[H\033[J"
CYAN = "\033[96m"
GREEN = "\033[92m"
HEADER = "\033[95m"
RED = "\033[91m"
RESET = "\033[0m"
UNDERLINE = "\033[4m"
YELLOW = "\033[93m"


def isANSISupported():
    """
    Function: isANSISupported
    Checks if the terminal supports ANSI sequences.
    If yes, return True, else False.
    Note:
        In terminals without ANSI support, some text maybe visible at the start. os.system("cls") has not been used 
        in case user runs the program from an already existing terminal window (as it can have other output).
    """
    kernel32 = ctypes.windll.kernel32
    kernel32.SetConsoleMode(kernel32.GetStdHandle(-11), 7)
    while kbhit():
        getch()
    stdout.write("\x1b[6n\b\b\b\b")
    stdout.flush()
    stdin.flush()
    if kbhit():
        if ord(getch()) == 27 and kbhit():
            if getch() == b"[":
                while kbhit():
                    getch()
                return stdout.isatty()
    return False


def customPrint(*string, end='\n', sep=' ', flush=False) -> None:
    """
    Function: customPrint
    Custom function for output to sys.stdout with easy text-formatting.
    Uses regular expressions to evaluate strings given and replace characters
    as necessary with formatting data.

    Formatting options:
        ?? -> Red
        ?! -> Yellow
        !! -> Green
        ** -> Cyan
        ^^ -> Blue
        && -> Bold
        __ -> Underline
        ## -> Reset

    Returns None.
    """
    finalStr = []
    if ANSI:
        replace = (
            ("\\?\\?", RED),
            ("\\?!", YELLOW),
            ("!!", GREEN),
            ("\\*\\*", CYAN),
            ("\\^\\^", BLUE),
            ("\\&\\&", BOLD),
            ("__", UNDERLINE),
            ("\\#\\#", RESET)
        )

        for i in string:
            for pattern, repl in replace:        
                i = substitute(pattern, repl, i)
            finalStr.append(i)
    elif not ANSI:
        replace = (
            ("\\?\\?", ''),
            ("\\?!", ''),
            ("!!", ''),
            ("\\*\\*", ''),
            ("\\^\\^", ''),
            ("\\&\\&", ''),
            ("__", ''),
            ("\\#\\#", '')
        )
        for i in string:
            for pattern, repl in replace:        
                i = substitute(pattern, repl, i)
            finalStr.append(i)
    
    stdout.write(sep.join(finalStr) + end) # sys.stdout.write() does not support giving strings as a list/tuple of parameters
    stdout.flush() if flush else None


def readSettings() -> None:
    """
    Function to read settings from file settings.dat.
    If file is found and data is correct, settings are loaded into global variables for later use.
    Else if file is:
        1. Empty: Attempts to write default values into file.
        2. Invalid: Attempts to erase the file and write default values into file.
        3. Not found: Attempts to create file and write default values into file.
    Returns None.
    """
    global PROMPT # Global prompt variable
    isDataLoaded = False # For checking if settings has been read in one of the conditions
    try:
        customPrint("**Info:## Loading settings... ")
        f = open(f"{dirname(realpath(__file__))}\\settings.dat", 'rb+')
        data = loadBin(f) # Data is stored in dictionary
        isDataLoaded = True
        PROMPT = data["prompt"]
    
    except EOFError:
        if isDataLoaded: # Check if the data was loaded (for checking empty settings.dat file)
            f.close()
            customPrint("Done")
        
        else: # Try to correct file settings.dat
            f.truncate(0)
            customPrint("**Info:## ?!File settings.dat was empty.## Writing default values... ")
            try:
                with open(f"{dirname(realpath(__file__))}\\settings.dat", 'wb') as f: # Opening with 'wb' mode even though 'rb+' is perfectly valid 
                                                      # as file is going to empty but will exist
                    dumpBin({"prompt":f"{BLUE}%U{RESET}->{BLUE}%S%R{RESET}&&{GREEN}%P{RESET}(S4):~ {YELLOW}${RESET}"}, f)
            except PermissionError: # If access if denied
                customPrint("?!Warning: Permissions for writing data in file settings.dat not available.## ")
            PROMPT = f"{BLUE}%U{RESET}->{BLUE}%S%R{RESET}&&{GREEN}%P{RESET}(S4):~ {YELLOW}${RESET}"
            customPrint("**Info:## Loading default settings...")
    
    except FileNotFoundError: # File settings.dat not found
        customPrint("**Info:## ?!The file settings.dat does not exist.## Creating new file... ")
        try:
            with open(f"{dirname(realpath(__file__))}\\settings.dat", 'wb') as f: # Try to create new settings.dat file
                customPrint("**Info:## Writing default values...")
                dumpBin({"prompt":f"{BLUE}%U{RESET}->{BLUE}%S%R{RESET}&&{GREEN}%P{RESET}(S4):~ {YELLOW}${RESET}"}, f)
        except PermissionError: # Permission denied. Ignore creating file. Maybe on next run the issue can be resolved
            customPrint("?!Warning: Permissions for creating/writing data in file settings.dat not available.##")
        PROMPT = f"{BLUE}%U{RESET}->{BLUE}%S%R{RESET}&&{GREEN}%P{RESET}(S4):~ {YELLOW}${RESET}"
        customPrint("**Info:## Loading default settings...")
    
    except (UnpicklingError, KeyError):
        customPrint("?!Warning:## ?!Invalid data in file settings.dat.##")
        choice = input("**Confirm:## Do you want to erase the file and write the default values? (default) [y/n]\n").lower()
        if choice in ('', 'y', 'yes'):
            try:
                with open(f"{dirname(realpath(__file__))}\\settings.dat", 'wb') as f: # Try to erase file by using 'w' mode and write default values
                    customPrint("**Info:## Writing default values... ")
                    dumpBin({"prompt":f"{BLUE}%U{RESET}->{BLUE}%S%R{RESET}&&{GREEN}%P{RESET}(S4):~ {YELLOW}${RESET}"}, f)
            except PermissionError:
                customPrint("?!Warning: Permissions for writing data in file settings.dat not available.## ")
            PROMPT = f"{BLUE}%U{RESET}->{BLUE}%S%R{RESET}&&{GREEN}%P{RESET}(S4):~ {YELLOW}${RESET}"
            customPrint("**Info:## Loading default settings...")
        else:
            PROMPT = f"{BLUE}%U{RESET}->{BLUE}%S%R{RESET}&&{GREEN}%P{RESET}(S4):~ {YELLOW}${RESET}"
            customPrint("?!Warning: Invalid option entered.## File will be left as it is. Loading default values...")
    
    except PermissionError:
        PROMPT = f"{BLUE}%U{RESET}->{BLUE}%S%R{RESET}&&{GREEN}%P{RESET}(S4):~ {YELLOW}${RESET}"
        customPrint("?!Warning:## Access is denied for settings.dat. Loading default values...")

    except Exception as e: # Data not readable in file settings.dat
        customPrint(f"&&SECOND4:## ??UnknownError:## {e.__class__.__name__}: {e}")


def promptUpdater(path, prompt):
    """
    Function: promptUpdater
    Updates the dynamic prompt of Second.
    Returns updated prompt.
    """
    skip = 0 # Used for boosting performance
    while bool([i for i in ("%%", "%P", "%U", "%S", "%R") if i in prompt.upper()]): # Check if '%' is in string for speed
        try:
            for i in range(skip, len(prompt)+1): # I simply don't understand why it needs to be len(prompt)+1 when it can be 
                                                 # len(prompt)-1 or atleast len(prompt). I tried this in frustration during 
                                                 # debugging and it worked. If someone knows how, please try to mail me why.
                if prompt[i] == '%': # Check character for placeholder part
                    if prompt[i+1] in "UuSsRrPp%": # Valid characters following '%' to be a placeholder
                        # %(Pp) ->  Path (current working directory)
                        # %(Rr) ->  Release number
                        # %(Ss) ->  OS name
                        # %(Uu) ->  Username
                        # %(%)  ->  %
                        if prompt[i+1] in "Uu": prompt = prompt[:i] + getuser() + prompt[i+2:]; skip += len(getuser())
                        elif prompt[i+1] in "Ss": prompt = prompt[:i] + platSys() + prompt[i+2:]; skip += len(platSys())
                        elif prompt[i+1] in "Rr":
                            ver = platVer(); rel = platRel()
                            if rel == "10": rel = "11" if (int(ver.split('.')[2]) > 22000) else "10"
                            prompt = prompt[:i] + rel + prompt[i+2:]; skip += len(rel)
                        elif prompt[i+1] in "Pp": prompt = prompt[:i] + path + prompt[i+2:]; skip += len(path)
                        elif prompt[i+1] == '%': prompt = prompt[:i+1] + prompt[i+2:]; skip += 1
                        break
        except IndexError as e:
            break
    return prompt

global ANSI # Global ANSI support determination identifier.
ANSI = isANSISupported()
