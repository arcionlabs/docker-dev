#!/usr/bin/env bash

set -u

abort() {
  printf "%s\n" "$@" >&2
  exit 1
}

if [[ ! -z "${ARCION_LICENSE}" ]]; then  
    echo "ARCION_LICENSE found."  
elif [[ -f replicant.lic ]]; then
    echo "ARCION_LICENSE environmental varibale not found."
    echo "replicant.lic found"
    export ARCION_LICENSE="$(cat replicant.lic | base64)"
    echo "Add to your .bashrc or .zprofile:"
    echo "export ARCION_LICENSE='$ARCION_LICENSE'"
else
    abort "ARCION_LICENSE environmental variable not found AND replicant.lic not found"
fi

if [[ $(type -P "git") ]]; then 
    echo "git found." 
else     
    abort "git is NOT in PATH"
fi

if [[ $(type -P "docker") ]]; then 
    echo "docker found." 
else     
    abort "docker is NOT in PATH"
fi

docker network inspect arcnet >/dev/null 2>/dev/null
if [[ "$?" = "0" ]]; then
    echo "docker network arcnet found."
elif [[ ${i} = "1" ]]; then
    echo "docker network create arcnet"
    docker network create arcnet >/tmp/install.$$ 2>&1
    if [[ "$?" != 0 ]]; then 
        cat /tmp/install.$$
        abort "docker network create arcnet failed."
    fi
fi

oravols=(oraxe11g oraxe2130 oraee1930)
for v in ${oravols[*]}; do
    docker volume inspect $v >/dev/null 2>/dev/null
    if [[ "$?" = "0" ]]; then
        echo "docker volume $v found."
    else
        echo "docker volume create $v"
        docker volume create $v >/tmp/install.$$ 2>&1
        if [[ "$?" != 0 ]]; then 
            cat /tmp/install.$$
            abort "docker network create arcnet failed."
        fi
    fi    
done

if [[ -d "docker-dev" ]]; then
    echo "docker-dev found."
else
    echo "git clone https://github.com/arcionlabs/docker-dev"
    git clone https://github.com/arcionlabs/docker-dev >/tmp/install.$$ 2>&1
    if [[ "$?" != 0 ]]; then 
        cat /tmp/install.$$
        abort "docker network create arcnet failed."
    fi
fi

clear
cat <<EOF

The following starter demo can be started for you.

    # start Arcion demo kit
    docker compose -f docker-dev/arcion-demo/docker-compose.yaml up -d

    # start MySQL, PostgresSQL
    docker compose -f docker-dev/mysql/docker-compose.yaml up -d
    docker compose -f docker-dev/postgresql/docker-compose.yaml up -d

    # start Arcion demo kit CLI
    docker compose -f docker-dev/arcion-demo/docker-compose.yaml exec workloads tmux attach

When the demo starts, you will enter a tmux session.  
To detach (exit) from from the demo kit, use the following tmux command:  

    1. press <control> b
    2. type ":detach" wihout the quote

Once in the demo kit, type the following to migration from mysql to postgresql
    arcdemo.sh full mysql postgresql

EOF

read -p "Would you like to try the starter demo now (y/n)? " answer
case ${answer:0:1} in
    n|N )
        abort
    ;;
    * )
    ;;
esac

cat <<EOF
When the demo starts, you will enter a tmux session.  To detach from tmux, 

    1. press <control> b
    2. type ":detach" wihout the quote

EOF

docker compose -f docker-dev/arcion-demo/docker-compose.yaml up -d

# start MySQL, PostgresSQL, Open Source Kafka and Minio
docker compose -f docker-dev/mysql/docker-compose.yaml up -d
docker compose -f docker-dev/postgresql/docker-compose.yaml up -d
docker compose -f docker-dev/kafka/docker-compose.yaml up -d
docker compose -f docker-dev/minio/docker-compose.yaml up -d

# start Arcion demo kit CLI
ttyd_started=$( docker compose -f docker-dev/arcion-demo/docker-compose.yaml logs workloads | grep ttyd )
while [ -z "${ttyd_started}" ]; do
    sleep 1
    echo 'waiting on docker compose -f docker-dev/arcion-demo/docker-compose.yaml logs workloads | grep ttyd'
    ttyd_started=$( docker compose -f docker-dev/arcion-demo/docker-compose.yaml logs workloads | grep ttyd )
done
docker compose -f docker-dev/arcion-demo/docker-compose.yaml exec workloads tmux attach

