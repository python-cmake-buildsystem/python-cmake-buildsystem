"""Check that a Windows ARM64EC build of Python is really ARM64EC.

ARM64EC binaries have the x64 machine type (0x8664) and, unlike x64 binaries,
hybrid (CHPE) metadata referenced from their load configuration. An ARM64EC
process can load ARM64EC and x64 binaries, but not ARM64 ones, so a binary
silently built for the wrong architecture is either not loadable or runs
emulated.

Usage: python check_arm64ec.py <path>...

Each path is a binary (.exe, .dll, .pyd) or a directory searched recursively
for extension modules (.pyd). Other DLLs in a directory are not checked, as
dependencies such as OpenSSL may be x64. With no path, the running
interpreter, its DLLs and the extension modules of its lib-dynload directory
are checked.

Also checks that the running interpreter identifies itself as "win-amd64",
which lets pip select x64 wheels.
"""
import pathlib
import struct
import sys
import sysconfig

IMAGE_FILE_MACHINE_AMD64 = 0x8664
IMAGE_FILE_MACHINE_ARM64 = 0xAA64
IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG = 10
# Offset of CHPEMetadataPointer in IMAGE_LOAD_CONFIG_DIRECTORY64
CHPE_METADATA_POINTER_OFFSET = 200

EXTENSION_SUFFIX = ".pyd"


def rva_to_offset(sections, rva):
    for virtual_address, virtual_size, raw_offset, raw_size in sections:
        if virtual_address <= rva < virtual_address + max(virtual_size, raw_size):
            return rva - virtual_address + raw_offset
    raise ValueError(f"RVA 0x{rva:x} is not in any section")


def architecture(path):
    """Return "ARM64EC", "x64", "ARM64" or a description of another machine type."""
    data = pathlib.Path(path).read_bytes()
    if data[:2] != b"MZ":
        raise ValueError("not a PE file")
    pe = struct.unpack_from("<I", data, 0x3C)[0]
    if data[pe:pe + 4] != b"PE\0\0":
        raise ValueError("not a PE file")
    machine, section_count = struct.unpack_from("<HH", data, pe + 4)
    optional_header_size = struct.unpack_from("<H", data, pe + 20)[0]
    if machine == IMAGE_FILE_MACHINE_ARM64:
        return "ARM64"
    if machine != IMAGE_FILE_MACHINE_AMD64:
        return f"machine 0x{machine:04x}"
    optional_header = pe + 24
    # PE32+ data directories start at offset 112 of the optional header
    load_config_rva, load_config_size = struct.unpack_from(
        "<II", data, optional_header + 112 + 8 * IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG)
    if load_config_rva == 0:
        return "x64"
    section_table = optional_header + optional_header_size
    sections = []
    for i in range(section_count):
        virtual_size, virtual_address, raw_size, raw_offset = struct.unpack_from(
            "<IIII", data, section_table + 40 * i + 8)
        sections.append((virtual_address, virtual_size, raw_offset, raw_size))
    load_config = rva_to_offset(sections, load_config_rva)
    size = struct.unpack_from("<I", data, load_config)[0]
    if size < CHPE_METADATA_POINTER_OFFSET + 8:
        return "x64"
    chpe_metadata = struct.unpack_from("<Q", data, load_config + CHPE_METADATA_POINTER_OFFSET)[0]
    return "ARM64EC" if chpe_metadata else "x64"


def default_paths():
    exe = pathlib.Path(sys.executable)
    paths = [exe]
    for directory in {exe.parent, pathlib.Path(sys.base_prefix)}:
        paths += sorted(directory.glob("python*.dll"))
    # Extension modules are in the lib-dynload directory of the module search path
    paths += [path for path in sys.path if pathlib.PurePath(path).name == "lib-dynload"]
    return paths


def binaries(paths):
    for path in map(pathlib.Path, paths):
        if path.is_dir():
            yield from sorted(p for p in path.rglob("*") if p.suffix.lower() == EXTENSION_SUFFIX)
        else:
            yield path


def main(argv):
    errors = []
    platform = sysconfig.get_platform()
    print(f"sysconfig.get_platform(): {platform}")
    if platform != "win-amd64":
        errors.append(f"platform is {platform!r} instead of 'win-amd64'")

    checked = 0
    for path in binaries(argv[1:] or default_paths()):
        try:
            arch = architecture(path)
        except (OSError, ValueError, struct.error) as e:
            arch = f"unreadable ({e})"
        print(f"{arch:8} {path}")
        checked += 1
        if arch != "ARM64EC":
            errors.append(f"{path} is {arch}")
    if checked == 0:
        errors.append("no binary was found")

    for error in errors:
        print(f"ERROR: {error}")
    print(f"Checked {checked} binaries: {'FAILURE' if errors else 'SUCCESS'}")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
