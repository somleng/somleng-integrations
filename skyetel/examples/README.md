## Build your own docker image

1. Edit the supported_cities.csv file with a list of supported cities
2. Build your own docker image

```bash
docker buildx build -t --platform linux/amd64 somleng-skyetel:example .
```

3. Run your image

```bash
docker run --platform linux/amd64 --rm -it --entrypoint /bin/sh somleng-skyetel:example
```
