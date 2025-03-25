#!/bin/bash

ls -la /data

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

ETCMC_HOME=/ETCMC

pushd ${ETCMC_HOME}
  pwd
  ls -la
  chmod +x Linux.py ETCMC_GETH.py geth
  python3 ./Linux.py --port 5123 start
popd