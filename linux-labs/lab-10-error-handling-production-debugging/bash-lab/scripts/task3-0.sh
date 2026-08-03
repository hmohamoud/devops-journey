#!/bin/bash
set -o pipefail
ls /nonexistent | wc -l
echo "$?"
