FROM vespaengine/vespa:8.452.13

USER root

ARG GRAALPY_DIR=/opt/vespa/lib/graalpy
ARG MAVEN_REPO=https://repo1.maven.org/maven2

# Put GraalPy jars into a separate directory
RUN mkdir $GRAALPY_DIR && \
    curl -s $MAVEN_REPO/org/graalvm/polyglot/polyglot/24.1.1/polyglot-24.1.1.jar \
          --output $GRAALPY_DIR/polyglot-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/graalvm/sdk/collections/24.1.1/collections-24.1.1.jar \
          --output $GRAALPY_DIR/collections-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/graalvm/sdk/nativeimage/24.1.1/nativeimage-24.1.1.jar \
          --output $GRAALPY_DIR/nativeimage-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/graalvm/sdk/word/24.1.1/word-24.1.1.jar \
          --output $GRAALPY_DIR/word-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/graalvm/python/python-language/24.1.1/python-language-24.1.1.jar \
          --output $GRAALPY_DIR/python-language-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/graalvm/truffle/truffle-api/24.1.1/truffle-api-24.1.1.jar \
          --output $GRAALPY_DIR/truffle-api-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/graalvm/truffle/truffle-nfi/24.1.1/truffle-nfi-24.1.1.jar \
          --output $GRAALPY_DIR/truffle-nfi-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/graalvm/truffle/truffle-nfi-libffi/24.1.1/truffle-nfi-libffi-24.1.1.jar \
          --output $GRAALPY_DIR/truffle-nfi-libffi-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/graalvm/regex/regex/24.1.1/regex-24.1.1.jar \
          --output $GRAALPY_DIR/regex-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/graalvm/llvm/llvm-api/24.1.1/llvm-api-24.1.1.jar \
          --output $GRAALPY_DIR/llvm-api-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/graalvm/shadowed/json/24.1.1/json-24.1.1.jar \
          --output $GRAALPY_DIR/json-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/graalvm/shadowed/icu4j/24.1.1/icu4j-24.1.1.jar \
          --output $GRAALPY_DIR/icu4j-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/graalvm/shadowed/xz/24.1.1/xz-24.1.1.jar \
          --output $GRAALPY_DIR/xz-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/graalvm/tools/profiler-tool/24.1.1/profiler-tool-24.1.1.jar \
          --output $GRAALPY_DIR/profiler-tool-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/graalvm/truffle/python-resources/24.1.1/python-resources-24.1.1.jar \
          --output $GRAALPY_DIR/python-resources-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/graalvm/truffle/truffle-runtime/24.1.1/truffle-runtime-24.1.1.jar \
          --output $GRAALPY_DIR/truffle-runtime-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/graalvm/truffle/truffle-enterprise/24.1.1/truffle-enterprise-24.1.1.jar \
          --output $GRAALPY_DIR/truffle-enterprise-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/graalvm/truffle/truffle-compiler/24.1.1/truffle-compiler-24.1.1.jar \
          --output $GRAALPY_DIR/truffle-compiler-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/graalvm/sdk/jniutils/24.1.1/jniutils-24.1.1.jar \
          --output $GRAALPY_DIR/jniutils-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/graalvm/sdk/nativebridge/24.1.1/nativebridge-24.1.1.jar \
          --output $GRAALPY_DIR/nativebridge-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/graalvm/python/python-embedding/24.1.1/python-embedding-24.1.1.jar \
          --output $GRAALPY_DIR/python-embedding-24.1.1.jar && \
    curl -s $MAVEN_REPO/org/bouncycastle/bcpkix-jdk18on/1.78.1/bcpkix-jdk18on-1.78.1.jar \
          --output $GRAALPY_DIR/bcpkix-jdk18on-1.78.1.jar && \
    curl -s $MAVEN_REPO/org/bouncycastle/bcprov-jdk18on/1.78.1/bcprov-jdk18on-1.78.1.jar \
          --output $GRAALPY_DIR/bcprov-jdk18on-1.78.1.jar && \
    curl -s $MAVEN_REPO/org/bouncycastle/bcutil-jdk18on/1.78.1/bcutil-jdk18on-1.78.1.jar \
          --output $GRAALPY_DIR/bcutil-jdk18on-1.78.1.jar

# Change ownership of several directories so that classes could be loaded
RUN chown vespa -R $GRAALPY_DIR && \
    mkdir /opt/vespa/.cache && \
    chown vespa -R /opt/vespa/.cache

USER vespa
