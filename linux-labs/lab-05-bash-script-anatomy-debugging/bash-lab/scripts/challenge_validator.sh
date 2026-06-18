#!/bin/bash

if [ -f bash-lab/input/app.log ]; then
	echo "Found file: bash-lab/input/app.log"
fi

if [ -f bash-lab/input/users.txt ]; then
	echo "FOUND file: bash-lab/input/users.txt"
fi

if [ -f bash-lab/input/config.env ]; then
	echo "FOUND file: bash-lab/input/config.env"
fi

if [ ! -f bash-lab/input/fake.log ]; then
	echo "MISSING file: bash-lab/input/fake.log"
fi

if [ -d  bash-lab/output ]; then
	echo "FOUND directory: bash-lab/output/"
fi

if [ -d bash-lab/errors ]; then
	echo "FOUND directory: bash-lab/errors"
fi
