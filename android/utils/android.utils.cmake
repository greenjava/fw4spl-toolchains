########################################
# macro to find packages on the host OS
macro(find_host_package )
    set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER )
    set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER )
    if(CMAKE_HOST_WIN32 )
        set(WIN32 1 )
        set(UNIX )
    elseif( CMAKE_HOST_APPLE )
        set(APPLE 1 )
        set(UNIX )
    endif()
    find_package( ${ARGN} )
    set(WIN32 )
    set(APPLE )
    set(UNIX 1 )
    set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
    set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
endmacro()

# macro to find programs on the host OS
macro(find_host_program )
    set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER )
    set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER )
    if(CMAKE_HOST_WIN32 )
        set(WIN32 1 )
        set(UNIX )
    elseif(CMAKE_HOST_APPLE )
        set(APPLE 1 )
        set(UNIX )
    endif()
    find_program( ${ARGN} )
    set(WIN32 )
    set(APPLE )
    set(UNIX 1 )
    set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
    set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
endmacro()

########################################
# detect current host platform
if(NOT DEFINED ANDROID_NDK_HOST_X64 AND (CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "amd64|x86_64|AMD64" OR CMAKE_HOST_APPLE) )
 set(ANDROID_NDK_HOST_X64 1 CACHE BOOL "Try to use 64-bit compiler toolchain" )
 mark_as_advanced( ANDROID_NDK_HOST_X64 )
endif()

set(TOOL_OS_SUFFIX "" )
if(CMAKE_HOST_APPLE )
 set(ANDROID_NDK_HOST_SYSTEM_NAME "darwin-x86_64" )
 set(ANDROID_NDK_HOST_SYSTEM_NAME2 "darwin-x86" )
elseif(CMAKE_HOST_WIN32 )
 set(ANDROID_NDK_HOST_SYSTEM_NAME "windows-x86_64" )
 set(ANDROID_NDK_HOST_SYSTEM_NAME2 "windows" )
 set(TOOL_OS_SUFFIX ".exe" )
elseif(CMAKE_HOST_UNIX )
 set(ANDROID_NDK_HOST_SYSTEM_NAME "linux-x86_64" )
 set(ANDROID_NDK_HOST_SYSTEM_NAME2 "linux-x86" )
else()
 message( FATAL_ERROR "Cross-compilation on your platform is not supported by this cmake toolchain" )
endif()

if(NOT ANDROID_NDK_HOST_X64 )
 set(ANDROID_NDK_HOST_SYSTEM_NAME ${ANDROID_NDK_HOST_SYSTEM_NAME2} )
endif()

########################################
# Find Android SDK
if(DEFINED ENV{ANDROID_SDK})
    set(ANDROID_SDK_PATH "$ENV{ANDROID_SDK}" CACHE PATH "Path to the Android SDK")
else()
    message(FATAL_ERROR "Can not find android SDK path, please set the path in env var 'ANDROID_SDK'")
endif()
file(TO_CMAKE_PATH "${ANDROID_SDK_PATH}" ANDROID_SDK_PATH)

########################################
# Find Android command line tool
find_host_program(ANDROID_EXECUTABLE
    NAMES android android.bat
    PATHS "${ANDROID_SDK_PATH}/tools"
    DOC   "The android command-line tool"
)
if(NOT ANDROID_EXECUTABLE)
    message(FATAL_ERROR "Can not find android command line tool: android")
endif()

########################################
# Find adb
find_host_program(ADB_EXECUTABLE
    NAMES adb
    PATHS "${ANDROID_SDK_PATH}/platform-tools"
    DOC   "The adb install tool"
)
if(NOT ADB_EXECUTABLE)
    message(FATAL_ERROR "Can not find ant build tool: adb")
endif()

########################################
# Find Android NDK
if(DEFINED ENV{ANDROID_NDK})
    set(ANDROID_NDK_PATH "$ENV{ANDROID_NDK}" CACHE PATH "Path to the Android NDK")
else()
    message(FATAL_ERROR "Can not find android NDK path, please set the path in env var 'ANDROID_NDK'")
endif()
file(TO_CMAKE_PATH "${ANDROID_NDK_PATH}" ANDROID_NDK_PATH)
# for compatibility with taka-no-me toolchain
set(ANDROID_NDK ${ANDROID_NDK_PATH})

########################################
# Find ndk-depends
find_host_program(NDK_DEPENDS
    NAMES ndk-depends
    PATHS ${ANDROID_NDK_PATH}
    DOC   "The ndk-depends command-line tool"
)
if(NOT NDK_DEPENDS)
    message(FATAL_ERROR "Can not find android command line tool: ndk-depends")
endif()
# for compatibility with taka-no-me toolchain
set(NDK_DEPENDS_PRG ${NDK_DEPENDS})

########################################
# Find ant
find_host_program(ANT_PRG
    NAMES ant ant.bat
    DOC   "The ant build tool"
)
