import sys
import os
import setup_py_env
from pathlib import Path
import print_site
from automata import Automata

is_nt = os.name == 'nt'
PATHSEP = ';' if is_nt else ':'


def _prepend_path(env, ename, prepend_str):

    curpath = env.get(ename, None)
    oldpath = '' if not curpath else f'{PATHSEP}{curpath}'
    env[ename] = f'{prepend_str}{oldpath}'


def _set_py_env(PR, worklist):

    print('\nset_py_env')

    # modify copy of env
    env = os.environ.copy()

    for job in worklist:
        ename = job[0]
        vallist = job[1:]

        # update the env
        fpath = PATHSEP.join([str(val) for val in vallist])
        _prepend_path(env, ename, fpath)

        # report result
        print_site.print_env(env, ename)

    return env


def set_unix_py_env(PR):

    # assume python 3.7
    pyvdir = 'python3.7'
    worklist = (
        ('PATH', PR / 'bin'),  # exe
        ('LD_LIBRARY_PATH', PR / 'lib'),  # .so
        ('PYTHONPATH', PR / 'lib' / pyvdir, PR / 'lib')
    )
    return _set_py_env(PR, worklist)


def set_win_py_env(PR):

    worklist = (
        ('PATH', PR / 'Scripts', PR),  # .exe
        ('PYTHONPATH', PR / 'lib', PR / 'DLLs')  # pyd
    )
    return _set_py_env(PR, worklist)


def run_script(a, PR, SCRIPT, ARGS):

    print('run_py_ver')
    print(f'PYTHONROOT={PR}')
    print(f'SCRIPT={SCRIPT}')

    # spawn python child env with corrected env
    pyexe = setup_py_env.pyexe(PR)
    argstr = ' '.join(ARGS)
    childenv = set_unix_py_env(PR) if not is_nt else set_win_py_env(PR)
    a.run_string(f'{pyexe} -s {SCRIPT} {argstr}', env=childenv)


def usage():
    msg = f""" \
Usage: python {__file__} python_root script_path
"""
    print(msg)
    sys.exit(-1)


def main(argv=None):
    if argv is None:
        argv = sys.argv

    if len(argv) < 3:
        usage()

    # caller to pass pyroot
    PR = Path(argv[1])
    # and script name to run
    SCRIPT = argv[2]
    # now arguments to script
    ARGS = []
    if len(argv) > 2:
        ARGS = argv[3:]

    logfile = 'log.txt'
    asi = os.environ['ASI']
    a = Automata(asi, log_name=logfile, showcmds=True, verbose=False)

    run_script(a, PR, SCRIPT, ARGS)


if __name__ == '__main__':
    sys.exit(main())
