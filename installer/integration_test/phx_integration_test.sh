#!/bin/bash
#set -x

LOG="../../integration_test/phx_integration_test.log"

function enter_cave {
    echo -e "\nDATE: $(date) OPTIONS: $@\n" >> $LOG
    mix phauxth.new $@
}

function edit_mix {
    sed -i 's/{:postgrex, ">= 0.0.0"},/{:postgrex, ">= 0.0.0"},\n     {:phauxth, git: "https:\/\/github.com\/riverrun\/phauxth.git"},\n     {:bcrypt_elixir, "~> 1.0"},\n     {:bamboo, "~> 0.8"},/g' mix.exs
    mix deps.get
}

function run_tests {
    mix test >> $LOG
    MIX_ENV=test mix ecto.drop
}

function clean {
    cd ..
    rm -rf alibaba
}

function phauxth_project {
    cd alibaba || exit $?
    enter_cave $@
    edit_mix
    run_tests
    clean
}

cd $(dirname "$0")/../tmp
echo y | mix phx.new alibaba
phauxth_project
echo y | mix phx.new alibaba
phauxth_project --confirm
echo y | mix phx.new alibaba --no-html --no-brunch
phauxth_project --api
echo y | mix phx.new alibaba --no-html --no-brunch
phauxth_project --api --confirm
echo "------------------------------------------------------------"
grep "test.*failure" ../integration_test/phx_integration_test.log
grep "error" ../integration_test/phx_integration_test.log
