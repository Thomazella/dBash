#!/usr/bin/env bash
noop() {
  return 0
}

#- - - - - - - - - - -

exitwith() {
  [ $# == 0 ] && return 0
  return $1
}

#- - - - - - - - - - -

exitstatus() {
  return $?
}

#- - - - - - - - - - -

ifprevious() {
  # do commands if previous command exited with a 0
  local previous=$?
  [ $previous != 0 ] && return $previous
  eval "$@"
}

#- - - - - - - - - - -

not() {
  [ $# == 0 ] && return 1
  eval "$@" && return 1
  return 0
}

#- - - - - - - - - - -

truthy() {
  [ $# == 0 ] && return 1
  [ "$1" ] && return ${#1}
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

ternary() {
  [ $# != 3 ] && return 1
  local condition="$1"
  local pass="$2"
  local fail="$3"
  local silent=">/dev/null 2>&1"
  if ! which $pass $silent; then pass="printf $pass"; fi
  if ! which $fail $silent; then fail="printf $fail"; fi
  if [ "$condition" == true ]; then eval $pass && return; fi
  if [ "$condition" == false ]; then eval $fail && return; fi
  if dotest $condition
  then eval $pass
  else eval $fail
  fi
}

#- - - - - - - - - - -

doif() {
  [ $# -lt 2 ] && return 1
  if dotest "$1"
  then shift && eval "$@"
  fi
}

#- - - - - - - - - - -

status() {
  eval "$@" 1>/dev/null 2>/dev/null
  echo $?
}

#- - - - - - - - - - -

trim() {
  # todo: proper trim using a for reading each char
  true
}

#- - - - - - - - - - -

mute() {
  [ "$#" == 0 ] && return 1
  local noStdout=1\>/dev/null
  local noStderr=2\>/dev/null
  eval "$@" $noStdout $noStderr
}

#- - - - - - - - - - -

and() {
  [ "$#" == 0 ] && return 1
  for((i=1; i <= ${#}; i++)); do
    eval "\$$i"
    [ "$?" != 0 ] && return 1
  done
  return 0
}

#- - - - - - - - - - -

iscommand() {
  [ "$#" == 0 ] && return 1
  which "$1" >/dev/null 2>&1 || return 1
}

#- - - - - - - - - - -

or() {
  [ "$#" == 0 ] && return 1
  for((i=1; i <= ${#}; i++)); do
    eval "\$$i"
    [ "$?" == 0 ] && return 0
  done
  return 1
}

#--------------

alias doifelse='ternary'
alias all='and'
alias any='or'
