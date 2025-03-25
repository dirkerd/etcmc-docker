#!/bin/bash

ls -la /data

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

ETCMC_HOME=/ETCMC

function tail_log()
{
  tail -f $ETCMC_HOME/app.log
}

function start_node()
{
total_sleeps=0
  # Wait for app.log to appear
  while [[ ! -f ${ETCMC_HOME}/app.log ]]; do
    sleep 1
  done

  is_running=$(grep -ic "Running.*5123" ${ETCMC_HOME}/app.log)
  while [[ "$is_running" == "0" && "$total_sleeps" != "15" ]]; do
    echo "Sleep before starting geth..."
    sleep 1
    is_running=$(grep -ic "Running.*5123" ${ETCMC_HOME}/app.log)
  done
  
  echo 'Sleeping is over'
  curl -X POST -s "http://127.0.0.1:5123/start_node" \
  -H 'Accept: */*' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  -H 'Cache-Control: no-cache' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: application/json' \
  -H "Origin: http://127.0.0.1:5123" \
  -H 'Pragma: no-cache' \
  -H "Referer: http://127.0.0.1:5123/" \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36' \
  -H 'sec-ch-ua: "Chromium";v="134", "Not:A-Brand";v="24", "Google Chrome";v="134"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Windows"' \
  --data-raw '{"port":"30303"}'
  sleep 1
  # Tail the log after we've started
  tail_log &
}

function cleanup_function ()
{
echo "Stopping geth node"
curl -X POST -s "http://127.0.0.1:5123/stop_node" \
  -H 'Accept: */*' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  -H 'Cache-Control: no-cache' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: application/json' \
  -H "Origin: http://127.0.0.1:5123" \
  -H 'Pragma: no-cache' \
  -H "Referer: http://127.0.0.1:5123/" \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36' \
  -H 'sec-ch-ua: "Chromium";v="134", "Not:A-Brand";v="24", "Google Chrome";v="134"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Windows"'
  
  sleep 1
  echo "Exiting"
  
  
  #echo "Checking if docker container is still running"
  #is_running=$(docker container ls --filter name=etcmc-$port | grep -ci etcmc-$port)
  #if [[ "$is_running" == "1" ]]; then
  #  container_id=$(docker container ls --filter name=etcmc-$port | grep -i etcmc-$port | awk '{ print $1 }')
  #  echo "Stopping docker container ${container_id}"
  #  docker container stop ${container_id}
  #fi
}

trap "cleanup_function" SIGINT
trap "cleanup_function" EXIT

if [[ -f ${ETCMC_HOME}/app.log ]]; then
  rm -f ${ETCMC_HOME}/app.log
fi

# Run this in the background
start_node &

pushd ${ETCMC_HOME}
  pwd
  ls -la
  chmod +x Linux.py ETCMC_GETH.py geth
  python3 ./Linux.py --port 5123 start
popd