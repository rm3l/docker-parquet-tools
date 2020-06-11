FROM maven:3-jdk-11-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install thrift
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      git \
      wget \
      automake \
      bison \
      flex \
      g++ \
      libboost-all-dev \
      libevent-dev \
      libssl-dev \
      libtool \
      make \
      cmake \
      pkg-config \
  && rm -rf /var/lib/apt/lists/*
ARG THRIFT_VERSION=0.12.0
RUN wget -qO- https://apache.mediamirrors.org/thrift/${THRIFT_VERSION}/thrift-${THRIFT_VERSION}.tar.gz | tar xzvf - -C /opt \
  && mv /opt/thrift-${THRIFT_VERSION} /opt/thrift
RUN mkdir /tmp/cmake-build && cd /tmp/cmake-build \
    && cmake \
       -DBUILD_COMPILER=ON \
       -DBUILD_LIBRARIES=OFF \
       -DBUILD_TESTING=OFF \
       -DBUILD_EXAMPLES=OFF \
       /opt/thrift \
    && cmake --build . --config Release \
    && make install \
    && rm -rf /tmp/* /var/lib/apt/lists/*

ARG BRANCH=master
RUN git clone --single-branch --depth=1 --branch=${BRANCH} https://github.com/apache/parquet-mr.git
WORKDIR /parquet-mr
#RUN mvn --batch-mode -DskipTests dependency:resolve-plugins dependency:go-offline -pl :parquet-tools

# Set to hadoop to use the Hadoop mode
ARG PROFILE=""
RUN if [ "$PROFILE" = "hadoop" ] ; then \
      export MVN_OPTIONS=""; \
    else \
      export MVN_OPTIONS="-Plocal"; \
    fi \
    && mvn --batch-mode -DskipTests \
      clean package \
      ${MVN_OPTIONS} \
      -am -pl \
      :parquet-generator,:parquet-common,:parquet-jackson,:parquet-column,:parquet-encoding,:parquet-hadoop,:parquet-tools

RUN ls -lhrt /parquet-mr/parquet-tools/target/parquet-tools-*.jar

FROM registry.access.redhat.com/ubi8/ubi-minimal:8.2

ARG JAVA_PACKAGE=java-11-openjdk-headless
ARG RUN_JAVA_VERSION=1.3.8

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en'

# Install java and the run-java script
# Also set up permissions for user `1001`
RUN microdnf install curl ca-certificates ${JAVA_PACKAGE} \
    && microdnf update \
    && microdnf clean all \
    && mkdir /deployments \
    && chown 1001 /deployments \
    && chmod "g+rwX" /deployments \
    && chown 1001:root /deployments \
    && curl https://repo1.maven.org/maven2/io/fabric8/run-java-sh/${RUN_JAVA_VERSION}/run-java-sh-${RUN_JAVA_VERSION}-sh.sh -o /deployments/run-java.sh \
    && chown 1001 /deployments/run-java.sh \
    && chmod 540 /deployments/run-java.sh \
    && echo "securerandom.source=file:/dev/urandom" >> /etc/alternatives/jre/lib/security/java.security

COPY --from=builder /usr/local/bin/thrift /usr/local/bin/thrift
COPY --from=builder /parquet-mr/parquet-tools/target/parquet-tools-*.jar /deployments/app.jar

ENV JAVA_OPTIONS="-XX:-UsePerfData"

USER 1001

ENTRYPOINT [ "/deployments/run-java.sh" ]

