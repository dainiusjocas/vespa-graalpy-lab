// Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
package ai.vespa.examples;

import com.google.inject.Inject;
import com.yahoo.processing.Processor;
import com.yahoo.processing.Request;
import com.yahoo.processing.Response;
import com.yahoo.processing.execution.Execution;
import org.graalvm.polyglot.Context;
import org.graalvm.polyglot.Value;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;

/**
 * An example processor which receives a request and returns a response.
 * If ExampleProcessorConfig is not found you need to run mvn install on this project.
 */
public class ExampleProcessor extends Processor {

    private final String message;

    @Inject
    public ExampleProcessor(ExampleProcessorConfig config) {
        this.message = config.message();
    }

    @SuppressWarnings("unchecked")
    @Override
    public Response process(Request request, Execution execution) {
        // process the request
        request.properties().set("foo", "bar");

        // pass it down the chain to get a response
        Response response = execution.process(request);

        // process the response
        response.data().add(new StringData(request, message));

        System.out.println(">>>>>");
        String graalpyScript = "'FAILED TO LOAD SCRIPT'";

        try (InputStream inputStream = getClass().getResourceAsStream("/graalpy/script.py")) {
            if (inputStream != null) {
                graalpyScript = new String(inputStream.readAllBytes(), StandardCharsets.UTF_8);
                try (Context context = Context.newBuilder("python").build()) {
                    Value value = context.eval("python", graalpyScript);
                    String stringValue = value.asString();
                    response.data().add(new StringData(request, stringValue));
                }
            }
        } catch (Exception e) {
            System.out.println("Failed to load script " + e.getMessage());
            throw new RuntimeException(e);
        }

        System.out.println("<<<<<");

        // return the response up the chain
        return response;
    }

}
