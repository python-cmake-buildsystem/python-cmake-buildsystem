"""Smoke test for a Python interpreter cross-compiled for Android.

Usage: python android_smoke_test.py <expected-android-api-level>
"""

import importlib
import importlib.machinery
import os
import platform
import sys
import sysconfig

expected_api_level = int(sys.argv[1])

print(sys.version)
print("machine:", platform.machine(), "platform:", sys.platform)
print("SOABI:", sysconfig.get_config_var("SOABI"))
print("Android API level:", sys.getandroidapilevel())

errors = []
if sys.getandroidapilevel() != expected_api_level:
    errors.append(f"sys.getandroidapilevel() is {sys.getandroidapilevel()}, expected {expected_api_level}")
if not sysconfig.get_config_var("SOABI"):
    errors.append("SOABI is not available from sysconfig")

# Modules that are expected to be available
required = ["math", "json", "re", "zlib", "decimal", "struct", "datetime", "select", "socket", "hashlib",
            "array", "binascii", "_csv", "_datetime", "_md5", "_sha1", "_sha2", "_sha256", "_sha512", "_random",
            "_bisect", "_heapq", "_pickle", "_struct", "_json", "_posixsubprocess", "fcntl", "mmap",
            "pwd", "resource", "termios", "unicodedata", "_multibytecodec", "_codecs_cn", "_codecs_jp",
            "_elementtree", "pyexpat", "_socket", "_queue", "_contextvars", "_asyncio"]
# Modules that depend on third-party libraries that may not be available, on functions
# that are not available at the minimum API level (grp requires getgrent(), API level 26),
# or that are not built by this build system (_statistics)
optional = ["grp", "_statistics", "_ssl", "sqlite3", "_bz2", "_lzma", "_ctypes", "readline", "_curses", "_curses_panel",
            "_dbm", "_gdbm", "_tkinter", "_uuid", "nis", "_crypt", "spwd", "ossaudiodev"]
# Modules that are not available in all Python versions
# (minimum version, maximum version excluded)
version_specific = {"_sha2": ((3, 12), (99,)), "_sha256": ((0,), (3, 12)), "_sha512": ((0,), (3, 12))}

for name in required + optional:
    if name in version_specific and not (version_specific[name][0] <= sys.version_info < version_specific[name][1]):
        continue
    try:
        importlib.import_module(name)
        print(f"  {name}: ok")
    except ImportError as e:
        print(f"  {name}: not available ({e})")
        if name in required:
            errors.append(f"required module {name} failed to import: {e}")

# Extension modules are linked allowing undefined symbols, so a missing symbol is
# only reported when the module is loaded: import every extension module that was built.
extension_suffixes = tuple(importlib.machinery.EXTENSION_SUFFIXES)
extension_modules = set()
for path in sys.path:
    if os.path.isdir(path):
        for file_name in os.listdir(path):
            if file_name.endswith(extension_suffixes):
                extension_modules.add(file_name.split(".", 1)[0])
print(f"Importing {len(extension_modules)} extension modules and {len(sys.builtin_module_names)} built-in modules")
for name in sorted(extension_modules) + sorted(sys.builtin_module_names):
    try:
        importlib.import_module(name)
    except ImportError as e:
        if name not in optional:
            errors.append(f"extension module {name} failed to import: {e}")
if not extension_modules and "_decimal" not in sys.builtin_module_names:
    errors.append("no extension modules found")

from decimal import Decimal
import zlib
if str(Decimal(1) / Decimal(7)) != "0.1428571428571428571428571429":
    errors.append("decimal computation returned an unexpected result")
if str(Decimal(2).sqrt()) != "1.414213562373095048801688724":
    errors.append("decimal square root returned an unexpected result")
if zlib.decompress(zlib.compress(b"python" * 100)) != b"python" * 100:
    errors.append("zlib round-trip failed")
if repr(3.14) != "3.14":
    errors.append(f"repr(3.14) is {repr(3.14)} (short float repr is not enabled)")
if float("1e308") * 10 != float("inf") or (2 ** 100) // 3 != 422550200076076467165567735125:
    errors.append("float or integer arithmetic returned an unexpected result")

import hashlib
if hashlib.sha256(b"abc").hexdigest() != "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad":
    errors.append("SHA-256 returned an unexpected result")

import threading
results = []
threads = [threading.Thread(target=lambda i=i: results.append(i * i)) for i in range(4)]
for t in threads:
    t.start()
for t in threads:
    t.join()
if sorted(results) != [0, 1, 4, 9]:
    errors.append("threads returned an unexpected result")

import socket
a, b = socket.socketpair()
a.sendall(b"ping")
if b.recv(4) != b"ping":
    errors.append("socket pair round-trip failed")
a.close()
b.close()

import time
if time.localtime(0).tm_year not in (1969, 1970) or time.strftime("%Y", time.gmtime(0)) != "1970":
    errors.append("time conversion returned an unexpected result")

if errors:
    sys.exit("Smoke test failed:\n  " + "\n  ".join(errors))
print("Smoke test passed")
