from container-registry.oracle.com/database/free:23.3.0.0

label maintainer sangkyulee@gmail.com

# for sharing data with arcion 
user root
run mkdir -p ${ORACLE_BASE}/oradata/share
run chown oracle:oinstall ${ORACLE_BASE}/oradata/share

run mkdir -p ${ORACLE_BASE}/oradata/archive_logs
run chown oracle:oinstall ${ORACLE_BASE}/oradata/archive_logs

run mkdir -p ${ORACLE_BASE}/oradata/online_logs
run chown oracle:oinstall ${ORACLE_BASE}/oradata/online_logs

run mkdir -p ${ORACLE_BASE}/oradata/backup
run chown oracle:oinstall ${ORACLE_BASE}/oradata/backup

# switch user back to oracle
user oracle
