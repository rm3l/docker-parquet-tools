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
RUN rm -rf /parquet-mr/parquet-tools/target/parquet-tools-*-tests.jar

FROM gcr.io/distroless/java:11

COPY --from=builder /usr/local/bin/thrift /usr/local/bin/thrift
COPY --from=builder /parquet-mr/parquet-tools/target/parquet-tools-*.jar /app/parquet-tools.jar

ENTRYPOINT [ "java", "-XX:-UsePerfData", "-jar", "/app/parquet-tools.jar" ]

