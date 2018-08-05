#!/usr/bin/env bats

[ -f main.bash ] && load ../main

@test "noop returns 0" {
  noop
}

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

@test "not with no args exits 1" {
  run not
  [ $status == 1 ]
}

@test "not <exit 0> exits 1" {
  run not exitwith 0
  [ $status == 1 ]
}

@test "not <exit 1> exits 0" {
  run not exitwith 1
  [ $status == 0 ]
}

@test "truthy with no args exits 1" {
  run truthy
  [ $status == 1 ]
}

@test "truthy 'foo' exists non zero" {
  run truthy 'foo'
  [ $status != 1 ]
}

@test "truthy 'foo' exits length of foo" {
  run truthy 'foo'
  [ $status == 3 ]
}

@test "truthy '' exits 1" {
  run truthy ''
  [ $status == 1 ]
}

@test "dotest with no args exits 1" {
  run dotest
  [ $status == 1 ]
}

@test "dotest 1 == 1" {
  dotest 1 == 1
}

@test "dotest 1 == 12" {
  run dotest 1 == 12
  [ $status == 1 ]
}

@test "dotest \"1 == 12\"" {
  run dotest "1 == 12"
  [ $status == 1 ]
}

@test "dotest \"12 -gt 2\"" {
  dotest "12 -gt 2"
}

@test "dotest \$foo exits 1" {
  local foo=123
  run dotest $foo
  [ $status == 1 ]
}

@test "dotest -n \$foo exits 0" {
  local foo=123
  dotest -n $foo
}

@test "dotest 341 exits 1" {
  run dotest 341
  [ $status == 1 ]
}

@test "dotest -ffoobar exits 1" {
  run dotest -ffoobar
  [ $status == 1 ]
}

@test "dotest -f exits 1" {
  run dotest -f
  [ $status == 1 ]
}

@test "dotest with if" {
  if dotest -n "somelength"; then true; fi
}

@test "dotest with if else" {
  if dotest 1 -gt 20; then false; else true; fi
}

@test "ternary exits 1 when not given 5 args" {
  run ternary 1
  [ $status == 1 ]
  run ternary 1 2
  [ $status == 1 ]
  run ternary 1 2 3 4
  [ $status == 1 ]
}

@test "ternary 1 == 1 ? y : n" {
  run ternary 1 == 1 ? y : n
  [ $output == "y" ]
}

@test "ternary 1 == 10 ? y : n" {
  run ternary 1 == 10 ? y : n
  [ $output == "n" ]
}

@test "ternary true ? y : n" {
  run ternary true ? y : n
  [ $output == "y" ]
}

@test "ternaryt false ? y : n" {
  run ternary false ? y : n
  [ $output == "n" ]
}

@test "ternary \$var == \$var ? y : n" {
  local a=1
  local b=2
  run ternary $a == $b ? y : n
  [ $output == "n" ]
}

@test "ternary in var declaration" {
  local b=$(ternary true ? 99 : 00)
  [ $b == 99 ]
}

# rewrite ternary to use ? : as argument separators