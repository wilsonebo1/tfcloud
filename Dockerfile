FROM node:lts-stretch-slim

MAINTAINER Platform Squad "enterprise-platform@datarobot.com"

RUN apt-get update && \
    apt-get install -y calibre git && \
    npm install --global gitbook-cli@2.3.2 && \
    npm cache clear --force && \
    rm -rf /tmp/*

WORKDIR /tmp/gitbook

EXPOSE 4000 35729

CMD ["gitbook", "serve"]
