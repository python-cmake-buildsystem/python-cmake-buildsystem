# Unit tests of the Python test suite to run on Android devices.
#
# Sourced by android_build_and_test.sh. Usage:
#   android_tests <all|in-process> <device-api-level> <python-major.minor>
# Sets the "tests" and "ignored" arrays (test names, and patterns of test cases to skip).

android_tests() {
  local mode=$1 api_level=$2 py_version=$3

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
    # the configuration checks
    tests+=(
      test_os test_posix test_time test_signal test_select test_selectors
      test_socket test_threading test_thread test_fcntl test_mmap test_resource
      test_pwd test_grp test_tempfile test_shutil test_io test_fileio test_stat
      test_locale test_platform test_sys test_sysconfig test_subprocess
      test_json test_gzip test_zipfile test_tarfile test_uuid test_asyncio
      test_concurrent_futures test_logging test_pathlib test_glob test_errno
      test_faulthandler test_capi
    )
  fi

  # Creating named pipes is denied by SELinux on Android (skipped by Python >= 3.13 test suite)
  ignored+=('*test_walk_named_pipe*')

  if [[ "${api_level}" -le 30 ]]; then
    # Time zone rules given in the TZ environment variable are not applied as expected on Android 11 images
    ignored+=('*test_timestamp_naive*')
  fi
}
