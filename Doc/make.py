#!/usr/bin/env python
import sys
import os.path
import logging
import argparse


logger = logging.getLogger('main')


def npath(*parts):
    if sys.platform != 'win32':
        parts = [ a.replace('\\', ospath.sep) for a in parts ]
    x = os.path.join(*parts)
    x = os.path.expanduser(x)
    x = os.path.normpath(x)
    return x


def parse_args(args=None):
    parser = argparse.ArgumentParser()

    workdir = npath(__file__, '..')

    parser.add_argument('dstdir', metavar='<OUTPUTDIR>', nargs='?',
                            default=npath(workdir, '..', 'build', 'docs', 'html'),
                            help='output build directory')

    parser.add_argument('srcdir', metavar='<SOURCEDIR>', nargs='?',
                            default=npath(workdir),
                            help='input dource dir')
    options = parser.parse_args(args)

    # sphinx related
    options.confdir = workdir

    return options


def main(o):
    from sphinx.util.docutils import docutils_namespace
    from sphinx.application import Sphinx

    
    doctreedir = npath(o.dstdir, '.doctrees')
    builder = 'html'

    overrides = {}
    overrides['version'] = '1.2.3'
    overrides['release'] = '4'
    #overrides['html_theme'] = 'classic'


    status = sys.stdout
    warning = sys.stderr
    freshenv = True

    warningserror = None
    tags = []
    verbosity = 0
    jobs = 0

    force_all = True
    filenames = []


    with docutils_namespace():
        app = Sphinx(o.srcdir, o.confdir,
                     o.dstdir, doctreedir, 
                     builder, overrides, 
                     status, warning, freshenv,
                     warningserror, tags, verbosity, jobs)
        app.build(force_all, filenames)
        return app.statuscode


if __name__ == '__main__':
    sys.exit(main(parse_args()) or 0)
