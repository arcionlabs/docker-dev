#!/usr/bin/env bash

manual_run=$1

# do not use `exit`.  it won't start the next script
# when run automated, the script does not work.

# the below are generic
archstatus() {
    sqlplus sys/${ORACLE_PWD}@${ORACLE_SID} as sysdba <<'EOF'
    SELECT i.instance_name, i.thread#,
    (SELECT DISTINCT DECODE(SUBSTR(f.member, 1, 1), '+', 'ASM', 'FS')
    FROM v$log l, v$logfile f
    WHERE l.thread# = i.thread#
    AND l.group# = f.group#)
    online_type,
    (SELECT DECODE(SUBSTR(a.name, 1, 1), '+', 'ASM', 'FS')
    FROM v$archived_log a
    WHERE dest_id = 1
    AND a.thread# = i.thread#
    AND a.sequence# =
    (SELECT max(al.sequence#)
    FROM v$archived_log al
    WHERE al.thread# = a.thread#)) archived_type
    FROM gv$instance i;
EOF
}

ora_showarchdest() {
    sqlplus sys/${ORACLE_PWD}@${ORACLE_SID} as sysdba <<'EOF'
    select name,log_mode from v$database;
    archive log list;
    select destination, status from v$archive_dest where status='VALID';
    select group#,sequence#,bytes,archived,status from v$log;
    select group#, member from v$logfile order by group#, member;
EOF
}

ora_shutdown() {
    sqlplus sys/${ORACLE_PWD}@${ORACLE_SID} as sysdba <<EOF
    -- set archive
    alter system set log_archive_dest_1='LOCATION=$ARCHREDO' scope=both;
    shutdown immediate;
EOF
}

ora_archenable() {
    sqlplus sys/${ORACLE_PWD} as sysdba <<'EOF'
    -- enable archive log
    startup mount
    alter database archivelog;
    alter database open;
    ALTER DATABASE FORCE LOGGING;
EOF
}

setup_archredo() {
    mkdir $ARCHREDO
    ora_showarchdest
    ora_shutdown
    sleep 10
    ora_archenable
    sleep 10
    ora_showarchdest
    archstatus
}

# skip if already run
echo "Checking $LOGDIR/arcion_arch.log this script already ran"
if [  -f "$LOGDIR/arcion_arch.log" ] || [ "$ORACLE_SID^^" == "ORCL" ]; then 
    echo "skipping."
else
    # create archive redo log
    setup_archredo | tee -a $LOGDIR/arcion_arch.log
fi