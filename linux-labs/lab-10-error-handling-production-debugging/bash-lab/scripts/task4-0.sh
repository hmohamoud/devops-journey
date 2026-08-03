#!/bin/bash

mkdir bash-lab/output && echo "created"
mkdir bash-lab/output || echo "already exists"
cd bash-lab/data && ls servers.txt && echo "found it"
