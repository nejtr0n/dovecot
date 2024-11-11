FROM alpine:3.20.3

ARG S6_OVERLAY_VERSION=3.2.0.2
ARG DOVECOT_VERSION=2.3.21.1-r0
ARG GOMPLATE_VERSION=3.11.7-r6

# Create user
RUN apk add --update --no-cache --virtual .tool-deps \
    shadow \
    && groupadd -g 5000 vmail \
    && useradd -u 5000 -g vmail vmail \
    && usermod -u 5000 vmail \
    && usermod -g 5000 vmail \
    && mkdir -pv /var/mail/vmail \
    && usermod -d /var/mail/vmail vmail \
    && chown vmail:vmail /var/mail/vmail \
    \
    # Cleanup unnecessary stuff
    && apk del .tool-deps \
    && rm -rf /var/cache/apk/*

# install and configure dovecot
RUN apk add --update --no-cache dovecot=${DOVECOT_VERSION} dovecot-lmtpd=${DOVECOT_VERSION} dovecot-pop3d=${DOVECOT_VERSION} dovecot-pgsql=${DOVECOT_VERSION} \
    gomplate=${GOMPLATE_VERSION} \
    && rm -rf /var/cache/apk/*
RUN chown -R dovecot:dovecot /etc/ssl/dovecot \
    && sed -i 's/^!include auth-passwdfile.conf.ext/#!include auth-passwdfile.conf.ext/g' /etc/dovecot/conf.d/10-auth.conf

# copy configs
COPY rootfs /

# Install s6-overlay
RUN export arch="$(apk --print-arch)" \
 && apk add --update --no-cache --virtual .tool-deps \
        curl \
 && curl -fL -o /tmp/s6-overlay-noarch.tar.xz \
         https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz \
 && curl -fL -o /tmp/s6-overlay-bin.tar.xz \
         https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${arch}.tar.xz \
 && tar -xf /tmp/s6-overlay-noarch.tar.xz -C / \
 && tar -xf /tmp/s6-overlay-bin.tar.xz -C / \
    \
 # Cleanup unnecessary stuff
 && apk del .tool-deps \
 && rm -rf /var/cache/apk/* /tmp/* \
 && chmod +x /etc/s6-overlay/s6-rc.d/*/up \
 && chmod +x /etc/s6-overlay/scripts/*


ENTRYPOINT ["/init"]

CMD ["dovecot", "-F"]