error_count=5
warning_count=2
zero_count=0

if [ "$error_count" -gt "$warning_count" ]; then
	echo "Errors are greater than warnings"
fi

if [ "$warning_count" -lt "$error_count" ]; then
	echo "Warnings are less than errors"
fi

if [ "$zero_count" -eq 0 ]; then
	echo "Zero count equals zero"
fi

if [ "$error_count" -ne "$warning_count" ]; then
	echo "Error count is not equal to warning count"
fi

if [ "$error_count" -ge 5 ]; then
	echo "Error count is greater than or equal to 5"
fi

if [ "$warning_count" -le 2 ]; then
	echo "Warning count is less than or equal to 2"
fi

 
