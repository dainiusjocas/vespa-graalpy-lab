# vespa-graalpy-lab

Running Python code in Vespa containers with GraalPy.

## Adding GraalPy code

Following the [guide](https://www.graalvm.org/python/#getting-started).

```shell
docker build -f Dockerfile -t vespa-graalpy-1 .
docker run --rm --name vespa --hostname vespa-container \
  --publish 0.0.0.0:8080:8080 --publish 0.0.0.0:19071:19071 \
  vespa-graalpy-1
mvn clean -DskipTests package && \
  vespa deploy -w 120 -t http://0.0.0.0:19071 && \
  curl -s http://0.0.0.0:8080/processing/\?text\=FOOBAR
```

One request with properly printing the response.
```shell
curl -s http://localhost:8080/processing/\?text\=Dainius | jq '.datalist[0].data' -r
```

## Benchmarking

### Default JVM

Concurrency=1
```
echo "GET http://localhost:8080/processing/?text=FOOBAR" \
| vegeta attack -duration=10s -rate=0 -workers 1 -max-workers 1 \
| vegeta report
Requests      [total, rate, throughput]         9270, 926.93, 926.84
Duration      [total, attack, wait]             10.002s, 10.001s, 984.125µs
Latencies     [min, mean, 50, 90, 95, 99, max]  895.458µs, 1.074ms, 1.055ms, 1.165ms, 1.217ms, 1.41ms, 7.832ms
Bytes In      [total, mean]                     2623410, 283.00
Bytes Out     [total, mean]                     0, 0.00
Success       [ratio]                           100.00%
Status Codes  [code:count]                      200:9270
```

Concurrency=8
```
 echo "GET http://localhost:8080/processing/?text=FOOBAR" \
| vegeta attack -duration=10s -rate=0 -workers 8 -max-workers 8 \
| vegeta report
Requests      [total, rate, throughput]         14345, 1434.24, 1433.99
Duration      [total, attack, wait]             10.003s, 10.002s, 1.075ms
Latencies     [min, mean, 50, 90, 95, 99, max]  1.028ms, 5.505ms, 5.45ms, 5.834ms, 6.057ms, 6.867ms, 23.685ms
Bytes In      [total, mean]                     4059352, 282.98
Bytes Out     [total, mean]                     0, 0.00
Success       [ratio]                           99.99%
Status Codes  [code:count]                      0:1  200:14344
```

### GraalVM 23

Build a Docker image and run it:
```shell
docker build -f Dockerfile -t vespa-graalpy-1 .
docker build -f graalvm.Dockerfile -t vespa-graalvm-graalpy-1 .
docker run --rm --name vespa-graalvm --hostname vespa-container \
  --publish 0.0.0.0:8080:8080 --publish 0.0.0.0:19071:19071 \
  vespa-graalvm-graalpy-1
mvn clean -DskipTests package && \
  vespa deploy -w 120 -t http://0.0.0.0:19071 && \
  curl -s http://0.0.0.0:8080/processing/\?text\=FOOBAR
```

Concurrency=1
```
echo "GET http://localhost:8080/processing/?text=FOOBAR" \
| vegeta attack -duration=10s -rate=0 -workers 1 -max-workers 1 \
| vegeta report
Requests      [total, rate, throughput]         20653, 2065.30, 2065.21
Duration      [total, attack, wait]             10s, 10s, 436.5µs
Latencies     [min, mean, 50, 90, 95, 99, max]  394.875µs, 481.576µs, 468.612µs, 525.774µs, 573.852µs, 664.375µs, 5.055ms
Bytes In      [total, mean]                     5844799, 283.00
Bytes Out     [total, mean]                     0, 0.00
Success       [ratio]                           100.00%
Status Codes  [code:count]                      200:20653
```

Concurrency=8
```shell
echo "GET http://localhost:8080/processing/?text=FOOBAR" \
| vegeta attack -duration=10s -rate=0 -workers 8 -max-workers 8 \
| vegeta report
Requests      [total, rate, throughput]         78592, 7859.19, 7858.42
Duration      [total, attack, wait]             10.001s, 10s, 980.875µs
Latencies     [min, mean, 50, 90, 95, 99, max]  447.834µs, 1.008ms, 991.243µs, 1.304ms, 1.402ms, 1.634ms, 5.893ms
Bytes In      [total, mean]                     22241536, 283.00
Bytes Out     [total, mean]                     0, 0.00
Success       [ratio]                           100.00%
Status Codes  [code:count]                      200:78592
```

So GraalVM is ~2x faster single threaded, and ~5x faster with 8 threads.

## Overall setup

In the `Dockerfile` we have to create a directory with the GraalPy dependencies.
This directory must be referenced in the `services.xml` file under `classpath_extra` tag.
The Python code should be added under the `resources/org.graalvm.python.vfs/` directory.
In a Java class add code to run the Python code as per GraalPy examples.

## Future work

- [ ] minimize the dependencies list (now 193 MB)
- [ ] How to give the request/response objects for python
- [ ] Add a Python library that has native extensions
- [ ] Resource pool for the Python component as it is single [threaded](https://github.com/oracle/graalpython/blob/08eaa6f1c4328a77b445792e1e70f98b129fe3d2/docs/contributor/IMPLEMENTATION_DETAILS.md?plain=1#L143)
