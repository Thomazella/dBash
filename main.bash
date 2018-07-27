#!/usr/bin/env bash
ifCommandSuceeded() {
	[ $? != 0 ] && return 1
	eval $@
}

#- - - - - - - - - - -

previousStatus() {
	return $?
}

#- - - - - - - - - - -

doifprevious() {
	if previousStatus;
		then eval "$@" && return 0
	fi
	return 1
}

#- - - - - - - - - - -

not() {
	[ $# == 0 ] && return 1
	eval $@ && return 1
	return 0
}

#- - - - - - - - - - -

truthy() {
	[ $# == 0 ] && return 1
	if [ "${#1}" != 0 ]
		then return 0
	fi
	return 1
}

#- - - - - - - - - - -

dotest() {
	[ $# == 0 ] && return 1
	local predicate="$@"
	local isNotTruthyTestOrInvalid='^-[[:alpha:]][ ][^ ]+|[^ ]+[ ]-[[:alpha:]][[:alpha:]][ ][^ ]+|[^ ]+[ ]=[ ][^ ]+|[^ ]+[ ]==[ ][^ ]+|[^ ]+[ ]!=[ ][^ ]+|[^ ]+[ ]<[ ][^ ]+|[^ ]+[ ]>[ ][^ ]+'
	if [[ "$predicate" =~ $isNotTruthyTestOrInvalid ]]
		then [ $predicate ] 2>/dev/null && return 0
	fi
	return 1
}

#- - - - - - - - - - -

istrue() {
	[ $# == 0 ] && return 1
	if truthy $@ && dotest $@
		then return 0
	fi
	return 1
}

#- - - - - - - - - - -

ternary() {
	[ $# != 3 ] && return 1
	local test="$1"
	local pass="$2"
	shift && shift && local fail="$@"
	if istrue $test
		then eval $pass
		else eval $fail
	fi
}

#- - - - - - - - - - -

doif() {
	[ $# -lt 2 ] && return 1
	if istrue "$1"
		then shift && eval "$@"
	fi
}

#- - - - - - - - - - -

status() {
	# [ $# == 0 ] && return 1
	mute eval "$@"
	echo $?
}

#- - - - - - - - - - -

trim() {
	# todo: proper trim using a for reading each char
	true
}

#- - - - - - - - - - -

mute() {
	dotest "$# == 0" && return 1
	local noStdout=1\>/dev/null
	local noStderr=2\>/dev/null
	eval "$@" $noStdout $noStderr
}

#- - - - - - - - - - -

and() {
	dotest "$# == 0" && return 1
	for((i=1; i <= ${#}; i++)); do
		eval "\$$i"
		previousStatus || return 1
	done
	return 0
}

#- - - - - - - - - - -

or() {
	dotest "$# == 0" && return 1
	for((i=1; i <= ${#}; i++)); do
		eval "\$$i"
		previousStatus && return 0
	done
	return 1
}

#--------------

alias doifelse='ternary'
