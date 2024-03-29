#!/usr/bin/env bash

ycsb_create_mysql() {
cat <<'EOF'
CREATE TABLE IF NOT EXISTS YCSBSPARSE (
    YCSB_KEY INT PRIMARY KEY,
    FIELD0 TEXT, FIELD1 TEXT,
    FIELD2 TEXT, FIELD3 TEXT,
    FIELD4 TEXT, FIELD5 TEXT,
    FIELD6 TEXT, FIELD7 TEXT,
    FIELD8 TEXT, FIELD9 TEXT,
    TS TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    INDEX (TS)
);
EOF
}

ycsb_load() {
    local ROLE=${1}
    local DB_ARC_USER=${2} 
    local DB_ARC_PW=${3} 
    local DB_DB=${4} 
    local SIZE_FACTOR=${5:-1}
    local SIZE_FACTOR_NAME

    if [ "${SIZE_FACTOR}" = "1" ]; then
        SIZE_FACTOR_NAME=""
    else
        SIZE_FACTOR_NAME=${SIZE_FACTOR}
    fi
    DB_ARC_USER=${DB_ARC_USER}${SIZE_FACTOR_NAME}

    set -x

    db="${DB_ARC_USER}_${DB_DB}"

    set -x

    rm /tmp/ycsb.fifo.$$ 2>/dev/null
    mkfifo /tmp/ycsb.fifo.$$
    seq 0 $(( 1000000*${SIZE_FACTOR:-1} - 1 )) > /tmp/ycsb.fifo.$$ &
    ycsb_create_mysql | mysql -u ${db} --password=${DB_ARC_PW} -D ${db}

    echo "load data local infile '/tmp/ycsb.fifo.$$' into table YCSBSPARSE (YCSB_KEY);" | \
        mysql -u ${db} \
            --password=${DB_ARC_PW} \
            -D ${db} \
            --local-infile
    rm /tmp/ycsb.fifo.$$

    set +x
}
# 1M, 10M and 100M rows
ycsb_load SRC ${SRCDB_ARC_USER} ${SRCDB_ARC_PW} ycsb 1
if [ -z "${ARCDEMO_DEBUG}" ]; then
    ycsb_load SRC ${SRCDB_ARC_USER} ${SRCDB_ARC_PW} ycsb 10 
    ycsb_load SRC ${SRCDB_ARC_USER} ${SRCDB_ARC_PW} ycsb 100
fi