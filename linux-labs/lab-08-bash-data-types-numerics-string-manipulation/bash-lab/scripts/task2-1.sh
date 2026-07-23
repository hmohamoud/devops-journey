#!/bin/bash

state="Stopped"
switch_states(){

	local state="running"
}

switch_states
echo "$state"

