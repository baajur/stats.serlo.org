#!/bin/sh

log_info() {
    time=$(date +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"level\":\"info\",\"time\":\"$time\",\"message\":\"$1\"}"
}

log_fatal() {
    time=$(date +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"level\":\"fatal\",\"time\":\"$time\",\"message\":\"$1\"}"
}

log_warn() {
    time=$(date +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"level\":\"warn\",\"time\":\"$time\",\"message\":\"$1\"}"
}

exit_script() {
  trap - SIGINT SIGTERM # clear the trap
  log_warn "run script shutdown"
}

trap exit_script SIGINT SIGTERM

log_info "run athene2 dbsetup revision $GIT_REVISION"

connect="-h $ATHENE2_DATABASE_HOST --port $ATHENE2_DATABASE_PORT -u $ATHENE2_DATABASE_USER -p$ATHENE2_DATABASE_PASSWORD"

log_info "wait for athene2 database to be ready"
until mysql $connect -e "SHOW DATABASES" >/dev/null 2>/dev/null
do 
    log_warn "could not find athene2 server - retry in 10 seconds"
    sleep 10
done

for retry in 1 2 3 4 5 6 7 8 9 10 ; do
    log_info "check if athene2 database exists"
    mysql $connect -e "SHOW DATABASES" | grep "serlo" >/dev/null 2>/dev/null
    if [[ $? != 0 ]] ; then
        log_info "could not find serlo database lets import the latest dump"
        if [[ -f /tmp/dump.sql ]] ; then
            mysql $connect </tmp/dump.sql
            if [[ $? != 0 ]] ; then
                log_warn "could not import serlo database from dump - trying later"
                continue
            else
                log_info "import serlo database was successful"
                exit 0
            fi
        else
            log_info "serlo database does not exists but no dump file present - trying later"
            contine
        fi
    else
        log_info "serlo database exists - nothing to do"
        exit 0
    fi
    log_info "serlo database does not exist - retry in 10 seconds"
    sleep 10
done

log_info "serlo database does not exist - retry with cron"
exit 1
