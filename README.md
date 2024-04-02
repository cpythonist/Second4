# Second 4
Source code of the Second 4 Interpreter. This repository contains all the necessary scripts to compile to a full installer archive.<br>
The ready-made installer executable is available in the [Releases](http://github.com/cpythonist/Second4/releases/latest) tab. If you want to build the program yourself, please see the steps under [Building]():<br>

## Improvements aimed for Second 4:
- [x] Added commands from previous versions (Second 1 and 2)
- [ ] Added dark mode support (extremely unstable and under development).
- [x] Higher efficiency using the cmd module of the standard library of CPython-3.11.6 for greater performance.
- [x] Consoles without ANSI support can also run the program.
- [x] Easy usage by removing the necessity of quotes for all arguments.
- [x] Add update feature.
- [x] Add functionality to execute terminal commands from Second.<br>
<br>
## Building:<br>
1. Install the following applications:<br>
&emsp;[`Python-3.11.6`](http://python.org/)<br>
&emsp;[`Inno Setup-6.2.2`](http://jrsoftware.org/)<br>
<br>
2. Install the following Python packages (present in `requirements.txt`):<br>
  `certifi==2024.2.2`<br>
&emsp;`Cython==3.0.10`<br>
&emsp;`fastnumbers==5.1.0`<br>
&emsp;`idna==3.6`<br>
&emsp;`Nuitka==2.0.6`<br>
&emsp;`ordered-set==4.1.0`<br>
&emsp;`packaging==24.0`<br>
&emsp;`psutil==5.9.8`<br>
&emsp;`requests==2.31.0`<br>
&emsp;`urllib3==2.2.1`<br>
&emsp;`zstandard==0.22.0`<br><br>
3. Build [Cython](http://github.com/cython/cython) modules:<br>
&emsp;Run the following command to build the `.pyd` files:<br>
&emsp;`python setup.py build_ext --inplace`<br>
&emsp;This outputs three `.pyd` files: `globalNamespace.pyd`, `base.pyd`, `printStrings.pyd`<br><br>
4. Build [Nuitka](http://github.com/Nuitka/Nuitka) executable:<br>
&emsp;Run the following command to build the Nuitka executable (please change the required paths as per your computer):<br>
&emsp;`python -m nuitka --standalone --follow-imports --mingw64 --warn-unusual-code --windows-icon-from-ico=second4.ico --company-name="Infinite Inc." --product-name="Second 4.0" --file-version=1.0.0.0 --product-version=4.0 --file-description="Second 4.0 Interpreter" --copyright="Apache-2.0" --include-data-files=settings.dat=. second4.py`<br><br>
5. (Optional) Build Inno Setup installer archive:<br>
&emsp;Run `script4.0.iss` to produce the installer.
