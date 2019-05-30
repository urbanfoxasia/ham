FOUND_SETUP_SCRIPT=no
if [ "$FOUND_SETUP_SCRIPT" == "no" ]; then
    export DIR="${HAM_HOME}/specs/toolsets/$1"
    export SETUP_SCRIPT="$DIR/setup-toolset.sh"
    if [ -f "$SETUP_SCRIPT" ]; then
        FOUND_SETUP_SCRIPT="From GLOBAL."
    fi
fi

if [ "$FOUND_SETUP_SCRIPT" == "no" ]; then
    echo "E/Can't find the toolset '$1'"
    return 1
fi

ALREADY_IMPORTED=`ni-hget HAM_IMPORTS_TOOLSETS $1`
if [[ $ALREADY_IMPORTED = "1" ]]; then
    echo "I/Already imported '$1'."
else
    export PATH=$PATH
    . "$SETUP_SCRIPT"
    if [ $? != 0 ]; then
        echo "E/Toolset '$1' import failed !"
        return 1
    else
        if [[ -z $HAM_IMPORTED_TOOLSETS ]]; then
            export HAM_IMPORTED_TOOLSETS="$1"
        else
            export HAM_IMPORTED_TOOLSETS="$HAM_IMPORTED_TOOLSETS $1"
        fi
        ni-hput HAM_IMPORTS_TOOLSETS $1 1
        echo -e "Imported toolset $1 ${FOUND_SETUP_SCRIPT}"
    fi
fi
