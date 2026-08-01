#!/bin/bash

for outer in a b c; do
	for inner in 1 2 3; do
    		if [ "$inner" -eq 2 ]; then
			break 2 
		fi
    		echo "$outer-$inner"
  	done
done
