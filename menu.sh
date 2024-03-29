#!/usr/bin/env bash

abort() {
  printf "%s\n" "$@" >&2
  exit 1
}

export MENU_DIR="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

if [ -x "${MENU_DIR}/bin/startdb.sh" ]; then
    . ${MENU_DIR}/bin/startdb.sh
    ARCION_DOCKER_COMPOSE=docker_compose_db
fi

setDockerCompose() {
    docker compose --help >/dev/null 2>/dev/null
    if [[ "$?" == "0" ]]; then
        export ARCION_DOCKER_COMPOSE="docker compose"
    else
        docker-compose --help >/dev/null 2>/dev/null
        if [[ "$?" == "0" ]]; then
            export ARCION_DOCKER_COMPOSE="docker-compose"
        else
            abort "docker compose and docker-compose not found."
        fi
    fi
    echo "Found ${ARCION_DOCKER_COMPOSE}."
}

set_machine

#export NEWT_COLORS='
#  window=,blue
#  border=white,blue
#  textbox=white,blue
#  button=black,white'

docker ps --format '{{.Names}}' | tee /tmp/docker.ps | awk -F'-' '{print $1}' | sort -u
docker compose ls -q | tee /tmp/docker.compose.ls | awk '{print $1}' | sort -u

# find 
# %h = dirname
# %f = filename

SELECTED=$( whiptail --title "Select database to start" \
    --checklist \
    "List of databases" 0 0 0 \
    $( for d in $(find * -maxdepth 2 -not \( -path docker-dev -prune \) -name "docker-compose.yaml" -printf "%h\n"); do echo $d $d OFF; done ) \
 3>&1 1>&2 2>&3 )

for db in ${SELECTED[@]}; do
    db=$(echo ${db} | sed 's/"//g' ) # remove the quote surrounding the name
    echo $db
    #${ARCION_DOCKER_COMPOSE} up $db
    docker_compose_db up $db
done
