# Examples

## Build your own docker image

Edit the `supported_cities.csv` file with a list of supported cities and build your own docker image.

```bash
docker buildx build -t --platform linux/amd64 somleng-skyetel:example .
```

## Deployment

The image is ready to be deployed to AWS Lambda and can be triggered by a scheduler.

## Standalone mode

If you're not using Lambda, you can run your image with the following command:

```bash
docker run --platform linux/amd64 --rm -it -e APP_ENV=production -e SOMLENG_API_KEY='somleng-carrier-api-key' SOMLENG_API_KEY='somleng-carrier-api-key' -e SKYETEL_USERNAME='skyetel-username' -e SKYETEL_PASSWORD='skyetel-password' -e MIN_STOCK=5 -e MAX_STOCK=10 --entrypoint ./bin/somleng-skyetel somleng-skyetel:example
```
