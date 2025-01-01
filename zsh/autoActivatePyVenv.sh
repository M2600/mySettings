#!/bin/bash

cd() {
	builtin cd "$@"

	function activate_venv() {
		#if [[ $(ls -a -U1 .venv/ |wc -l) < 1 ]]; then
		#	echo "No virtul env"
		#elif [[ $(ls -a -U1 .venv/ |wc -l) > 1 ]]; then
		#	echo "Found multiple virtual envs"
		#	echo "Please activate manually"
		#else
		#	source .venv/$(ls .venv/)/bin/activate
		#fi

		if [ -f .venv/bin/activate ]; then
			source .venv/bin/activate
		else
			echo "No virtual env"
		fi
	}

	if [ -z "$VIRTUAL_ENV" ]; then
		if [ -d .venv ]; then
			activate_venv
		fi
	elif [[ $(pwd) != $(dirname $(dirname "$VIRTUAL_ENV"))/* ]]; then
		deactivate

		if [ -d .venv ]; then
			activate_venv
		fi
	fi


}

