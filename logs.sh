#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

port=5111
if [[ "$1" != "" ]]; then
  port=$1
fi

ETCMC_HOME=$SCRIPT_DIR/data/${port}-etcmc

tail -n 100 -f ${ETCMC_HOME}/app.log
