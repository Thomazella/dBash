#!/usr/bin/env bats

[ -f main.bash ] && load ../main

#- - - - - noop - - - - -

@test "noop returns 0" {
  noop
}

#- - - - - exitwith - - - - -

@test "exitwith defaults to 0" {
  run exitwith
  [ $status == 0 ]
}


@test "exitwith 22" {
  run exitwith 22
  [ $status == 22 ]
}

@test "exitstatus" {
  run exitwith 11 || exitstatus
  [ $status == 11 ]
}

#- - - - - ifprevious - - - - -

@test 'ifprevious exit 0' {
  true
  ifprevious noop
}

@test 'ifprevious exit non 0' {
  false || ifprevious noop || true
}

@test 'ifprevious returns exit status' {
  run exitwith 123 || ifprevious noop
  [ $status == 123 ]
}

#- - - - - not - - - - -

@test "not with no args exit 1" {
  run not
  [ $status == 1 ]
}

@test "not <exit 0> exit 1" {
  run not exitwith 0
  [ $status == 1 ]
}

@test "not <exit 1> exit 0" {
  run not exitwith 1
  [ $status == 0 ]
}

#- - - - - truthy - - - - -

@test "truthy with no args exit 1" {
  run truthy
  [ $status == 1 ]
}

@test "truthy 'foo' exists non zero" {
  run truthy 'foo'
  [ $status != 1 ]
}

@test "truthy 'foo' exit length of foo" {
  run truthy 'foo'
  [ $status == 3 ]
}

@test "truthy '' exit 1" {
  run truthy ''
  [ $status == 1 ]
}

#- - - - - ok - - - - -

@test "ok with no args exit 1" {
  run ok
  [ $status == 1 ]
}

@test "ok 1 == 1" {
  ok 1 == 1
}

@test "ok 1 == 12" {
  run ok 1 == 12
  [ $status == 1 ]
}

@test "ok \"1 == 12\"" {
  run ok "1 == 12"
  [ $status == 1 ]
}

@test "ok \"12 -gt 2\"" {
  ok "12 -gt 2"
}

@test "ok \$foo exit 1" {
  local foo=123
  run ok $foo
  [ $status == 1 ]
}

@test "ok -n \$foo exit 0" {
  local foo=123
  ok -n $foo
}

@test "ok 341 exit 1" {
  run ok 341
  [ $status == 1 ]
}

@test "ok -ffoobar exit 1" {
  run ok -ffoobar
  [ $status == 1 ]
}

@test "ok -f exit 1" {
  run ok -f
  [ $status == 1 ]
}

@test "ok with if" {
  if ok -n "somelength"; then true; fi
}

@test "ok with if else" {
  if ok 1 -gt 20; then false; else true; fi
}

#- - - - - ternary - - - - -

@test "ternary exit 1 when not given 5 args" {
  run ternary 1
  [ $status == 1 ]
  run ternary 1 2
  [ $status == 1 ]
  run ternary 1 2 3 4
  [ $status == 1 ]
}

@test "ternary 1 == 1 ? y : n" {
  run ternary 1 == 1 ? y : n
  [ "$output" == "y" ]
}

@test "ternary 1 == 10 ? y : n" {
  run ternary 1 == 10 ? y : n
  [ "$output" == "n" ]
}

@test "ternary true ? y : n" {
  run ternary true ? y : n
  [ "$output" == "y" ]
}

@test "ternary false ? y : n" {
  run ternary false ? y : n
  [ "$output" == "n" ]
}

@test "ternary \$var == \$var ? y : n" {
  local a=1
  local b=2333
  run ternary $a == $b ? y : n
  [ "$output" == "n" ]
}

@test "ternary one liner in var declaration" {
  local b=$(ternary true ? 99 : 00)
  [ $b == 99 ]
}

#- - - - - ifdo - - - - -

@test "ifdo 1 == 1 : echo y" {
  run ifdo 1 == 1 : echo y
  [ "$output" == "y" ]
}

@test "ifdo true : echo y" {
  run ifdo true : echo y
  [ "$output" == "y" ]
}

@test "ifdo 1 == 10 : echo n" {
  run ifdo 1 == 10 : echo "exits with 1"
  [ $status == 1 ]
}

@test "ifdo false : echo n" {
  run ifdo false : echo "exits with 1"
  [ $status == 1 ]
}

@test "ifdo with var" {
  local foo=33
  run ifdo $foo == 33 : echo "y"
  [ "$output" == "y" ]
}

#- - - - - status - - - - -

@test "status exitwith 11" {
  run status exitwith 11
  [ "$output" == "11" ]
}

@test "status true" {
  run status true
  [ "$output" == "0" ]
}

@test "status after exitwith 11" {
  exitwith 11 || status
}

@test "status after true" {
true && status
}

@test "mute echo nope" {
  run mute echo nope
  [ ! "$output" ]
}

@test "mute invalidcommand" {
  run mute invalidcommand
  [ ! "$output" ]
}

@test "mute 1 invalidcommand" {
  run mute 1 invalidcommand
  [[ "$output" =~ 'command not found' ]]
}

@test "mute 2 echo nope" {
  run mute 2 echo nope
  [ "$output" == "nope" ]
}

@test "mute exit 0" {
  mute echo dd
  run mute invalidcommand
  [ "$status" == 0 ]
}
