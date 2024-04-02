# Second 4
Source code of the Second 4 Interpreter. This repository contains all the necessary scripts to compile to a full installer archive.  
The ready-made installer executable is available in the [Releases](http://github.com/cpythonist/Second4/releases/latest) tab. If you want to build the program yourself, please see the steps under [Building]():  

## Improvements aimed for Second 4:
- [x] Added commands from previous versions (Second 1 and 2)
- [ ] Added dark mode support (extremely unstable and under development).
- [x] Higher efficiency using the cmd module of the standard library of CPython-3.11.6 for greater performance.
- [x] Consoles without ANSI support can also run the program.
- [x] Easy usage by removing the necessity of quotes for all arguments.
- [x] Add update feature.
- [x] Add functionality to execute terminal commands from Second.  
  
## Building:  
1. Install the following applications:  
&emsp;[`Python-3.11.6`](http://python.org/)  
&emsp;[`Inno Setup-6.2.2`](http://jrsoftware.org/)  
  
2. Install the following Python packages (present in `requirements.txt`):  
&emsp;`certifi==2024.2.2`  
&emsp;`Cython==3.0.10`  
&emsp;`fastnumbers==5.1.0`  
&emsp;`idna==3.6`  
&emsp;`Nuitka==2.0.6`  
&emsp;`ordered-set==4.1.0`  
&emsp;`packaging==24.0`  
&emsp;`psutil==5.9.8`  
&emsp;`requests==2.31.0`  
&emsp;`urllib3==2.2.1`  
&emsp;`zstandard==0.22.0`
  
4. Build [Cython](http://github.com/cython/cython) modules:  
&emsp;Run the following command to build the `.pyd` files:
  
&emsp;&emsp;&emsp;`python setup.py build_ext --inplace`  
  
&emsp;&emsp;&emsp;This outputs three `.pyd` files: `globalNamespace.pyd`, `base.pyd`, `printStrings.pyd`    
  
5. Build [Nuitka](http://github.com/Nuitka/Nuitka) executable:  
&emsp;Run the following command to build the Nuitka executable (please change the required paths as per your computer):  
  
&emsp;&emsp;&emsp;`python -m nuitka --standalone --follow-imports --mingw64 --warn-unusual-code --windows-icon-from-ico=second4.ico --company-name="Infinite Inc." --product-name="Second 4.0" --file-version=1.0.0.0 --product-version=4.0 --file-description="Second 4.0 Interpreter" --copyright="Apache-2.0" --include-data-files=settings.dat=. second4.py`    
  
6. (Optional) Build Inno Setup installer archive:  
&emsp;Run `script4.0.iss` to produce the installer.
