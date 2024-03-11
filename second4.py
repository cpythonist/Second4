# Second 4.0 source code
#
# Filename: second4.py
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
# Improvements aimed for Second 4.0:
#   1. Added commands from previous versions (Second 1 and 2)
#   2. Added dark mode support (extremely unstable and under development).**
#   3. Higher efficiency using the cmd module of the standard library of 
#      CPython-3.11.6 for greater performance.
#   4. Consoles without ANSI support can also run the program.**
#   5. Easy usage by removing the necessity of quotes for all arguments.
#   6. Add update feature.
#   7. Add functionality to execute terminal commands from Second.
#   ** Implementation removed.
#
# Please refer https://cpythonist.github.io/second/documentation/secondDoc4.0.html
# for documentation.
# Please report any bugs at the email address in https://cpythonist.github.io/contact.html.
# 
# Please note that in settings.dat, the DARKMODE (dictionary key "darkmode": (True/False/"auto") variable 
# has not been removed. This is left as such as future versions may include a (hopefully) fully-functional 
# colour mode support.
# 

def main():
    # The "try-wrap"
    try:
        # Imports
        # Imports are declared inside try statement only in this program so as to catch any Exception and 
        # log it into error files. This is the program second4.exe and thus any error needs to be logged.
        from logging import DEBUG, getLogger, FileHandler, Formatter
        from os import makedirs, getpid
        from os.path import isdir
        from subprocess import Popen, PIPE
        from sys import exit as sysExit, argv
        from traceback import format_exc as formatExcep
        import base
        import ctypes, globalNamespace as gn

        # Initialisation for use of escape codes
        base.system('')

        gn.readSettings() # Read user settings from settings.dat
        ctypes.windll.kernel32.SetConsoleTitleW("Second 4") # Set title of console window

        prog = base.Second4() # Create object prog from Second4
        gn.customPrint(f"""
&&**Infinite Second {base.__version__}##
Written by CPythonist (http://cpythonist.github.io/)
!!Developed in CPython 3.11.6
Optimised using Cython 3.0.6
Compiled using Nuitka 1.9.2
Compressed to installer executable using Inno Setup 6.2.2
Thanks to __stackoverflow.com## !!for the necessary help!##

Type "help" without the quotes for the help menu.
""")
        
        # Run the updater as a separate process. Given parameters are the process ID of self process to be passed to installer.
        # Popen(["second4Updater", str(getpid())], executable=argv[0], stdin=PIPE, stdout=PIPE, stderr=PIPE, close_fds=True, shell=False)
        # Didn't use this as the problem of FileNotFoundError couldn't be resolved (the program couldn't identify the updater and update
        # installer files).
        
        while True: # KeyboardInterrupts to be caught in cmd module was either not possible or was difficult to implement, OR IDK how to implement
            try:
                prog.cmdloop()
                prog.prompt = gn.promptUpdater(prog.path, prog.realPrompt)
            except FileNotFoundError:
                gn.customPrint(f"&&SECOND4:## ??CriticalError:## The current working directory \"{prog.path}\" does not exist. Attempting to change to parent directory...")
                exist = False
                temp = prog.path
                while not exist:
                    if isdir(temp:='\\'.join(temp.split('\\')[:-1])):
                        prog.path = temp; exist = True
                        gn.customPrint(f"&&SECOND4:## **Info:## The parent directory \"{temp}\" exists and the current working directory has been changed to it.\n")
                    else: gn.customPrint(f"&&SECOND4:## ??CriticalError:## The parent directory \"{temp}\" does not exist. Trying for the next parent directory...")
            except KeyboardInterrupt as e:
                print()

    except Exception as e: # Handle fatal Exceptions and log the error output.
        gn.customPrint(f"&&SECOND4:## ??UnknownError:## {e.__class__.__name__}: {e}\n", end='')
        makedirs("errOut", mode=0o777, exist_ok=True)
        handler = FileHandler(filename="errOut\\mainErrLog.log", mode="a")
        handler.setLevel(DEBUG)
        handler.setFormatter(Formatter("\n%(asctime)s\n%(levelname)s: %(name)s: %(message)s"))
        logger = getLogger("main")
        logger.addHandler(handler)
        logger.fatal(f"Fatal Exception:\n{formatExcep()}")
        gn.customPrint("-" * (25 + len(f"{e.__class__.__name__}{e}")) + "\n")
        sysExit(1)

if __name__ == "__main__":
    main()
