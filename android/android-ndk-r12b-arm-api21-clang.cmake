# Android CMake Clang toolchain file for Android NDK r12b and arch armv7-a

########################################
# NDK 12b download link:
# Windows 32-bit:     http://dl.google.com/android/repository/android-ndk-r12b-windows-x86.zip
# Windows 64-bit:     http://dl.google.com/android/repository/android-ndk-r12b-windows-x86_64.zip
# Mac OS X:           http://dl.google.com/android/repository/android-ndk-r12b-darwin-x86_64.zip
# Linux 64-bit (x86): http://dl.google.com/android/repository/android-ndk-r12b-linux-x86_64.zip

########################################
# Required env var:
# - ANDROID_SDK: path to the Android SDK
# - ANDROID_NDK: path to the Android NDK

include(${CMAKE_CURRENT_LIST_DIR}/utils/android.utils.cmake)

########################################
set(CMAKE_SYSTEM_NAME Android)
set(CMAKE_SYSTEM_VERSION 1)

# rpath makes low sence for Android
set(CMAKE_SKIP_RPATH TRUE CACHE BOOL "If set, runtime paths are not added when using shared libraries." )
set(CMAKE_SYSTEM_PROCESSOR "armv7-a")

set(CMAKE_CROSSCOMPILING TRUE)

set(ANDROID_NDK_VERSION      "r12b"        CACHE STRING "Android NDK version")
set(ANDROID_ARCH             "armeabi-v7a" CACHE STRING "Android target architecture")
set(ANDROID_API_LEVEL        "21"          CACHE STRING "Android API level")
set(ANDROID_STL              "c++_shared"  CACHE STRING "Android C++ runtime library")


########################################
# Install standalone Android toolchain
set(ANDROID_STANDALONE_TOOLCHAIN_PATH "${ANDROID_NDK_PATH}/android-toolchain-${ANDROID_NDK_VERSION}" CACHE PATH "Android standalone toolchain folder dir")
if(NOT EXISTS "${ANDROID_STANDALONE_TOOLCHAIN_PATH}")
    set(TOOLCHAIN_ARGS "${ANDROID_NDK_PATH}/build/tools/make_standalone_toolchain.py" 
                       --api "${ANDROID_API_LEVEL}"
                       --stl "libc++" 
                       --arch "arm" 
                       --install-dir "${ANDROID_STANDALONE_TOOLCHAIN_PATH}")
    execute_process(COMMAND python ${TOOLCHAIN_ARGS}
                    WORKING_DIRECTORY "${ANDROID_NDK_PATH}/build/tools")
endif()

########################################
# for compatibility with taka-no-me toolchain
set(ANDROID_ABI ${ANDROID_ARCH})
set(ARM_TARGET ${ANDROID_ARCH})
set(ANDROID_COMPILER_VERSION 4.9)

########################################
# setup the cross-compiler
set(CMAKE_C_COMPILER   "${ANDROID_STANDALONE_TOOLCHAIN_PATH}/bin/clang38${TOOL_OS_SUFFIX}"                       CACHE FILEPATH "C compiler")
set(CMAKE_CXX_COMPILER "${ANDROID_STANDALONE_TOOLCHAIN_PATH}/bin/clang38++${TOOL_OS_SUFFIX}"                     CACHE FILEPATH "C++ compiler")
set(CMAKE_ASM_COMPILER "${ANDROID_STANDALONE_TOOLCHAIN_PATH}/arm-linux-androideabi/bin/as${TOOL_OS_SUFFIX}"      CACHE FILEPATH "assembler")
set(CMAKE_STRIP        "${ANDROID_STANDALONE_TOOLCHAIN_PATH}/arm-linux-androideabi/bin/strip${TOOL_OS_SUFFIX}"   CACHE FILEPATH "strip")
set(CMAKE_AR           "${ANDROID_STANDALONE_TOOLCHAIN_PATH}/arm-linux-androideabi/bin/ar${TOOL_OS_SUFFIX}"      CACHE FILEPATH "archive")
set(CMAKE_LINKER       "${ANDROID_STANDALONE_TOOLCHAIN_PATH}/arm-linux-androideabi/bin/ld${TOOL_OS_SUFFIX}"      CACHE FILEPATH "linker")
set(CMAKE_NM           "${ANDROID_STANDALONE_TOOLCHAIN_PATH}/arm-linux-androideabi/bin/nm${TOOL_OS_SUFFIX}"      CACHE FILEPATH "nm")
set(CMAKE_OBJCOPY      "${ANDROID_STANDALONE_TOOLCHAIN_PATH}/arm-linux-androideabi/bin/objcopy${TOOL_OS_SUFFIX}" CACHE FILEPATH "objcopy")
set(CMAKE_OBJDUMP      "${ANDROID_STANDALONE_TOOLCHAIN_PATH}/arm-linux-androideabi/bin/objdump${TOOL_OS_SUFFIX}" CACHE FILEPATH "objdump")
set(CMAKE_RANLIB       "${ANDROID_STANDALONE_TOOLCHAIN_PATH}/arm-linux-androideabi/bin/ranlib${TOOL_OS_SUFFIX}"  CACHE FILEPATH "ranlib")

