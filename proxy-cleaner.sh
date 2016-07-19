#!/bin/bash
# Remove or set proxy informations, before commiting the files

# No argument will clean up the proxy information. (Replace it by "FCKNG_HTTP_PROXY")
# If argument 1:  YES : will replace "FCKNG_HTTP_PROXY" by the real proxy info
# Argument 2: can be a proxy "http://my.proxy.com:1234/", if not will use the environment variable $http_proxy


command -v ag >/dev/null 2>&1 || { echo >&2 "I require ag but it is not installed. Aborting. (Hint: \"dnf install the_silver_searcher\")"; exit 1; }


export SET_PROXY=${1:-"NO"}
export PROXY=${2:-"$http_proxy"}

if [ "$SET_PROXY" = "YES" ]; then
    if [ ${#PROXY} -lt 10  ]; then 
        echo "Error: PROXY too short to be true! \"$PROXY\""  
        exit 1
    fi
    for f in $(ag -l --ignore ${0##*/} "FCKNG_HTTP_PROXY") 
    do
        echo "Set: $f"
        sed -i "s=FCKNG_HTTP_PROXY=$PROXY=g" "$f"
    done
    echo "Proxy set: Do not forget to clean-up before commiting !! "
else
    for f in $(ag -l --ignore ${0##*/} "$PROXY") 
    do
        echo "Clean: $f"
        sed -i "s=$PROXY=FCKNG_HTTP_PROXY=g" "$f"
    done
fi 


#
# ${1:-"NO"} will take command line argument #1  if it exist and "NO" by default
# ${#PROXY} is the string length of the variable $PROXY
# ${0##*/} is the program name without the path
#
