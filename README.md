# vespa-pygraal-lab
Try to run python in Vespa containers with pygraal

<!-- Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root. -->

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://assets.vespa.ai/logos/Vespa-logo-green-RGB.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://assets.vespa.ai/logos/Vespa-logo-dark-RGB.svg">
  <img alt="#Vespa" width="200" src="https://assets.vespa.ai/logos/Vespa-logo-dark-RGB.svg" style="margin-bottom: 25px;">
</picture>


## Adding pygraal code

Following the [guide](https://www.graalvm.org/python/#getting-started).

## Problems

After the basic setup we get this exception back:
```text
Container.com.yahoo.processing.handler.ProcessingHandler	Uncaught exception handling request\nexception=\njava.lang.IllegalStateException: No language and polyglot implementation was found on the module-path. Make sure at last one language is added to the module-path. 
	at org.graalvm.polyglot.Engine$PolyglotInvalid.noPolyglotImplementationFound(Engine.java:1801)
	at org.graalvm.polyglot.Engine$PolyglotInvalid.createHostAccess(Engine.java:1792)
	at org.graalvm.polyglot.Engine$PolyglotInvalid.createHostAccess(Engine.java:1754)
	at org.graalvm.polyglot.Engine$Builder.build(Engine.java:741)
	at org.graalvm.polyglot.Context$Builder.build(Context.java:1925)
	at org.graalvm.polyglot.Context.create(Context.java:979)
	at ai.vespa.examples.ExampleProcessor.process(ExampleProcessor.java:37)
	at com.yahoo.processing.execution.Execution.process(Execution.java:112)
	at com.yahoo.processing.handler.AbstractProcessingHandler.handle(AbstractProcessingHandler.java:126)
	at com.yahoo.container.jdisc.ThreadedHttpRequestHandler.handleRequest(ThreadedHttpRequestHandler.java:87)
	at com.yahoo.container.jdisc.ThreadedRequestHandler$RequestTask.processRequest(ThreadedRequestHandler.java:191)
	at com.yahoo.container.jdisc.ThreadedRequestHandler$RequestTask.run(ThreadedRequestHandler.java:185)
	at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1136)
	at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:635)
	at java.base/java.lang.Thread.run(Thread.java:840)\n
```

Adding `<scope>compile</scope>` to pom.xml to the GraalPy dependencies doesn't help.

When `scope=provided` then class cannot be found:
```text
[2024-12-20 11:08:52.965] ERROR   container        Container.com.yahoo.protect.Process	java.lang.Error handling request\nexception=\njava.lang.NoClassDefFoundError: org/graalvm/polyglot/Context
	at ai.vespa.examples.ExampleProcessor.process(ExampleProcessor.java:37)
	at com.yahoo.processing.execution.Execution.process(Execution.java:112)
	at com.yahoo.processing.handler.AbstractProcessingHandler.handle(AbstractProcessingHandler.java:126)
	at com.yahoo.container.jdisc.ThreadedHttpRequestHandler.handleRequest(ThreadedHttpRequestHandler.java:87)
	at com.yahoo.container.jdisc.ThreadedRequestHandler$RequestTask.processRequest(ThreadedRequestHandler.java:191)
	at com.yahoo.container.jdisc.ThreadedRequestHandler$RequestTask.run(ThreadedRequestHandler.java:185)
	at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1136)
	at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:635)
	at java.base/java.lang.Thread.run(Thread.java:840)\nCaused by: java.lang.ClassNotFoundException: org.graalvm.polyglot.Context not found by generic-request-processing [31]
	at org.apache.felix.framework.BundleWiringImpl.findClassOrResourceByDelegation(BundleWiringImpl.java:1591)
	at org.apache.felix.framework.BundleWiringImpl.access$300(BundleWiringImpl.java:79)
	at org.apache.felix.framework.BundleWiringImpl$BundleClassLoader.loadClass(BundleWiringImpl.java:1976)
	at java.base/java.lang.ClassLoader.loadClass(ClassLoader.java:525)
	... 9 more
```

# Vespa sample applications - a generic request-response processing application

A simple stateless Vespa application demonstrating general composable request-response processing with Vespa.
No content cluster is configured just a stateless Java container.
A custom config class is created and used to control the processing component.

Refer to [getting started](https://docs.vespa.ai/en/getting-started.html) for more information.


### Executable example

**Validate environment, should be minimum 4G:**

Refer to [Docker memory](https://docs.vespa.ai/en/operations-selfhosted/docker-containers.html#memory)
for details and troubleshooting:
<pre>
$ docker info | grep "Total Memory"
or
$ podman info | grep "memTotal"
</pre>

**Check-out, compile and run:**
<pre data-test="exec">
$ git clone --depth 1 https://github.com/vespa-engine/sample-apps.git
$ cd sample-apps/examples/generic-request-processing &amp;&amp; mvn clean package
$ docker run --detach --name vespa --hostname vespa-container \
  --publish 127.0.0.1:8080:8080 --publish 127.0.0.1:19071:19071 \
  vespaengine/vespa
</pre>

**Wait for the configserver to start:**
<pre data-test="exec" data-test-wait-for="200 OK">
$ curl -s --head http://localhost:19071/ApplicationStatus
</pre>

**Deploy the application:**
<pre data-test="exec" data-test-assert-contains="prepared and activated.">
$ curl --header Content-Type:application/zip --data-binary @target/application.zip \
  localhost:19071/application/v2/tenant/default/prepareandactivate
</pre>

**Wait for the application to start:**
<pre data-test="exec" data-test-wait-for="200 OK">
$ curl -s --head http://localhost:8080/ApplicationStatus
</pre>

**Test the application:**
<pre data-test="exec" data-test-assert-contains="Hello, services!">
$ curl -s http://localhost:8080/processing/
</pre>

**Shutdown and remove the container:**
<pre data-test="after">
$ docker rm -f vespa
</pre>
