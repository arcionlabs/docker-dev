#!/usr/bin/env bash

recover() {

    set -x 
    rman target / <<EOF
    shutdown immediate;
EOF

    rm -rf $ARCHREDO/*

    scn=$(cat $LOGDIR/backup.log | grep -m 1 -A 1 CURRENT_SCN | tail -1)

    if [ -z "$scn" ]; then
        rm -rf /opt/oracle/oradata/*
        rm -rf /opt/oracle/oradata/.*
    else
        rman target / <<EOF
        startup mount;
        run
        {
        set until sequence $scn;
        restore database;
        recover database;
        alter database open resetlogs;
        }
        shutdown immediate;
EOF
    fi

    set +x
}

redocnt=$(ls $REDO | wc -l)
echo "Crash recover $LOGDIR/redo.large.log and online redo cnt ($redocnt)> 0"
if [  -f "$LOGDIR/redo.large.log" ] && (( redocnt == 0 )); then 
    recover
elif [  -f "$LOGDIR/redo.large.log" ] && (( redocnt > 0 )); then
    echo "skipping."
else
    echo "skipping."
fi

# run the regular oracle startup
exec $ORACLE_BASE/$RUN_FILE