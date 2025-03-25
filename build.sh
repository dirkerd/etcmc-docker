#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [[ ! -d ${SCRIPT_DIR}/data ]]; then
  mkdir ${SCRIPT_DIR}/data
fi

if [[ ! -f ${SCRIPT_DIR}/data/ETCMC_Linux.zip ]]; then
  curl -Lik https://github.com/Nowalski/ETCMC_Software/releases/download/Setup%2FWindows/ETCMC_Linux.zip -o ${SCRIPT_DIR}/data/ETCMC_Linux.zip
fi

if [[ ! -d ${SCRIPT_DIR}/data/unzipped ]]; then
  unzip ${SCRIPT_DIR}/data/ETCMC_Linux.zip -d ${SCRIPT_DIR}/data/unzipped
fi

docker build -f Dockerfile.etcmc.simple . -t etcmc-simple
