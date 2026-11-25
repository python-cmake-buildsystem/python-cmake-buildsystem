# Unit tests of the Python test suite to run on Android devices.
#
# Sourced by android_build_and_test.sh. Usage:
#   android_tests <all|in-process> <device-api-level> <python-major.minor> <builtin:0|1>
# Sets the "tests" and "ignored" arrays (test names, and patterns of test cases to skip).
#
# Python < 3.13 does not support Android officially, so its test suite makes assumptions
# that do not hold on Android. The test cases failing because of them are skipped below.

android_tests() {
  local mode=$1 api_level=$2 py_version=$3 builtin=$4
  local py_minor=${py_version#*.}

  # Tests that do not start processes, so that they can run on devices that cannot
  # fork() (ARM executables run using binary translation on x86_64 emulators).
  # They cover the numeric, text and data format code, which depends on the
  # architecture (e.g. the libmpdec configuration of the decimal module).
  tests=(
    test_array test_binascii test_bisect test_bytes test_cmath test_codecs
    test_codecencodings_cn test_codecencodings_hk test_codecencodings_jp
    test_codecencodings_kr test_codecencodings_tw test_collections test_complex
    test_csv test_datetime test_decimal test_dict test_enum test_float test_format
    test_fractions test_functools test_hashlib test_heapq test_hmac test_int
    test_itertools test_long test_math test_memoryview test_multibytecodec
    test_operator test_pickle test_random test_re test_set test_statistics
    test_string test_strtod test_struct test_unicode test_unicodedata test_zlib
  )
  ignored=()

  if [[ "${mode}" == "all" ]]; then
    # Tests of the operating system interfaces, whose availability is detected by
    # the configuration checks.
    # test_concurrent_futures is not run, because its cleanup requires the
    # multiprocessing resource tracker (see below).
    tests+=(
      test_os test_posix test_time test_signal test_select test_selectors
      test_socket test_threading test_thread test_fcntl test_mmap test_resource
      test_pwd test_grp test_tempfile test_shutil test_io test_fileio test_stat
      test_locale test_platform test_sys test_sysconfig test_subprocess
      test_json test_gzip test_zipfile test_tarfile test_uuid test_asyncio
      test_logging test_pathlib test_glob test_errno test_faulthandler test_capi
    )
  else
    # These tests fork
    ignored+=('*test_after_fork*' '*test_regression_gh94675*')
  fi

  # SELinux denies creating named pipes and hard links in /data/local/tmp
  ignored+=('*test_walk_named_pipe*' '*test_glob_named_pipe*' '*test_rmtree_on_named_pipe*'
            '*TestExtractionFilters.test_pipe' '*test_hardlink_to*')
  # Signals 32 and 33 are reserved by the Android C library
  ignored+=('*test_pthread_sigmask*')
  # F_NOTIFY fails with EINVAL on the emulator images of Android >= 11
  ignored+=('*test_fcntl_64_bit*')
  # Android does not provide POSIX named semaphores and shared memory. Python < 3.13
  # requires them for the multiprocessing resource tracker (multiprocessing.managers
  # and multiprocessing.shared_memory cannot be imported).
  ignored+=('*test_111615*' '*ConfigDictTest.test_multiprocessing_queues*' '*test_hang_global_shutdown_lock*'
            '*test_lockf_exclusive*' '*test_lockf_share*' '*test_unix_events.TestFork.*')
  # No syslog daemon listening on /dev/log
  ignored+=('*UnixSysLogHandlerTest.test_udp_reconnection*')
  # The "unzip" tool of the device does not support the options used by the test
  ignored+=('*test_unzip_zipfile*')
  # The build system does not install the Makefile of the Python build
  ignored+=('*test_get_makefile_filename*' '*TestSysConfig.test_srcdir*')

  if [[ "${py_minor}" -le 9 ]]; then
    # openpty() and if_nameindex() require API level 23 and 24: tests of Python < 3.10
    # do not check that they are available
    ignored+=('*_pty*' '*ipv6_scopeid_symbolic*')
  fi
  if [[ "${py_minor}" -eq 11 ]]; then
    # Copying extended attributes fails with EACCES because of SELinux: ignored by Python >= 3.12
    ignored+=('*test_shutil.TestCopy.*' '*test_shutil.TestCopyTree.*' '*test_shutil.TestMove.*')
    # Binding the Unix sockets fails, because the path chosen by the test helper is not writable
    ignored+=('*UnixStreamTest.*' '*SCMRightsStreamTest.*')
  fi
  if [[ "${py_minor}" -eq 12 ]]; then
    # The NODEV test is run if sys.platform is "linux" (it is "android" for Python >= 3.13)
    ignored+=('*test_makedev*')
  fi

  if [[ "${builtin}" == "1" ]]; then
    # These tests load the _testmultiphase extension module from its file
    ignored+=('*Test_ModuleStateAccess*' '*test_module_state_shared_in_global*')
  fi

  if [[ "${api_level}" -le 31 ]]; then
    # Time zone rules given in the TZ environment variable are not applied as expected on Android <= 12 images
    ignored+=('*test_timestamp_naive*')
  fi
  if [[ "${api_level}" -le 23 ]]; then
    # On Android <= 6 images, "adb shell" runs as root, which enables tests changing the
    # owner of files (the uid of the test archive overflows on 32-bit targets), there is no service database
    # and /dev/stdin cannot be reopened
    ignored+=('*NoneInfoExtractTests*' '*test_create_connection_service_name*' '*test_devstdin_input*')
    # Changing the mode of a symbolic link is not supported by old kernels
    ignored+=('*test_cleanup_with_symlink_modes*')
    # The dynamic linker of Android 5 cannot run executables whose path is longer than
    # 128 characters, such as the interpreter of the virtual environments of these tests
    ignored+=('*test_config_vars_depend_on_site_initialization*' '*test_config_vars_recalculation_after_site_initialization*')
    # The child process occasionally does not exit on the Android 5 x86 image
    ignored+=('*test_is_alive_after_fork*')
  fi
}
