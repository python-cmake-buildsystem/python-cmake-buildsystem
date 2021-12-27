#!/usr/bin/env python
"""alternative build script for python documentation.

This script runs the sphix documentation build.

Example:
    $> make.py

In python for python.
"""

#TODO adds blurb support

import sys
import os.path
import logging
import textwrap
import argparse

# dependencies
try:
    import sphinx
except ImportError:
    print("""
The 'sphinx-build' command was not found. Make sure you have Sphinx
installed, then set the SPHINXBUILD environment variable to point
to the full path of the 'sphinx-build' executable. Alternatively you
may add the Sphinx directory to PATH.

If you don't have Sphinx installed, grab it from
  http://sphinx-doc.org/
"""
)
    sys.exit(1)

try:
    import blurb
except ImportError:
    print("""
The blurb package was not found. 
Installing blurb with 
  {e} -m pip install blurb

""".format(e=sys.executable)
)
    sys.exit(1)


# The script begins here!!

from sphinx.util.docutils import docutils_namespace
from sphinx.application import Sphinx
from sphinx.util.console import nocolor


logger = logging.getLogger('main')


def npath(*parts):
    if sys.platform != 'win32':
        parts = [ a.replace('\\', ospath.sep) for a in parts ]
    x = os.path.join(*parts)
    x = os.path.expanduser(x)
    x = os.path.normpath(x)
    return x


def split_doc(txt):
    if not txt:
        return '', ''
    descr, _, epi = txt.lstrip().partition('\n')
    epi = textwrap.dedent(epi)
    return descr, epi.strip()


def main(o):

    builder = 'html'

    overrides = {}
    #overrides['version'] = '1.2.3'
    #overrides['release'] = '4'

    #overrides['html_theme'] = 'classic'


    status = sys.stdout
    warning = sys.stderr
    freshenv = False

    warningserror = None
    tags = []
    verbosity = 0
    jobs = 0

    force_all = o.force
    filenames = o.filenames

    nocolor()

    with docutils_namespace():
        app = Sphinx(o.srcdir, o.confdir,
                     o.dstdir, o.doctrees,
                     builder, overrides, 
                     status, warning, freshenv,
                     warningserror, tags, verbosity, jobs)
        app.build(force_all, filenames)
        return app.statuscode

		
def parse_args(args=None):
    description, epilog = split_doc(__doc__)
    class StandardFormatter(argparse.ArgumentDefaultsHelpFormatter,
                            argparse.RawDescriptionHelpFormatter):
        pass
    parser = argparse.ArgumentParser(formatter_class=StandardFormatter,
                                     description=description, epilog=epilog)

    workdir = npath(__file__, '..')
    parser.add_argument('-f', '--force', action='store_true', default=False,
                            help='force all nodes rebuild')

    parser.add_argument('-d', '--doctrees', metavar='<OUTPUTDIR>', nargs='?',
                            default=npath(workdir, 'build', 'doctrees'),
                            help='output build directory')
    parser.add_argument('-o', '--output', dest='dstdir', metavar='<OUTPUTDIR>',
                            default=npath(workdir, 'build', 'html'),
                            help='output build directory')
    parser.add_argument('-i', '--srcdir', metavar='<SOURCEDIR>',
                            default=npath(workdir),
                            help='input dource dir')

    parser.add_argument('filenames', nargs='*')

    options = parser.parse_args(args)

    # sphinx directory containing the config file
    options.confdir = workdir

    filenames = []
    for f in options.filenames or []:
        filenames.append(npath(f, 'index') if os.path.isdir(f) else f)
    options.filenames = filenames
    return options
		

if __name__ == '__main__':
    sys.exit(main(parse_args()) or 0)
