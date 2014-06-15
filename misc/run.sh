#!/bin/sh

cd "$(dirname $0)"
export LD_LIBRARY_PATH="$PWD" 
export GI_TYPELIB_PATH="$PWD" 
./rocket-launcher
