# container: install cli for psh, s3
FROM php:7-cli
RUN apt-get update \
    && apt-get --quiet --yes --no-install-recommends install \
      keychain \
      unzip \
      rsync grsync \
    && curl -L https://github.com/platformsh/platformsh-cli/releases/latest/download/platform.phar -o platform \
    && chmod +x platform && mv platform /usr/local/bin/platform

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
