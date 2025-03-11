FROM vespaengine/vespa:8.492.15

USER root

ARG GRAALPY_DIR=/opt/vespa/lib/graalpy
ARG MAVEN_REPO=https://repo1.maven.org/maven2
ARG GRAALVM_VERSION=24.1.2

# Put GraalPy jars into a separate directory
RUN mkdir $GRAALPY_DIR && \
    curl -s $MAVEN_REPO/org/graalvm/polyglot/polyglot/$GRAALVM_VERSION/polyglot-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/polyglot-$GRAALVM_VERSION.jar && \
    curl -s $MAVEN_REPO/org/graalvm/sdk/collections/$GRAALVM_VERSION/collections-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/collections-$GRAALVM_VERSION.jar && \
    curl -s $MAVEN_REPO/org/graalvm/sdk/nativeimage/$GRAALVM_VERSION/nativeimage-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/nativeimage-$GRAALVM_VERSION.jar && \
    curl -s $MAVEN_REPO/org/graalvm/sdk/word/$GRAALVM_VERSION/word-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/word-$GRAALVM_VERSION.jar && \
    curl -s $MAVEN_REPO/org/graalvm/python/python-language/$GRAALVM_VERSION/python-language-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/python-language-$GRAALVM_VERSION.jar && \
    curl -s $MAVEN_REPO/org/graalvm/truffle/truffle-api/$GRAALVM_VERSION/truffle-api-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/truffle-api-$GRAALVM_VERSION.jar && \
    curl -s $MAVEN_REPO/org/graalvm/truffle/truffle-nfi/$GRAALVM_VERSION/truffle-nfi-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/truffle-nfi-$GRAALVM_VERSION.jar && \
    curl -s $MAVEN_REPO/org/graalvm/truffle/truffle-nfi-libffi/$GRAALVM_VERSION/truffle-nfi-libffi-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/truffle-nfi-libffi-$GRAALVM_VERSION.jar && \
    curl -s $MAVEN_REPO/org/graalvm/regex/regex/$GRAALVM_VERSION/regex-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/regex-$GRAALVM_VERSION.jar && \
    curl -s $MAVEN_REPO/org/graalvm/llvm/llvm-api/$GRAALVM_VERSION/llvm-api-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/llvm-api-$GRAALVM_VERSION.jar && \
    curl -s $MAVEN_REPO/org/graalvm/shadowed/json/$GRAALVM_VERSION/json-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/json-$GRAALVM_VERSION.jar && \
    curl -s $MAVEN_REPO/org/graalvm/shadowed/icu4j/$GRAALVM_VERSION/icu4j-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/icu4j-$GRAALVM_VERSION.jar && \
    curl -s $MAVEN_REPO/org/graalvm/shadowed/xz/$GRAALVM_VERSION/xz-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/xz-$GRAALVM_VERSION.jar && \
    curl -s $MAVEN_REPO/org/graalvm/tools/profiler-tool/$GRAALVM_VERSION/profiler-tool-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/profiler-tool-$GRAALVM_VERSION.jar && \
    curl -s $MAVEN_REPO/org/graalvm/truffle/python-resources/$GRAALVM_VERSION/python-resources-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/python-resources-$GRAALVM_VERSION.jar && \
    curl -s $MAVEN_REPO/org/graalvm/truffle/truffle-runtime/$GRAALVM_VERSION/truffle-runtime-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/truffle-runtime-$GRAALVM_VERSION.jar && \
    curl -s $MAVEN_REPO/org/graalvm/truffle/truffle-enterprise/$GRAALVM_VERSION/truffle-enterprise-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/truffle-enterprise-$GRAALVM_VERSION.jar && \
    curl -s $MAVEN_REPO/org/graalvm/truffle/truffle-compiler/$GRAALVM_VERSION/truffle-compiler-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/truffle-compiler-$GRAALVM_VERSION.jar && \
    curl -s $MAVEN_REPO/org/graalvm/sdk/jniutils/$GRAALVM_VERSION/jniutils-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/jniutils-$GRAALVM_VERSION.jar && \
    curl -s $MAVEN_REPO/org/graalvm/sdk/nativebridge/$GRAALVM_VERSION/nativebridge-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/nativebridge-$GRAALVM_VERSION.jar && \
    curl -s $MAVEN_REPO/org/graalvm/python/python-embedding/$GRAALVM_VERSION/python-embedding-$GRAALVM_VERSION.jar \
          --output $GRAALPY_DIR/python-embedding-$GRAALVM_VERSION.jar && \
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
