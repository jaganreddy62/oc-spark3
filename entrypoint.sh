#!/bin/bash
ROLE=$1

if [ "$ROLE" = "master" ]; then
  exec $SPARK_HOME/sbin/start-master.sh && tail -f $SPARK_HOME/logs/spark-*.out
elif [ "$ROLE" = "worker" ]; then
  exec $SPARK_HOME/sbin/start-slave.sh spark://$SPARK_MASTER:7077 && tail -f $SPARK_HOME/logs/spark-*.out
elif [ "$ROLE" = "history-server" ]; then
  export SPARK_HISTORY_OPTS="-Dspark.history.fs.logDirectory=s3a://spark-logs -Dspark.history.ui.port=18080"
  exec $SPARK_HOME/sbin/start-history-server.sh && tail -f $SPARK_HOME/logs/spark-*.out
else
  exec "$@"
fi
