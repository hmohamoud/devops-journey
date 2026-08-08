#!/bin/bash
source config/toolkit.conf
export CPU_WARNING_THRESHOLD=100
echo "$CPU_WARNING_THRESHOLD"


unset CPU_WARNING_THRESHOLD    
source config/toolkit.conf
echo "$CPU_WARNING_THRESHOLD"
