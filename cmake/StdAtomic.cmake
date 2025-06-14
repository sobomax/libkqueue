# Check if _Atomic needs -latomic

set(LIBATOMIC_STATIC_PATH "" CACHE PATH "Directory containing static libatomic.a")

include(CheckCSourceLinks)

set(
  check_std_atomic_source_code
  [=[
  #include <stdatomic.h>
  _Atomic long long x = 0;
  void test(_Atomic long long *x, long long v) {
      atomic_store(x, v);
  }
  int main(int argc, char **argv) {
      test(&x, argc);
      return 0;
  }
  ]=])

check_c_source_links("${check_std_atomic_source_code}" std_atomic_without_libatomic)

if(NOT std_atomic_without_libatomic)
  set(CMAKE_REQUIRED_LIBRARIES atomic)
  check_c_source_compiles("${check_std_atomic_source_code}" std_atomic_with_libatomic)
  set(CMAKE_REQUIRED_LIBRARIES)
  if(NOT std_atomic_with_libatomic)
    message(FATAL_ERROR "Toolchain doesn't support C11 _Atomic with nor without -latomic")
  else()
    if(STATIC_LINK)
      find_library(ATOMIC_STATIC NAMES libatomic.a PATHS /usr/lib /usr/local/lib ${LIBATOMIC_STATIC_PATH} NO_DEFAULT_PATH)
      if(ATOMIC_STATIC)
        message(STATUS "Linking static libatomic: ${ATOMIC_STATIC}")
        target_link_libraries(standard_settings INTERFACE ${ATOMIC_STATIC})
      else()
        message(WARNING "STATIC_LINK is set but static libatomic not found; falling back to -latomic")
        target_link_libraries(standard_settings INTERFACE atomic)
      endif()
    else()
      target_link_libraries(standard_settings INTERFACE atomic)
    endif()
  endif()
endif()
