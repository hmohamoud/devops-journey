#!/bin/bash

if [ -f "$1" ]; then
        echo "file exists"
else
        echo "file Doesnt exist"
fi

if [ -e "$1" ]; then
        echo "It exists"
else
        echo "It Doesnt exist"
fi

if [ -d "$1" ]; then
        echo "directory It exists"
else
        echo "directory Doesnt exist"
fi

if [ -x "$1" ]; then
	echo "Yes its executable"
else
	echo "It cannot be executed"
fi

if [ -w "$1" ]; then
	echo "It can be edited/changed/created etc" 
else
	echo "It cannot be edited/changed/created etc"
fi

if [ -r "$1" ]; then
        echo "It can be viewed/ls "
else
        echo "It cannot be viewed/ls"
fi
