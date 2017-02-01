// Based on code in Python's `configure` script (see conftest.c)

#include <stdio.h>

#undef bfin
#undef cris
#undef fr30
#undef linux
#undef hppa
#undef hpux
#undef i386
#undef mips
#undef powerpc
#undef sparc
#undef unix

char *PLATFORM_TRIPLET =

#if defined(__linux__)
# if defined(__x86_64__) && defined(__LP64__)
        "x86_64-linux-gnu"
# elif defined(__x86_64__) && defined(__ILP32__)
        "x86_64-linux-gnux32"
# elif defined(__i386__)
        "i386-linux-gnu"
# elif defined(__aarch64__) && defined(__AARCH64EL__)
#  if defined(__ILP32__)
        "aarch64_ilp32-linux-gnu"
#  else
        "aarch64-linux-gnu"
#  endif
# elif defined(__aarch64__) && defined(__AARCH64EB__)
#  if defined(__ILP32__)
        "aarch64_be_ilp32-linux-gnu"
#  else
        "aarch64_be-linux-gnu"
#  endif
# elif defined(__alpha__)
        "alpha-linux-gnu"
# elif defined(__ARM_EABI__) && defined(__ARM_PCS_VFP)
#  if defined(__ARMEL__)
        "arm-linux-gnueabihf"
#  else
        "armeb-linux-gnueabihf"
#  endif
# elif defined(__ARM_EABI__) && !defined(__ARM_PCS_VFP)
#  if defined(__ARMEL__)
        "arm-linux-gnueabi"
#  else
        "armeb-linux-gnueabi"
#  endif
# elif defined(__hppa__)
        "hppa-linux-gnu"
# elif defined(__ia64__)
        "ia64-linux-gnu"
# elif defined(__m68k__) && !defined(__mcoldfire__)
        "m68k-linux-gnu"
# elif defined(__mips_hard_float) && defined(_MIPSEL)
#  if _MIPS_SIM == _ABIO32
        "mipsel-linux-gnu"
#  elif _MIPS_SIM == _ABIN32
        "mips64el-linux-gnuabin32"
#  elif _MIPS_SIM == _ABI64
        "mips64el-linux-gnuabi64"
#  else
#       "unknown platform triplet"
#  endif
# elif defined(__mips_hard_float)
#  if _MIPS_SIM == _ABIO32
        "mips-linux-gnu"
#  elif _MIPS_SIM == _ABIN32
        "mips64-linux-gnuabin32"
#  elif _MIPS_SIM == _ABI64
        "mips64-linux-gnuabi64"
#  else
#       "unknown platform triplet"
#  endif
# elif defined(__or1k__)
        "or1k-linux-gnu"
# elif defined(__powerpc__) && defined(__SPE__)
        "powerpc-linux-gnuspe"
# elif defined(__powerpc64__)
#  if defined(__LITTLE_ENDIAN__)
        "powerpc64le-linux-gnu"
#  else
        "powerpc64-linux-gnu"
#  endif
# elif defined(__powerpc__)
        "powerpc-linux-gnu"
# elif defined(__s390x__)
        "s390x-linux-gnu"
# elif defined(__s390__)
        "s390-linux-gnu"
# elif defined(__sh__) && defined(__LITTLE_ENDIAN__)
        "sh4-linux-gnu"
# elif defined(__sparc__) && defined(__arch64__)
        "sparc64-linux-gnu"
# elif defined(__sparc__)
        "sparc-linux-gnu"
# else
#       "unknown platform triplet"
# endif
#elif defined(__FreeBSD_kernel__)
# if defined(__LP64__)
        "x86_64-kfreebsd-gnu"
# elif defined(__i386__)
        "i386-kfreebsd-gnu"
# else
#       "unknown platform triplet"
# endif
#elif defined(__gnu_hurd__)
        "i386-gnu"
#elif defined(__APPLE__)
        "darwin"
#else
#       "unknown platform triplet"
#endif
                                  ;

int main()
{
    printf("%s", PLATFORM_TRIPLET);

    return 0;
}
