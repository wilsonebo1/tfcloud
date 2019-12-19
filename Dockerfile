FROM node:lts-stretch-slim

MAINTAINER Platform Squad "enterprise-platform@datarobot.com"

RUN apt-get update && apt-get install -y calibre git
RUN npm install --global gitbook-cli@2.3.2 && \
    npm cache clear --force && \
    rm -rf /tmp/*
RUN mkdir /tmp/gitbook && \
    cd /tmp/gitbook && \
    gitbook install

WORKDIR /tmp/gitbook

EXPOSE 4000 35729

CMD ["gitbook", "serve"]
