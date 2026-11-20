"""Smoke test for a Python interpreter cross-compiled for Android.

Usage: python android_smoke_test.py <expected-android-api-level>
"""

import importlib
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
required = ["math", "json", "re", "zlib", "decimal", "struct", "datetime", "select", "socket", "hashlib"]
# Modules that depend on third-party libraries that may not be available
optional = ["_ssl", "sqlite3", "_bz2", "_lzma", "_ctypes", "readline", "_curses"]

for name in required + optional:
    try:
        importlib.import_module(name)
        print(f"  {name}: ok")
    except ImportError as e:
        print(f"  {name}: not available ({e})")
        if name in required:
            errors.append(f"required module {name} failed to import")

from decimal import Decimal
import zlib
if str(Decimal(1) / Decimal(7)) != "0.1428571428571428571428571429":
    errors.append("decimal computation returned an unexpected result")
if zlib.decompress(zlib.compress(b"python" * 100)) != b"python" * 100:
    errors.append("zlib round-trip failed")
if repr(3.14) != "3.14":
    errors.append(f"repr(3.14) is {repr(3.14)} (short float repr is not enabled)")

if errors:
    sys.exit("Smoke test failed:\n  " + "\n  ".join(errors))
print("Smoke test passed")
