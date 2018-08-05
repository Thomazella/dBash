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
  # if previous command exited with 0, do stuff
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
  local predicate="$@" isNotTruthyTestOrInvalid='^-[[:alpha:]][ ][^ ]+|[^ ]+[ ]-[[:alpha:]][[:alpha:]][ ][^ ]+|[^ ]+[ ]=[ ][^ ]+|[^ ]+[ ]==[ ][^ ]+|[^ ]+[ ]!=[ ][^ ]+|[^ ]+[ ]<[ ][^ ]+|[^ ]+[ ]>[ ][^ ]+'
  if [[ "$predicate" =~ $isNotTruthyTestOrInvalid ]]; then
    [ $predicate ] 2>/dev/null && return 0
  fi
  return 1
}

#- - - - - - - - - - -

ternary() {
  [ $# -lt 5 ] && return 1
  # reject malformed arguments. This is good: foo ? a : b.
  [[ ! "$@" =~ [[:space:]]+[?][[:space:]]+[^:]+[[:space:]]+[:][[:space:]]+ ]] && return 1

  local condition pass fail passCommand failCommand
  # parse args into local var condition, pass and fail
  for arg in $@; do
    [ $arg == "?" -a ! "$question" ] && local question=true && continue
    [ $arg == ":" -a ! "$colon" ] && local colon=true && continue
    [ ! $question -a ! $colon ] && condition="$condition $arg" && continue
    [ $question -a ! $colon ] && pass="$pass $arg" && continue
    fail="$fail $arg"
  done

  # get the first word out
  [[ "$pass" =~ ^[[:space:]]*([^ ]+) ]] && passCommand=${BASH_REMATCH[1]}
  [[ "$fail" =~ ^[[:space:]]*([^ ]+) ]] && failCommand=${BASH_REMATCH[1]}
  # if it's not a command, assume it's a value and append printf
  if ! which $passCommand >/dev/null 2>&1; then pass="printf \"$pass\""; fi
  if ! which $failCommand >/dev/null 2>&1; then fail="printf \"$fail\""; fi
  # handle cases where condition = true|false
  if [[ "$condition" =~ [[:space:]]*true[[:space:]]* ]]; then eval $pass && return; fi
  if [[ "$condition" =~ [[:space:]]*false[[:space:]]* ]]; then eval $fail && return; fi
  # main logicf
  if dotest $condition; then
    eval $pass
  else
    eval $fail
  fi
}

#- - - - - - - - - - -

doif() {
  [ $# -lt 2 ] && return 1
  if dotest "$1"; then
    shift && eval "$@"
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
  local noStdout=1\>/dev/null noStderr=2\>/dev/null
  eval "$@" $noStdout $noStderr
}

#- - - - - - - - - - -

and() {
  [ "$#" == 0 ] && return 1
  for ((i = 1; i <= ${#}; i++)); do
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
  for ((i = 1; i <= ${#}; i++)); do
    eval "\$$i"
    [ "$?" == 0 ] && return 0
  done
  return 1
}

#--------------

alias conditional='ternary'
alias all='and'
alias any='or'
