# docker-parquet-tools

[![Docker Build Workflow](https://github.com/rm3l/docker-parquet-tools/workflows/Docker%20Image%20CI/badge.svg)](https://github.com/rm3l/docker-parquet-tools/actions?query=workflow%3A%22Docker+Image+CI%22)

[![Docker Stars](https://img.shields.io/docker/stars/rm3l/parquet-tools.svg)](https://hub.docker.com/r/rm3l/parquet-tools)
[![Docker Pulls](https://img.shields.io/docker/pulls/rm3l/parquet-tools.svg)](https://hub.docker.com/r/rm3l/parquet-tools)

[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/rm3l/docker-parquet-tools/blob/master/LICENSE)

## Motivations

At this time, using the [Apache Parquet Tools](https://github.com/apache/parquet-mr/tree/master/parquet-tools) CLI requires either:
- downloading a [pre-built JAR file](https://repo1.maven.org/maven2/org/apache/parquet/parquet-tools/1.11.0/) from a public Maven repository. But, as far as I know, only the Hadoop mode is built, which means that the Hadoop client dependency is not included in the JAR;
- or building it manually, for example if you need a version not released yet.
Building it however requires few operations and dependencies that can easily fit into a Dockerfile, so as to be reusable elsewhere.

This repository provides a quite simple public Docker image that builds the [Apache Parquet Tools](https://github.com/apache/parquet-mr/tree/master/parquet-tools) CLI for both Local and Hadoop modes.
In the end, the Docker image allows to use the CLI in a quite straightfoward manner.

## Example Usage

```bash
docker container run -v /tmp/data:/data --rm -t rm3l/parquet-tools:latest schema /data/<myFile>.parquet
```

## Developed by

* Armel Soro
  * [keybase.io/rm3l](https://keybase.io/rm3l)
  * [rm3l.org](https://rm3l.org) - &lt;armel+parquet_tools@rm3l.org&gt; - [@rm3l](https://twitter.com/rm3l)
  * [paypal.me/rm3l](https://paypal.me/rm3l)
  * [coinbase.com/rm3l](https://www.coinbase.com/rm3l)

## License

    The MIT License (MIT)

    Copyright (c) 2020 Armel Soro

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
