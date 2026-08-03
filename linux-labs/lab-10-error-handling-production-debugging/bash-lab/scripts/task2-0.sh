#!/bin/bash
set -e 
grep "pattern" file.txt || true
echo "still running"
