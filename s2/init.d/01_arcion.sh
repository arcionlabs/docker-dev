#!/usr/bin/env bash

singlestore -f -u root --password=${ROOT_PASSWORD} <<EOF
    CREATE USER '${REPLICANT_USER}'@'%' IDENTIFIED BY '${REPLICANT_PW}';
    CREATE USER '${REPLICANT_USER}'@'127.0.0.1' IDENTIFIED BY '${REPLICANT_PW}';
    CREATE DATABASE ${REPLICANT_DB};
    GRANT ALL ON ${REPLICANT_DB}.* to '${REPLICANT_USER}'@'%';
    GRANT ALL ON ${REPLICANT_DB}.* to '${REPLICANT_USER}'@'127.0.0.1';
EOF

singlestore -u ${REPLICANT_USER} --password=${REPLICANT_PW} <<EOF
    USE ${REPLICANT_DB};
    CREATE TABLE IF NOT EXISTS REPLICATE_IO_CDC_HEARTBEAT(
        TIMESTAMP BIGINT NOT NULL,
        PRIMARY KEY(TIMESTAMP)
    );
EOF