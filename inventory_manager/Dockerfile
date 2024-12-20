# syntax=docker/dockerfile:1.7-labs

ARG RUBY_VERSION=3.3
FROM public.ecr.aws/lambda/ruby:$RUBY_VERSION AS build-image

RUN dnf update && \
    dnf -y install git openssl-devel gcc make

COPY Gemfile Gemfile.lock ${LAMBDA_TASK_ROOT}/

RUN gem install bundler && \
    bundle config --local deployment true && \
    bundle config --local path "vendor/bundle" && \
    bundle config --local without 'development test' && \
    bundle install

RUN rm -rf vendor/bundle/ruby/*/cache/ && find vendor/ -name "*.o" -delete && find vendor/ -name "*.c"

COPY --link app.rb ${LAMBDA_TASK_ROOT}/
COPY --link app/ ${LAMBDA_TASK_ROOT}/app/
COPY --link bin/ ${LAMBDA_TASK_ROOT}/bin/
COPY --link --exclude=*.key --exclude=*.sample.csv config/ ${LAMBDA_TASK_ROOT}/config/
COPY --link lib/ ${LAMBDA_TASK_ROOT}/lib/

# #############################

FROM public.ecr.aws/lambda/ruby:$RUBY_VERSION

COPY --from=build-image ${LAMBDA_TASK_ROOT} ${LAMBDA_TASK_ROOT}

ENV RUBY_YJIT_ENABLE=true
ENV APP_ENV=production

CMD [ "app.App::Handler.process" ]
