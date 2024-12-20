# Inventory Manager

[![Inventory Manager](https://github.com/somleng/somleng-integrations/actions/workflows/inventory-manager.yml/badge.svg)](https://github.com/somleng/somleng-integrations/actions/workflows/inventory-manager.yml)

This integration runs on a schedule and automatically orders DIDs from the given supplier and adds them to [Somleng](https://www.somleng.org/docs.html). It keeps the stock levels between `MIN_STOCK` and `MAX_STOCK` for each city configured in the `supported_cities.csv` file.

## Configuration

| Variable                   | Description                                               | Example                | Required | Default                |
| -------------------------- | --------------------------------------------------------- | ---------------------- | -------- | ---------------------- |
| APP_ENV                    | Application environment                                   | production             | false    | production             |
| SUPPLIER                   | Name of the Supplier                                      | skyetel                | true     | none                   |
| SOMLENG_API_KEY            | Somleng Carrier API Key SID                               | change-me              | true     | none                   |
| SKYETEL_USERNAME           | Skyetel API Username Token                                | change-me              | true     | none                   |
| SKYETEL_PASSWORD           | Skyetel API Password                                      | change-me              | true     | none                   |
| MIN_STOCK                  | Minimum number of phone numbers to maintain per city      | 50                     | true     | 0                      |
| MAX_STOCK                  | Maximum number of phone numbers to maintain per city      | 100                    | true     | 0                      |
| SUPPORTED_CITIES_DATA_FILE | Name of the CSV file containing supported cities          | `supported_cities.csv` | false    | `supported_cities.csv` |
| SOMLENG_NUMBER_VISIBILITY  | Visibility of created phone number. `public` or `private` | `public`               | false    | `public`               |

## Usage

See [examples](examples).

## CLI

The CLI can be used to test your integration.

```bash
Usage: somleng-inventory-manager [options]
        --[no-]dry-run [FLAG]        Dry run only. No phone numbers will be actually purchased.
        --[no-]verbose [FLAG]        Run verbosely
    -h, --help                       Prints this help
```

## Deployment

The [docker image](https://github.com/somleng/somleng-integrations/pkgs/container/somleng-inventory-manager) is automatically configured for deployment to AWS Lambda.
