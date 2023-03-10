
# - Try to find Jack Audio Libraries
# libjack; libjackserver;
# Once done this will define
#  LIBJACK_FOUND - System has libjack.so
#  LIBJACK_INCLUDE_DIRS - The jack.h include directories
#  LIBJACK_LIBRARIES - The libraries needed to use jack

# Install jack on Ubuntu: apt-get install libjack-jackd2-dev
# Add user to audio group: usermod -a -G audio <yourUserName>

#------------------------------------------------------------------------
function(setupJackSupport)
    # JACK SDK Location
    if(SMTG_WIN)
        if("${SMTG_JACK_SDK_PATH}" STREQUAL "")
            # Check if the JACK SDK is next to the vst3sdk folder:
            set(JACK_SDK_PATH ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../../../external.jackaudio)
            if(NOT EXISTS "${JACK_SDK_PATH}/lib")
                # Check if the JACK SDK is in the vst3sdk folder:
                set(JACK_SDK_PATH ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../../external.jackaudio)
                if(NOT EXISTS "${JACK_SDK_PATH}/lib")
                    set(JACK_SDK_PATH "")
                endif()
            endif()
            if(NOT "${JACK_SDK_PATH}" STREQUAL "")
                get_filename_component(JACK_SDK_PATH "${JACK_SDK_PATH}" ABSOLUTE)
            endif()
            set(SMTG_JACK_SDK_PATH "${JACK_SDK_PATH}" CACHE PATH "Here you can define where to find the JACK SDK" FORCE)
        else()
            set(JACK_SDK_PATH "${SMTG_JACK_SDK_PATH}")
			if(NOT IS_ABSOLUTE ${JACK_SDK_PATH})
                get_filename_component(JACK_SDK_PATH "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../../${JACK_SDK_PATH}" ABSOLUTE)
            endif()
            if(NOT EXISTS "${JACK_SDK_PATH}/include/jack/jack.h")
                message(FATAL_ERROR "[SMTG] SMTG_JACK_SDK_PATH is set but does not point to an expected location!")
            else()
                set(SMTG_JACK_SDK_PATH "${JACK_SDK_PATH}" CACHE PATH "Here you can define where to find the JACK SDK" FORCE)
            endif()
        endif()
        if(EXISTS "${SMTG_JACK_SDK_PATH}")
            message(STATUS "[SMTG] SMTG_JACK_SDK_PATH is set to: " ${SMTG_JACK_SDK_PATH})
        else()
            message(STATUS "[SMTG] SMTG_JACK_SDK_PATH is not set. If you need it, please download the JACK SDK!")
        endif()
        if(CMAKE_SIZEOF_VOID_P EQUAL 8)
            set(EXTENSION 64) 
            set(LOCAL_JACK_LIB "${SMTG_JACK_SDK_PATH}/lib/win64")
            set(PROGRAM_FILE_JACK2_INCLUDE "C:/Program Files/JACK2/include")
            set(PROGRAM_FILE_JACK2_LIB "C:/Program Files/JACK2/lib")
        else()
            set(LOCAL_JACK_LIB "${SMTG_JACK_SDK_PATH}/lib/win32")
            set(PROGRAM_FILE_JACK2_INCLUDE "C:/Program Files (x86)/JACK2/include")
            set(PROGRAM_FILE_JACK2_LIB "C:/Program Files (x86)/JACK2/lib")
        endif()

        set(LOCAL_JACK_INCLUDE "${SMTG_JACK_SDK_PATH}/include")
        set(PROGRAM_FILE_JACK1_INCLUDE "C:/Program Files (x86)/Jack/includes")
        set(PROGRAM_FILE_JACK1_LIB "C:/Program Files (x86)/Jack/lib")
    endif(SMTG_WIN)

    find_path(LIBJACK_INCLUDE_DIR
        NAMES
            jack/jack.h
        PATHS
            /usr/include
            /usr/local/include
            /opt/local/include
            ${LOCAL_JACK_INCLUDE}
            ${PROGRAM_FILE_JACK2_INCLUDE}
            ${PROGRAM_FILE_JACK1_INCLUDE}
    )

    find_library(LIBJACK_libjack_LIBRARY
        NAMES
            libjack${EXTENSION} jack
        PATHS
            /usr/lib
            /usr/local/lib
            /opt/local/lib
            ${LOCAL_JACK_LIB}
            ${PROGRAM_FILE_JACK2_LIB}
            ${PROGRAM_FILE_JACK1_LIB}
    )

    find_library(LIBJACK_libjackserver_LIBRARY
        NAMES
            libjackserver${EXTENSION} jackserver
        PATHS
            /usr/lib
            /usr/local/lib
            /opt/local/lib
            ${LOCAL_JACK_LIB}
            ${PROGRAM_FILE_JACK2_LIB}
            ${PROGRAM_FILE_JACK1_LIB}
    )

    set(LIBJACK_LIBRARIES ${LIBJACK_libjack_LIBRARY})
    set(LIBJACK_LIBRARY ${LIBJACK_LIBRARIES})
    set(LIBJACK_INCLUDE_DIRS ${LIBJACK_INCLUDE_DIR})

    include(FindPackageHandleStandardArgs)
    # handle the QUIETLY and REQUIRED arguments and set LIBJACK_FOUND to TRUE
    # if all listed variables are TRUE
    find_package_handle_standard_args(LIBJACK DEFAULT_MSG
                                      LIBJACK_LIBRARY LIBJACK_INCLUDE_DIR)

    if(LIBJACK_FOUND)
        message(STATUS "[SMTG] LIBJACK_FOUND at: " ${LIBJACK_INCLUDE_DIR})
    elseif(SMTG_LINUX)
        message(STATUS "[SMTG] LIBJACK_FOUND is not set. If you need it, install it (for example with: apt-get install libjack-jackd2-dev) or check Jack Audio from http://www.jackaudio.org!")
    else()
        message(STATUS "[SMTG] LIBJACK_FOUND is not set. If you need it, please install Jack Audio from http://www.jackaudio.org!")
    endif(LIBJACK_FOUND)

endfunction(setupJackSupport)
