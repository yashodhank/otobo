# This is the build file for the OTOBO nginx docker image.
# See also README_DOCKER.md.

# Use the latest nginx.
# This image is based on Debian 10 (Buster). The User is root.
FROM nginx:mainline

# install some required and optional Debian packages
RUN packages=$( echo \
        "less" \
        "nano" \
        "tree" \
        "vim" \
    ) \
    && apt-get update \
    && apt-get -y --no-install-recommends install $packages \
    && rm -rf /var/lib/apt/lists/*

# mostly for documentation
EXPOSE 80/tcp
EXPOSE 443/tcp

# We want an UTF-8 console
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# This setting works in the devel environment.
# In the general case OTOBO_NGINX_WEB_HOST can be set when starting the container:
#   docker run -e OTOBO_NGINX_WEB_HOST=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+') -p 443:443 otobo_nginx
# Attention: specify OTOBO_WEB_PORT to 5000 in .env when
# starting HTTP with 'docker-compose -f docker-compose.yml up'
ENV OTOBO_NGINX_WEB_HOST          172.17.0.1
ENV OTOBO_NGINX_WEB_PORT          5000

# Not that these file need to be copied into a container.
# Alternatively /etc/ssl can be exported as a volume to the host.
ENV OTOBO_NGINX_SSL_CERTIFICATE      /etc/nginx/ssl/otobo_nginx-selfsigned.crt
ENV OTOBO_NGINX_SSL_CERTIFICATE_KEY  /etc/nginx/ssl/otobo_nginx-selfsigned.key

WORKDIR /etc/nginx

# move the old config out of the way
RUN mv conf.d/default.conf conf.d/default.conf.hidden

# new nginx config, will be modified by /docker-entrypoint.d/20-envsubst-on-templates.sh
# See 'Using environment variables in nginx configuration' in https://hub.docker.com/_/nginx
COPY scripts/nginx/templates/ templates
COPY scripts/nginx/snippets/  snippets

LABEL maintainer="Team OTOBO <dev@otobo.org>"
