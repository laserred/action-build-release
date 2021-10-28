FROM ubuntu:latest

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 14.16.0
ENV TZ=GMT+0

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y build-essential
RUN apt-get install -y zip unzip curl php php-cli php-dev php-curl php-mbstring php-xmlrpc git rsync
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=1.10.16
RUN curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin/node
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
ENV PATH="/usr/local/bin:${PATH}"

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]