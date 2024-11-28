# Examples

## Build your own docker image

Edit the `supported_cities.csv` file with a list of supported cities and build your own docker image.

```bash
docker buildx build -t --platform linux/amd64 somleng-inventory-manager:example .
```

## Testing

You can test your image with the following command:

```bash
docker run --platform linux/amd64 --rm -it -e APP_ENV=production -e SOMLENG_API_KEY='somleng-carrier-api-key' -e SOMLENG_API_KEY='somleng-carrier-api-key' -e SKYETEL_USERNAME='skyetel-username' -e SKYETEL_PASSWORD='skyetel-password' -e MIN_STOCK=5 -e MAX_STOCK=10 -e SUPPLIER='skyetel' --entrypoint ./bin/somleng-inventory-manager somleng-inventory-manager:example --verbose --dry-run
```

## Deployment

The image is ready to be deployed to [AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/ruby-image.html#ruby-image-instructions) and can be triggered [on a schedule](https://docs.aws.amazon.com/lambda/latest/dg/with-eventbridge-scheduler.html). Read the AWS docs for details.
