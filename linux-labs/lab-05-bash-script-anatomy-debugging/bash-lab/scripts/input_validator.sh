if [ -f bash-lab/input/app.log ] && [ -f bash-lab/input/users.txt ] && [ -f bash-lab/input/config.env ]; then
	echo "All required input files found"
	exit 0
else
	if [ ! -f bash-lab/input/app.log ]; then 
		echo "Missing file: bash-lab/input/app.log"
	fi
	
	if [ ! -f bash-lab/input/users.txt ]; then
		echo "Missing file: bash-lab/input/users.txt"
	fi

	if [ ! -f bash-lab/input/config.env ]; then
		echo "Missing file: bash-lab/input/config.env"
	fi
	exit 1
fi
