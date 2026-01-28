FROM fireflyiii/base:latest

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF

ENV VERSION=$VERSION
ENV BUILD_DATE=$BUILD_DATE
ENV VCS_REF=$VCS_REF

# OCI Image labels
LABEL org.opencontainers.image.authors="Sanandrea <sanandrea8080@gmail.com>"
LABEL org.opencontainers.image.url="https://github.com/sanandrea/data-importer"
LABEL org.opencontainers.image.documentation="https://docs.firefly-iii.org/"
LABEL org.opencontainers.image.source="https://github.com/sanandrea/data-importer"
LABEL org.opencontainers.image.vendor="Sanandrea <sanandrea8080@gmail.com>"
LABEL org.opencontainers.image.licenses="AGPL-3.0-or-later"
LABEL org.opencontainers.image.title="Firefly III Data Importer"
LABEL org.opencontainers.image.description="Firefly III Data Importer - data importer for Firefly III"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.base.name="fireflyiii/base:latest"

# Copy entrypoint and build metadata
COPY entrypoint-web.sh /usr/local/bin/entrypoint.sh
COPY counter.txt /var/www/counter-main.txt
COPY date.txt /var/www/build-date-main.txt

# Set executable permissions
USER root
RUN chmod uga+x /usr/local/bin/entrypoint.sh
USER www-data

# Copy and extract application code
COPY download.zip /var/www/download.zip

RUN unzip -q /var/www/download.zip -d $FIREFLY_III_PATH && \
    chmod -R 775 $FIREFLY_III_PATH/storage && \
    rm /var/www/download.zip

WORKDIR $FIREFLY_III_PATH
