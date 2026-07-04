ARG WP_CLI_IMAGE_TAG=cli

FROM wordpress:${WP_CLI_IMAGE_TAG}

USER root
RUN apk add --no-cache bash

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
