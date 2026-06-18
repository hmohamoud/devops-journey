#!/bin/bash
if [ -f bash-lab/input/app.log ]; then
	echo "FOUND file: bash-lab/input/app.log"
else
	echo "MISSING file: bash-lab/input/app.log"
fi

if [ -f bash-lab/input/users.txt ]; then
	echo "FOUND file: bash-lab/input/users.txt"
else
	echo "MISSING file: bash-lab/input/users.txt"
fi 

if [ -f bash-lab/input/config.env ]; then
	echo "FOUND file: bash-lab/input/config.env"
else
	echo "MISSING file: bash-lab/input/config.env"
fi

if [ ! -f bash-lab/input/missing.log ]; then
	echo "MISSING file: bash-lab/input/missing.log"
else
	echo "FOUND file: bash-lab/input/missing.log"
fi

if [ -d bash-lab/output ]; then
	echo "FOUND directory: bash-lab/output"
else
	echo "MISSED directory: bash-lab/output"
fi

if [ -d bash-lab/errors ]; then
	echo "FOUND directory: bash-lab/errors"
else
	echo "MISSED directory: bash-lab/errors"
fi 
