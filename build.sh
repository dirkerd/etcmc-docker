#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

command_exists() {
    command -v "$1" &> /dev/null
}

install_prereqs() {
    echo "Installing prerequisists..."
    SUDO=''
    if (( $EUID != 0 )); then
        SUDO='sudo'
        echo "Running as non-root user. Using sudo for installation."
    fi
    
    # Check the package manager and install Python 3 and pip
    if command_exists apt; then
        $SUDO apt update -y
        $SUDO apt install -y curl unzip docker.io
    elif command_exists yum; then
        $SUDO yum install -y curl unzip docker.io
    elif command_exists dnf; then
        $SUDO dnf install -y curl unzip docker.io
    else
        echo "Unsupported package manager. Please install Python 3 manually."
        exit 1
    fi
    sudo usermod -aG docker $USER

    echo "Curl, unzip and Docker have been installed."
}

# With this syntax, we can not (and should not) use single or double brackets
if ! command_exists docker; then
  install_prereqs
fi

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

docker image list