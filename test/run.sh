#!/bin/bash

bundle exec bacon -rsimplecov -I lib test/spec_*.rb
BACON=$?

bundle exec ruby -I lib test/compatibility-test.rb
COMPAT=$?

if [ ${BACON} -ne 0 ] || [ ${COMPAT} -ne 0 ]
then
    exit 1
fi
