#!/usr/bin/env bats

[ -f main.bash ] && source main.bash
[ -f ../main.bash ] && source ../main.bash

@test "noop returns 0" {
  noop
}

@test "returnit defaults to 0" {
  returnit
  [ $? == 0 ]
}

@test "returnit 22" {
  returnit 22 || [ $? == 22 ]
}

@test "exitstatus" {
  returnit 11 || exitstatus || [ $? == 11 ]
}

@test 'ifprevious exit 0' {
  true
  ifprevious noop
}

@test 'ifprevious exit non 0' {
  false || ifprevious noop || true
}

@test 'ifprevious returns \$?' {
  returnit 123 || ifprevious noop || [ $? == 123 ]
}


@test "ido" {
  returnit 22 || [ $? == 22 ]
}
