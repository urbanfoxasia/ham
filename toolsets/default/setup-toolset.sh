#!/bin/bash

. ham-toolset-import.sh xslt_tools
if [ $? != 0 ]; then return 1; fi

# path setup
case $HAM_OS in
    NT*)
        . ham-toolset-import.sh msvc_15_x86
        # echo "I/Default Toolset: Using VC10 legacy package"
        # . ham-toolset-import.sh msvc_10_x86
        ;;
    OSX*)
        . ham-toolset-import.sh clang_33
        export OSPLAT=X86
        export BUILD_BIN_LOA=osx-x86
        ;;
    LINUX)
        . ham-toolset-import.sh gcc_470
        ;;
    *)
        echo "E/Toolset: Unsupported host OS"
        return 1
        ;;
esac