set(CMAKE_C_COMPILER_TARGET armv7-none-linux-androideabi)
set(CMAKE_CXX_COMPILER_TARGET armv7-none-linux-androideabi)

########################################
# Force set compilers
set(CMAKE_C_COMPILER_ID Clang)
set(CMAKE_CXX_COMPILER_ID Clang)
set(CMAKE_C_PLATFORM_ID Linux)
set(CMAKE_CXX_PLATFORM_ID Linux)
set(CMAKE_CXX_SIZEOF_DATA_PTR 4)
set(CMAKE_C_HAS_ISYSROOT 1)
set(CMAKE_CXX_HAS_ISYSROOT 1)
set(CMAKE_C_COMPILER_ABI ELF)
set(CMAKE_CXX_COMPILER_ABI ELF)
set(CMAKE_CXX_SOURCE_FILE_EXTENSIONS cc cp cxx cpp CPP c++ C)

########################################
# force ASM compiler (required for CMake < 2.8.5)
set(CMAKE_ASM_COMPILER_ID_RUN TRUE )
set(CMAKE_ASM_COMPILER_ID GNU )
set(CMAKE_ASM_COMPILER_WORKS TRUE )
set(CMAKE_ASM_COMPILER_FORCED TRUE )
set(CMAKE_COMPILER_IS_GNUASM 1)
set(CMAKE_ASM_SOURCE_FILE_EXTENSIONS s S asm )

########################################
# flags and definitions
remove_definitions(-DANDROID)
add_definitions(-DANDROID)

########################################
# STL
set(ANDROID_STL_INCLUDE_DIRS "${ANDROID_STANDALONE_TOOLCHAIN_PATH}/include/c++/4.9.x"
                             "${ANDROID_STANDALONE_TOOLCHAIN_PATH}/include/llvm-libc++abi/include")
set(ANDROID_LIB_STL "${ANDROID_STANDALONE_TOOLCHAIN_PATH}/arm-linux-androideabi/lib/armv7-a/libc++_shared.so" )
set(ANDROID_SYSROOT "${ANDROID_STANDALONE_TOOLCHAIN_PATH}/sysroot" )
set(CMAKE_SYSROOT ${ANDROID_SYSROOT})

set(CMAKE_CXX_CREATE_SHARED_LIBRARY "<CMAKE_CXX_COMPILER> <CMAKE_SHARED_LIBRARY_CXX_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS> <CMAKE_SHARED_LIBRARY_SONAME_CXX_FLAG><TARGET_SONAME> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>" )
set(CMAKE_CXX_CREATE_SHARED_MODULE  "<CMAKE_CXX_COMPILER> <CMAKE_SHARED_LIBRARY_CXX_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS> <CMAKE_SHARED_LIBRARY_SONAME_CXX_FLAG><TARGET_SONAME> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>" )
set(CMAKE_CXX_LINK_EXECUTABLE       "<CMAKE_CXX_COMPILER> <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>" )
set(CMAKE_CXX_CREATE_SHARED_LIBRARY "${CMAKE_CXX_CREATE_SHARED_LIBRARY} ${ANDROID_LIB_STL}")
set(CMAKE_CXX_CREATE_SHARED_MODULE  "${CMAKE_CXX_CREATE_SHARED_MODULE} ${ANDROID_LIB_STL}")
set(CMAKE_CXX_LINK_EXECUTABLE       "${CMAKE_CXX_LINK_EXECUTABLE} ${ANDROID_LIB_STL}")

