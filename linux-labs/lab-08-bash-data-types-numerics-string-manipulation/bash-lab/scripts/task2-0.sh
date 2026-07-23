#!/bin/bash

state="Stopped"
switch_states(){

	state="running"
}

switch_states
echo "$state"
