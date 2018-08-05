#!/usr/bin/env bats

[ -f main.bash ] && source main.bash
[ -f ../main.bash ] && source ../main.bash

@test "noop returns 0" {
  noop
}

@test "exitwith defaults to 0" {
  exitwith
  [ $? == 0 ]
}

@test "exitwith 22" {
  exitwith 22 || [ $? == 22 ]
}

@test "exitstatus" {
  exitwith 11 || exitstatus || [ $? == 11 ]
}

@test 'ifprevious exit 0' {
  true
  ifprevious noop
}

@test 'ifprevious exit non 0' {
  false || ifprevious noop || true
}

@test 'ifprevious returns \$?' {
  exitwith 123 || ifprevious noop || [ $? == 123 ]
}

@test "not with no args exits 1" {
  not || [ $? == 1 ]
}

@test "not <exit 0> exits 1" {
  not exitwith 0 || [ $? == 1 ]
}

@test "not <exit 1> exits 0" {
  not exitwith 1 || [ $? == 0 ]
}

@test "truthy with no args exits 1" {
  truthy || [ $? == 1 ]
}

@test "truthy 'foo'" {
  truthy 'foo' || [ $? != 1 ]
}

@test "truthy 'foo' exits length of foo" {
  truthy 'foo' || [ $? == 3 ]
}

@test "truthy ''" {
  truthy '' || [ $? == 1 ]
}
