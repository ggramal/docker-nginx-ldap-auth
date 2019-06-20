FROM ubuntu:18.04
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y gettext dumb-init nginx-full curl libpam-ldapd libnss-ldapd --no-install-recommends && \
    apt-get clean autoclean && apt-get autoremove -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/
ADD docker-entrypoint.sh                      /docker-entrypoint.sh
ADD templates/                               /
RUN chmod 700 /docker-entrypoint.sh && \
    groupadd -g 999 nginx && \
    useradd -r -u 999 -g nginx nginx && \
    rm /etc/nginx/sites-enabled/default && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log
EXPOSE 80 443
ENTRYPOINT ["/docker-entrypoint.sh"]
