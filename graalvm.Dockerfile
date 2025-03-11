FROM vespa-graalpy-1

USER root

# Install GraalVM JVM
ARG JAVA_VERSION=23

RUN mkdir /usr/lib/jvm/graalvm-java$JAVA_VERSION
COPY --from=container-registry.oracle.com/graalvm/jdk:23.0.2-ol8-20250210 \
        /usr/lib64/graalvm/graalvm-java$JAVA_VERSION \
        /usr/lib/jvm/graalvm-java$JAVA_VERSION

# Set alternative to GraalVM Java
RUN alternatives --install /usr/bin/java java /usr/lib/jvm/graalvm-java$JAVA_VERSION/bin/java 2 && \
    alternatives --install /usr/bin/javac javac /usr/lib/jvm/graalvm-java$JAVA_VERSION/bin/javac 2 && \
    alternatives --set java /usr/lib/jvm/graalvm-java$JAVA_VERSION/bin/java && \
    alternatives --set javac /usr/lib/jvm/graalvm-java$JAVA_VERSION/bin/javac

ENV JAVA_HOME=/usr/lib/jvm/graalvm-java$JAVA_VERSION

# macos specific hacks
# For MacOS we need pass -XX:UseSVE=0 arg
ENV JDK_JAVA_OPTIONS="-XX:UseSVE=0"

USER vespa
