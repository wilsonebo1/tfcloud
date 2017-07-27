FROM node:slim

MAINTAINER Release Squad "release@datarobot.com"

RUN apt-get update && \
    apt-get install -y calibre && \
    npm install --global gitbook-cli && \
    gitbook fetch latest && \
    npm cache clear --force && \
    rm -rf /tmp/*

WORKDIR /gitbook

EXPOSE 4000 35729

CMD ["gitbook", "serve"]
