# Second 4.0 source code
#
# Filename: second4.py
# Brief description: Contains the program that accesses all the files and runs the program.
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
# Improvements in Second 4.0:
#   1. Added commands from previous versions (Second 1 and 2)
#   2. Added dark mode support (extremely unstable and under development).**
#   3. Higher efficiency using the cmd module of the standard library of 
#      CPython-3.11.6 for greater performance.
#   4. Consoles without ANSI support can also run the program.
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
# 
# 

__version__ = "4.0" # Defined as <class 'str'> so as to be compatible for parse function of packaging.version module.
                    # It accepts only string, not integers and floats.

try:
    # Imports
    from base64 import b64decode
    from logging import DEBUG, getLogger, FileHandler, Formatter
    from os import makedirs, getpid, getcwd, remove as removeFile, rename, chdir, listdir
    from os.path import isdir, isfile
    from packaging.version import parse
    from psutil import pid_exists
    from requests import get, codes
    from shutil import rmtree, copy
    from sys import exit as sysExit
    from tempfile import gettempdir
    from threading import Thread
    from time import sleep
    from traceback import format_exc as formatExcep
    from zipfile import ZipFile
    import base
    import ctypes, globalNamespace as gn
except (ImportError, FileNotFoundError, ModuleNotFoundError):
    gn.customPrint(f"&&SECOND4:## ??Error:## File import was unsuccessful. Second-{__version__} was unable to start. Try reinstalling the program.\n")
    raise SystemExit


def installer(pidStr):
    """
    Function to install updates if found. Called from updater() in a separate thread.
    Arguments:
        pidStr -> PID of parent of update thread (second4.exe) in type 'str'
    """
    # The "try-wrap"
    try:
        # Get version number (i.e., number before first decimal point)
        versionNumber = __version__.split('.')[0]
        # Try to make error and output directories, then create handlers for logging into files,
        # then create loggers objects. Two loggers available: one for all output and one for errors.
        makedirs("updateOut", mode=0o777, exist_ok=True)
        handler1 = FileHandler(filename="updateOut\\installerLog.log", mode="a")
        handler1.setLevel(DEBUG)
        handler1.setFormatter(Formatter("\n%(asctime)s\n%(levelname)s:%(name)s: %(message)s"))
        logger1 = getLogger("installer")
        logger1.addHandler(handler1)

        makedirs("errOut", mode=0o777, exist_ok=True)
        handler2 = FileHandler(filename="errOut\\installerErrLog.log", mode="a")
        handler2.setLevel(DEBUG)
        handler2.setFormatter(Formatter("\n%(asctime)s\n%(levelname)s:%(name)s: %(message)s"))
        logger2 = getLogger("installerErr")
        logger2.addHandler(handler2)

        # Try to get data
        data = get(f'https://github.com/cpythonist/Second{versionNumber}/releases/latest/download/Second{versionNumber}.zip', headers={"Authorization" : 'token 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', "Accept": 'application/vnd.github.v3+json'})
        logger1.info("Download done.")

        if data.status_code == 200: # If fetch operation was successful
            logger1.info(f"Zip file size: {len(data.content)} B")

            with open(f"{gettempdir()}\\Second{versionNumber}.zip", 'wb') as f: # Write .zip file to temporary folder
                f.write(data.content)
            
            with ZipFile(f"{gettempdir()}\\Second{versionNumber}.zip", 'r') as f: # Extract .zip file to the install directory
                f.extractall(getcwd() + "\\..")
            
            logger1.info(f"Extract done")
            while True:
                try:
                    if not pid_exists(int(pidStr)):
                        removeFile(f"{gettempdir()}\\Second{versionNumber}.zip") # Delete the downloaded .zip file in temporary folder
                        rename(f"..\\second{versionNumber}", f"..\\Second{versionNumber}") # Rename the extracted folder with capitalised letter

                        chdir("..") # Go to parent folder to delete previous version
                        copy(f"Second{versionNumber}\\settings.dat", f"Second{versionNumber}") # Copy the settings.dat file

                        # Remove the previous installation except for error and update logs
                        [(removeFile(i) if isfile(i) else rmtree(i, ignore_errors=True)) for i in listdir(f"Second{versionNumber}") if not (i in ("errOut", "updateOut"))]
                        
                        # Delete the previous directory IF the directory was empty, i.e. if no logs were found
                        rmtree(f"Second{versionNumber}", ignore_errors=True) if not len(listdir(f"Second{versionNumber}")) else None
                        logger1.info("Success: The update was successful.\n")
                        break
                    sleep(2)
                except Exception:
                    logger1.error("Error during deleting of previous installation files.")
                    logger2.exception("Error during deleting of previous installation files.")
        
        else: # Or log error message and exit
            logger1.error("Update was unsuccessful. Please see ..\\errOut\\installerErrLog.log for error details.")
            logger2.error(f"{data.text}")

    except ConnectionError: # If Internet connection is not available
        logger1.error("Download NOT done. Please see ..\\errOut\\installerErrLog.log for error details.")
        logger2.error(f"No internet connection available.\n{formatExcep()}")

    except FileNotFoundError: # If previous installation was not found
        logger1.warning("Warning(s) present. Refer to .\\errOut\\installErrLog.log for warning details.")
        logger2.warning(f"Previous installation was not found.\n{formatExcep()}")

    except Exception: # Any other exception
        logger1.critical("Critical Exception. Refer to ..\\errOut\\installErrLog.log for error details.")
        logger2.critical(f"Critical Exception:\n{formatExcep()}")


def updater(pidStr):
    """
    Function to check for updates. Called from main() in a separate thread.
    Arguments:
        pidStr -> PID of parent (second4.exe) in type 'str'
    """
    # The "try-wrap"
    try:
        currentVersion = parse(__version__)

        # Get latest version data, i.e. content of text file present in GitHub repository
        if (latestVersion:=get("https://api.github.com/repos/cpythonist/secondVersionManagement/contents/latestVersion.txt", headers={'Authorization': 'token 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'})).status_code == codes.ok:
            latestVersion = parse(b64decode(latestVersion.json()['content']).decode("utf-8").strip())
            
            if currentVersion < latestVersion: # Determine if update is available
                install = Thread(name="installer", target=installer, args=[pidStr])
                install.start()

    except ConnectionError:
        pass

    except Exception as e:
        pass


def main():
    # The "try-wrap"
    try:
        # Initialisation for use of escape codes
        base.system('')

        gn.readSettings() # Read user settings from settings.dat
        ctypes.windll.kernel32.SetConsoleTitleW("Second 4") # Set title of console window

        prog = base.Second4() # Create object prog from Second4
        gn.customPrint(f"""
&&**Infinite Second {__version__}##
Written by CPythonist (http://cpythonist.github.io/)
!!Developed in CPython 3.11.6
Optimised using Cython 3.0.6
Compiled using Nuitka 1.9.2
Compressed to installer executable using Inno Setup 6.2.2
Thanks to __stackoverflow.com## !!for the necessary help!##

Type "help" without the quotes for the help menu.
""")
        
        # Run the updater as a separate process. Given parameters are the process ID of self process to be passed to installer.
        update = Thread(name="updater", target=updater, args=[str(getpid())])
        update.start()
        
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
