#!/bin/bash

function cleanup_function ()
{
echo "Stopping geth node"
curl "http://127.0.0.1:${port}/stop_node" \
  -H 'Accept: */*' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  -H 'Cache-Control: no-cache' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: application/json' \
  -H "Origin: http://127.0.0.1:${port}" \
  -H 'Pragma: no-cache' \
  -H "Referer: http://127.0.0.1:${port}/" \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36' \
  -H 'sec-ch-ua: "Chromium";v="134", "Not:A-Brand";v="24", "Google Chrome";v="134"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Windows"' \
  --data-raw '{"port":"30303"}'
  
  sleep 5
  
  echo "Checking if docker container is still running"
  is_running=$(docker container ls --filter name=etcmc-$port | grep -ci etcmc-$port)
  if [[ "$is_running" == "1" ]]; then
    
    container_id=$(docker container ls --filter name=etcmc-$port | grep -i etcmc-$port | awk '{ print $1 }')
    echo "Stopping docker container ${container_id}"
    docker container stop ${container_id}
  fi
}

#trap "cleanup_function" SIGINT


SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

#DATA_DIR=$SCRIPT_DIR/data
#DATA_DIR=/c/etcmcdata

#echo $DATA_DIR

follow=0
port=5111
if [[ "$1" != "" ]]; then
  port=$1
fi

ETCMC_HOME=$SCRIPT_DIR/data/${port}-etcmc
DATA_DIR=$SCRIPT_DIR/data/${port}-gethdata

echo $ETCMC_HOME
echo $DATA_DIR

if [[ ! -f ${SCRIPT_DIR}/data/ETCMC_Linux.zip ]]; then
  curl -Lik https://github.com/Nowalski/ETCMC_Software/releases/download/Setup%2FWindows/ETCMC_Linux.zip -o ${SCRIPT_DIR}/data/ETCMC_Linux.zip
fi

if [[ ! -d ${ETCMC_HOME} ]]; then
  unzip ${SCRIPT_DIR}/data/ETCMC_Linux.zip -d ${ETCMC_HOME}
fi

if [[ -f ${SCRIPT_DIR}/config.toml && -f ${ETCMC_HOME}/config.toml ]]; then
  diff -uNp ${SCRIPT_DIR}/config.toml ${ETCMC_HOME}/config.toml 2>&1 > /dev/null
  if [[ "$?" != "0" ]]; then
    timestamp=$(date +%s)
    mv ${ETCMC_HOME}/config.toml ${ETCMC_HOME}/config.toml.${timestamp}
    cp $SCRIPT_DIR/config.toml ${ETCMC_HOME}
  fi
fi

echo '{"login_required": false}' > ${ETCMC_HOME}/login.json

is_running=$(docker container ls --filter name=etcmc-$port | grep -ci etcmc-$port)
if [[ "$is_running" == "0" ]]; then
  old_id=$(docker container ls -a --filter name=etcmc-$port | grep -i etcmc-$port | awk '{ print $1 }')
  if [[ "$old_id" != "" ]]; then
    #echo $old_id
    docker container rm ${old_id}
  fi
fi

MSYS_NO_PATHCONV=1 docker run -d --name etcmc-$port -v ${DATA_DIR}:/data:rw -v ${ETCMC_HOME}:/ETCMC:rw -p ${port}:5123 etcmc-simple

sleep 10

curl "http://127.0.0.1:${port}/start_node" \
  -H 'Accept: */*' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  -H 'Cache-Control: no-cache' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: application/json' \
  -H "Origin: http://127.0.0.1:${port}" \
  -H 'Pragma: no-cache' \
  -H "Referer: http://127.0.0.1:${port}/" \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36' \
  -H 'sec-ch-ua: "Chromium";v="134", "Not:A-Brand";v="24", "Google Chrome";v="134"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Windows"' \
  --data-raw '{"port":"30303"}'
#MSYS_NO_PATHCONV=1 docker exec -it etcmc-$port tail -f /ETCMC/app.log

if [[ "$follow" == "1" ]]; then
  #trap "cleanup_function" EXIT
  sleep 5
  tail -n 100 -f ${ETCMC_HOME}/app.log
fi

docker container list
