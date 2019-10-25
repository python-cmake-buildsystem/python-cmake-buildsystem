

* ``0001-VS2010-Support-Backport-Fix-13210.-Port-the-Windows-.patch``: This patch
  is a partial backport of `python/cpython@401f9f3 <https://github.com/python/cpython/commit/401f9f3>`_.

  Changes to the following modules have **NOT** been backported:

  * ``Tools/msi``
  * ``Tools/buildbot``
  * ``PCBuild``

  It applies to the following versions of Visual Studio:

  * 1600: VS2010
  * 1700: VS2012
  * 1800: VS2013
  * 1900: VS2015

* ``0002-VS2015-Support-Backport-Issue-22919-Windows-build-up.patch``: This patch
  is a partial backport of `python/cpython@65e4cb1 <https://github.com/python/cpython/commit/65e4cb1>`_.

  Changes to the following modules have **NOT** been backported:

  * ``Lib/distutils/sysconfig``
  * ``Modules/socketmodule.c``: Not required since changes related to WSA have been introduced
    in Python 3.x (see `python/cpython@6b4883d <https://github.com/python/cpython/commit/6b4883d>`)
  * ``Tools/buildbot``
  * ``PCBuild``

  It applies to the following versions of Visual Studio:

  * 1900: VS2015


* ``0003-VS2015-Support-Backport-of-Issue-23524-Replace-_PyVe.patch``: This patch
  is a partical backport of `python/cpython@d81431f <https://github.com/python/cpython/commit/d81431f>`_

  This patch do not backport the define of "timezone" as "_timezone" as it was done in Python 3.x.
  Keeping "timezone" is required in Python 2.7.x to avoid the following build issue
  ``error C2032: '__timezone': function cannot be member of struct '__timeb64'`` associated with ``sys/timeb.h``.
  The need for ``sys/timeb.h`` was removed in Python 3.x in `python/cpython@6fc4ade <https://github.com/python/cpython/commit/6fc4ade>`_
  and `python/cpython@0011124  <https://github.com/python/cpython/commit/0011124>`_ but is still used in Python 2.7.x.

  Changes to the following modules have **NOT** been backported:

  * ``PCbuild``


References
----------

* Microsoft Visual C++ - Internal version numbering
  See https://en.wikipedia.org/wiki/Microsoft_Visual_C%2B%2B#Internal_version_numbering
