import sys
import os
import re
import print_site
from automata import Automata
from pathlib import Path

is_debug = False
is_nt = os.name == 'nt'
bindir = 'Scripts' if is_nt else 'bin'
ext = '.exe' if is_nt else ''


def fix_activate_path(VRdir):

    new_lines = []
    fn = Path(VRdir) / bindir / 'activate'
    with open(fn, 'r') as fh:
        sexp = re.compile(r"VIRTUAL_ENV='(.+)'")
        for line in fh:
            # VIRTUAL_ENV='C:\Users\appsmith\asv\pyenv\glue-run-dbg'
            m = sexp.search(line)
            if m:
                # convert slashes
                the_path = str(Path(m.group(1)).as_posix())
                # fix drive letter
                fix_path = f'/{the_path[0].lower()}{the_path[2:]}'
                line = f"VIRTUAL_ENV='{fix_path}'\n"
            new_lines.append(line)

    with open(fn, 'w') as fh:
        print(''.join(new_lines), file=fh)


def pyexe(PR):
    return PR / bindir / f'python{ext}'


def ensure_pip(a, PR):
    pe = pyexe(PR)
    a.run_string(f'{pe} -s -m ensurepip --default-pip --upgrade --verbose')


def upgrade_pip(a, PR):
    pe = pyexe(PR)
    a.run_string(f'{pe} -s -m pip install --upgrade --verbose pip')


def compose_venv_root(PR):

    # where do we put the venv?
    drive = 'i:/' if is_nt else '/i'
    vext = 'dbg' if 'debug' in str(PR) else 'rel'
    return Path(drive, 'pyenv', f'glue-run-{vext}')


def make_venv(a, PR, VRdir):
    venvexe = PR / bindir / f'virtualenv{ext}'
    pyexe = PR / bindir / f'python{ext}'
    a.run_string(f'{venvexe} {VRdir} --python={pyexe} --verbose --always-copy --clear')

    if is_nt:
        fix_activate_path(VRdir)


def activate_venv(a, VR):

    # activate the venv - sets a few vars
    # https://stackoverflow.com/questions/436198/what-is-an-alternative-to-execfile-in-python-3
    activate_script = VR / bindir / 'activate_this.py'
    myglobals = dict(
        __file__=activate_script,
        __name__='__main__'
    )

    print(f'activating virtualenv={VR} with {activate_script}')
    with open(activate_script, 'rb') as f:
        code = compile(f.read(), activate_script, 'exec')
        exec(code, myglobals)

    print_site.print_site()


def install_pkgs(a, pkglist, PR, do_upgrade=True):
    pe = pyexe(PR)
    pkgs = ' '.join(pkglist)
    uparg = '' if not do_upgrade else '--upgrade'
    a.run_string(f'{pe} -s -m pip install {uparg} --verbose {pkgs}')


def install_ports(a, portlist, PR=None):
    drive = 'i:/' if is_nt else '/i'
    portboy = Path(drive, 'ports', 'scripts', 'portboy.py')
    pe = pyexe(PR)
    repo_str = ' '.join(portlist)
    a.run_string(f'{pe} {portboy} {repo_str}')


def install_virtualenv(a, PR=None):
    pkglist = ('virtualenv==16.7.9',)
    install_pkgs(a, pkglist, PR, do_upgrade=False)


def install_our_pkgs(a, PR=None):

    # list of packages
    pkglist = (
        'docopt',
        'msgpack',
        'mashumaro',
        'mashuhelpa',
        'rpyc',
        'pyyaml',
        'sqlalchemy',
        'fdb',
        'graphql-core',
        'pyrsistent',
        'datetime',
        'snakemake',
        'twine',
        'region_profiler',
    )
    portlist = (
        'pypreprocessor',
    )

    install_pkgs(a, pkglist, PR)
    install_ports(a, portlist, PR)


def copy_python_exe(a, PR):

    pydir = PR / bindir

    # copy python to python3
    a.cp(
        pydir / f'python{ext}',
        pydir / f'python3{ext}')


def fix_dll_search_path():
    import win_fix_dlls
    win_fix_dlls.add_path_to_dll_search(True)


def fix_dll(fname, use_dbg_stem='_d'):
    suffix = '.dll' if is_nt else '.so'
    prefix = '' if is_nt else 'lib'
    dbg_stem = use_dbg_stem if is_debug else ''
    return f'{prefix}{fname}{dbg_stem}{suffix}'


def fix_dll_list(base_list, use_dbg_stem='_d'):
    return [p.parent / fix_dll(p.name, use_dbg_stem) for p in base_list]


def copy_ext_dlls(a, PR):

    if is_nt:
        # 3.8+ extensions and c-types don't search PATH!!!
        # so dlls have to be alongside the pyd
        dll_subdir = 'bin' if is_nt else 'lib'
        plat_dir = Path(os.environ['ASV_PLAT_PORTS'])
        plat_dll_dir = plat_dir / dll_subdir
        debug_list = [
            plat_dll_dir / 'libssl32MD',
            plat_dll_dir / 'libcrypto32MD'
        ]
        no_debug_list = [
            plat_dll_dir / 'zlib',
            plat_dll_dir / 'libffi',
            plat_dll_dir / 'libexpat',
            plat_dll_dir / 'sqlite3-shared',
        ]
        dll_list = fix_dll_list(debug_list, 'd') + fix_dll_list(no_debug_list, '')

        # libffi debug does not work...
        a.cp(dll_list, PR / 'DLLs')


def do_setup(a, PR):

    # fix_dll_search_path()

    print(f'setup_py_env::do_setup {PR}')

    # on Windows, pip and such will fish in the registry
    # path still has various python versions first
    # better all be at same level!
    print_site.print_site()

    # install into our build
    copy_python_exe(a, PR)
    copy_ext_dlls(a, PR)

    ensure_pip(a, PR)
    upgrade_pip(a, PR)
    install_virtualenv(a, PR)

    # create a virtualenv using python install
    VR = compose_venv_root(PR)
    make_venv(a, PR, VR)
    activate_venv(a, VR)
    upgrade_pip(a, VR)
    install_our_pkgs(a, VR)


def usage():
    msg = f"""\
Usage: python {__file__} python_root
"""
    print(msg)
    sys.exit(-1)


def main(argv=None):
    global is_debug
    if argv is None:
        argv = sys.argv

    if len(argv) < 2:
        usage()
        return -1

    # caller to pass pyroot
    PR = Path(argv[1])
    is_debug = 'debug' in str(PR)

    logfile = 'log.txt'
    asi = os.environ['ASI']
    a = Automata(asi, log_name=logfile, showcmds=True, verbose=False)

    do_setup(a, PR)

    return 0


if __name__ == '__main__':
    sys.exit(main())
