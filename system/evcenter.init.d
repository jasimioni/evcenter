#!/bin/sh
#
# evcenter - stop/start portal htt
#
# chkconfig: - 90 10
# description: Portal http://easyportal.horizonstelecom.com.
#

### BEGIN INIT INFO
### END INIT INFO

# Source function library.
. /etc/init.d/functions

EV_HOME="/opt/evcenter"
EV_USER=evcenter
LOG_DIR=$EV_HOME/var/log

export PERL5LIB=$EV_HOME/EVCenter/lib

status() {
    ps -ef | grep star\\man | grep evcenter
    if [ $? -eq 0 ]
    then
        echo "Starman rodando"
    else
        echo "Starman nao esta rodando"
    fi
}

stop() {
    ps -ef | grep star\\man | grep -q evcenter
    if [ $? -gt 0 ]
    then
        echo "Starman nao esta rodando"
    else
        echo "Matando processo..."
        for PID in `ps -ef | grep starman | grep evcenter | awk '{ print $2 }'`
        do
            kill $PID
        done
        sleep 1
        ps -ef | grep star\\man | grep -q evcenter
        if [ $? -gt 0 ]
        then
            echo "Processo Encerrado"
        else
            echo "Falha ao encerrar processo"
        fi
    fi
}

start() {
    echo "Iniciando Starman"
    su $EV_USER -c "/usr/local/bin/starman $EV_HOME/EVCenter/evcenter.psgi -l :5000 --daemonize --pid $EV_HOME/var/run/evcenter.pid --access-log $LOG_DIR/evcenter_access.log --error-log $LOG_DIR/evcenter_error.log"
    status
}

restart()
{
        stop
        start
}

reload() {
    for PID in `ps -ef | grep starman | grep evcenter | awk '{ print $2 }'`
    do
        kill -HUP $PID
    done
}


case "$1" in
        start|stop|restart|reload)
                $1
                ;;
        status)
        status
                ;;
        *)
                echo $"Usage: $0 {start|stop|restart|reload}"
                exit 1
esac

exit $?
