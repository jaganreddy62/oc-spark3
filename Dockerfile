FROM openjdk:11-jre-slim

ENV SPARK_VERSION=3.5.1 \
    HADOOP_VERSION=3 \
    SPARK_HOME=/opt/spark

RUN apt-get update && \
    apt-get install -y curl tar bash && \
    curl -fSL https://downloads.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz | tar -xz -C /opt && \
    mv /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} ${SPARK_HOME} && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PATH="$SPARK_HOME/bin:$PATH"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR ${SPARK_HOME}
ENTRYPOINT ["/entrypoint.sh"]
