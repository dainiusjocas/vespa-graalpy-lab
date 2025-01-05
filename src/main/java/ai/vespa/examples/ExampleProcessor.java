// Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
package ai.vespa.examples;

import com.google.inject.Inject;
import com.yahoo.processing.Processor;
import com.yahoo.processing.Request;
import com.yahoo.processing.Response;
import com.yahoo.processing.execution.Execution;
import org.graalvm.polyglot.Context;
import org.graalvm.python.embedding.utils.GraalPyResources;
import org.graalvm.python.embedding.utils.VirtualFileSystem;

/**
 * An example processor which receives a request and returns a response.
 * If ExampleProcessorConfig is not found you need to run mvn install on this project.
 */
public class ExampleProcessor extends Processor {
    private final Context context;
    private final GraalPy figlet;

    @Inject
    public ExampleProcessor(ExampleProcessorConfig config) {
        this.context = initContext();
        this.figlet = initPyfiglet(this.context);
    }

    private Context initContext() {
        VirtualFileSystem vfs = VirtualFileSystem.newBuilder()
                // This is the trick that makes it all work when deployed in Vespa.
                // As always, the classloader is the tricky part.
                // Main point here is that the VirtualFileSystem class is outside of the bundle,
                // and so it tries to load python dependencies from the classpath of the bundle.
                // While python dependencies must be loaded from the bundle resources.
                // To configure GraalPyResources to search classpath of the bundle we need to pass
                // a class that lives strictly in the bundle.
                // One of such classes is the StringData class, but it can be any other class
                // declared in the bundle.
                .resourceLoadingClass(StringData.class)
                .build();
        try {
            return GraalPyResources.contextBuilder(vfs).build();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private GraalPy initPyfiglet(Context context) {
        return context.eval("python",
                "from pyfiglet import Figlet;f = Figlet(font='slant');f").as(GraalPy.class);
    }

    @SuppressWarnings("unchecked")
    @Override
    public Response process(Request request, Execution execution) {
        // process the request
        String textToRender = request.properties().get("text").toString();
        // pass it down the chain to get a response
        Response response = execution.process(request);
        // add figlet to the response
        String string = figlet.renderText(textToRender);
        response.data().add(new StringData(request, string));
        // return the response up the chain
        return response;
    }

    interface GraalPy {
        String renderText(String string);
    }

    @Override
    public void deconstruct() {
        super.deconstruct();
        this.context.close();
    }
}
