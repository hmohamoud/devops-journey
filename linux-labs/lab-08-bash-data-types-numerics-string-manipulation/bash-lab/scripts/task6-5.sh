
#!/bin/bash

server=()

while IFS=, read -r name ip status port service; do
        server+=("$name")
done < bash-lab/data/servers.txt
for element in "${server[@]}";do
        echo "$element"
done
echo "${#server[@]}"

