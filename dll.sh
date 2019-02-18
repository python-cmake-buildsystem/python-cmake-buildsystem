#!/usr/bin/env bash

declare pydir='python-debug'
declare pydir='python'
declare -r PR="${ASV_PLAT_PORTS}/${pydir}"
declare -r pyexe="${PR}/Scripts/python.exe"

# python ignores PATH, so this is meaningless
dlldiag deps "${ASV_PLAT_PORTS}/${pydir}/DLLs/pyexpat.pyd"
dlldiag deps "${ASV_PLAT_PORTS}/${pydir}/DLLs/_ssl.pyd"

${pyexe} -c "import _socket;print(_socket)"
# ensurepip "no module _winreg"
${pyexe} -c "import _ctypes;print(_ctypes)"
# ensurepip can't read XML
# need static link version...
${pyexe} -c "import pyexpat;print(pyexpat)"
# pip can't do SSL
${pyexe} -c "import _ssl;print(_ssl)"

exit

# problem modules
2020-04-29-python-38-loadlibrary-breakage
https://docs.google.com/document/d/1Ap4n2-McAD9g5ve7V2wfqluaL-f1j11n6gBu4JfebKE

/i/ports/vs16-32/python/Scripts/python.exe -c "import elementtree"
/i/ports/vs16-32/python/Scripts/python.exe -s -m ensurepip --default-pip --upgrade --verbose
i:/pyenv/glue-run-rel/Scripts/python.exe -s -m pip install --upgrade

# debugger path
PATH=I:\ports\build-32\python-vs\bin\Debug;I:\ports\build-32\python-vs\Scripts\Debug;%PATH%
PYTHONPATH=I:\ports\build-32\python-vs\Lib\lib-Dynload\Debug;I:\ports\build-32\python-vs\Lib;$PYTHONPATH%

# path with install
PATH=I:\ports\vs16-32\python-vs\Scripts;I:\ports\vs16-32\python-debug\DLLs;I:\ports\vs16-32\python-debug;%PATH%
PYTHONPATH=I:\ports\vs16-32\python-debug\lib;I:\ports\vs16-32\python-debug\DLLs;I:\install\appsmith\vs16-32\winglue\python;I:\src\winglue\python;I:\scripts\pylib;$PYTHONPATH%
