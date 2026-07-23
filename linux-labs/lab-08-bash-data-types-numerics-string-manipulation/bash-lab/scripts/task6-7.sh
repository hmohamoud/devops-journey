
#!/bin/bash

server=()

while IFS=, read -r name ip status port service; do
        server+=("$name")
done < bash-lab/data/servers.txt

unset 'server[5]'

for element in "${server[@]}";do 
	echo "$element"
done

