low_number=3
high_number=10
same_number=10

if [ "$high_number" -gt "$low_number" ]; then
	echo "10 is greater than 3"
else
	echo "10 is not greater than 3"
fi

if [ "$low_number" -lt "$high_number" ]; then
	echo "3 is less than 10"
else
	echo "3 is not less than 10"
fi

if [ "$high_number" -eq "$same_number" ]; then
	echo "10 is equal to 10"
else 
	echo "10 is not not equal to 10"
fi


if [ "$high_number" -ge "$same_number" ]; then
	echo "10 is greater than or equal to 10"
else
	echo "10 is not greater than or equal to 10"

fi

if [ "$low_number" -ne "$high_number" ]; then
	echo "3 is not equal to 10"
else
	echo "3 is equal to 10"
fi

if [ "$low_number" -le "$high_number" ]; then
	echo "3 is less than or equal to 10"
else
	echo " 3 is not less than or equal to 10"
fi