########################################
# cache flags
set(ANDROID_CXX_FLAGS "-march=armv7-a -mfloat-abi=softfp -fsigned-char -fpic -funwind-tables -target armv7-none-linux-androideabi --sysroot=${ANDROID_SYSROOT} -Xclang -mnoexecstack -Qunused-arguments -frtti -fexceptions -fdata-sections -ffunction-sections -mfpu=neon -mfpu=vfpv3"
                            CACHE INTERNAL "Android specific c/c++ flags" )
set(ANDROID_CXX_FLAGS_RELEASE "-mthumb -fomit-frame-pointer -fno-strict-aliasing -target armv7-none-linux-androideabi"
                            CACHE INTERNAL "Android specific c/c++ Release flags" )
set(ANDROID_CXX_FLAGS_DEBUG "-marm -fno-omit-frame-pointer -fno-strict-aliasing -target armv7-none-linux-androideabi"
                            CACHE INTERNAL "Android specific c/c++ Debug flags" )
set(ANDROID_LINKER_FLAGS " -march=armv7-a -Wl,--fix-cortex-a8,--no-undefined,-z,noexecstack" CACHE INTERNAL "Android specific c/c++ linker flags" )
                              
set(CMAKE_CXX_FLAGS           "${ANDROID_CXX_FLAGS}"                               CACHE STRING "C++ flags")
set(CMAKE_C_FLAGS             "${ANDROID_CXX_FLAGS}"                               CACHE STRING "C flags")
set(CMAKE_CXX_FLAGS_RELEASE   "${ANDROID_CXX_FLAGS_RELEASE} -O3 -DNDEBUG"          CACHE STRING "C++ Release flags")
set(CMAKE_C_FLAGS_RELEASE     "${ANDROID_CXX_FLAGS_RELEASE} -O3 -DNDEBUG"          CACHE STRING "C Release flags")
set(CMAKE_CXX_FLAGS_DEBUG     "${ANDROID_CXX_FLAGS_DEBUG} -O0 -g -DDEBUG -D_DEBUG" CACHE STRING "C++ Debug flags")
set(CMAKE_C_FLAGS_DEBUG       "${ANDROID_CXX_FLAGS_DEBUG} -O0 -g -DDEBUG -D_DEBUG" CACHE STRING "C Debug flags")
set(CMAKE_SHARED_LINKER_FLAGS "${ANDROID_LINKER_FLAGS}"                            CACHE STRING "shared linker flags")
set(CMAKE_MODULE_LINKER_FLAGS "${ANDROID_LINKER_FLAGS}"                            CACHE STRING "module linker flags")
set(CMAKE_EXE_LINKER_FLAGS    "${ANDROID_LINKER_FLAGS} -Wl,-z,nocopyreloc"         CACHE STRING "executable linker flags")

########################################
# global includes and link directories
include_directories(SYSTEM "${ANDROID_SYSROOT}/usr/include" ${ANDROID_STL_INCLUDE_DIRS} )
link_directories("${ANDROID_SYSROOT}/usr/lib")

# set these global flags for cmake client scripts to change behavior
set(ANDROID TRUE )
set(BUILD_ANDROID TRUE )

# list of root paths to search on the target environment
set(CMAKE_FIND_ROOT_PATH "${ANDROID_STANDALONE_TOOLCHAIN_PATH}/bin" 
                         "${ANDROID_STANDALONE_TOOLCHAIN_PATH}/arm-linux-androideabi"
                         "${ANDROID_SYSROOT}"
                         "${ANDROID_SYSROOT}/usr"
                         "${CMAKE_INSTALL_PREFIX}") 

# only search for libraries and includes in the ndk toolchain
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
