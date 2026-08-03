#!/bin/bash
set -euo pipefail

tempfile=$(mktemp)
trap 'rm -f "$tempfile"' EXIT
ls fakefolder
echo "$temk"
