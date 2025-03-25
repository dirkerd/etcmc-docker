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
#trap "cleanup_function" EXIT

port=5111
if [[ "$1" != "" ]]; then
  port=$1
fi

cleanup_function
