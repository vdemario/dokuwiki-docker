# VERSION 1.0
# AUTHOR:         Vitor De Mario <vitordemario@gmail.com>
# DESCRIPTION:    Image with DokuWiki & lighttpd based on Miroslav Prasil's mprasil/dokuwiki image on https://registry.hub.docker.com/u/mprasil/dokuwiki/. Only change is removal of '/' on VOLUMES declaration.
#		  This might not be a correct change, but it was the way I found to add my own data and conf folders from a existing standalone dokuwiki running outside of docker.
# TO_BUILD:       docker build -t vdemario/dokuwiki .
# TO_RUN:         docker run -d -p 80:80 --name wiki vdemario/dokuwiki

FROM ubuntu:14.04
MAINTAINER Vitor De Mario <vitordemario@gmail.com>

# Set the version you want of Twiki
ENV DOKUWIKI_VERSION 2014-05-05a
ENV DOKUWIKI_CSUM fb44f206d1550921c640757599e90bb9

ENV LAST_REFRESHED 27. November 2014
# Update & install packages
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install wget \
    lighttpd \
    php5-cgi \
    php5-gd

# Download & deploy dokuwiki
RUN wget -O /dokuwiki.tgz \
    "http://download.dokuwiki.org/src/dokuwiki/dokuwiki-$DOKUWIKI_VERSION.tgz"
RUN if [ "$DOKUWIKI_CSUM" != "$(md5sum /dokuwiki.tgz | awk '{print($1)}')" ];\
  then echo "Wrong md5sum of downloaded file!"; exit 1; fi;
RUN tar -zxf dokuwiki.tgz
RUN mv "/dokuwiki-$DOKUWIKI_VERSION" /dokuwiki

# Set up ownership
RUN chown -R www-data:www-data /dokuwiki

# Cleanup
RUN rm dokuwiki.tgz

# Configure lighttpd
ADD dokuwiki.conf /etc/lighttpd/conf-available/20-dokuwiki.conf
RUN lighty-enable-mod dokuwiki fastcgi accesslog
RUN mkdir /var/run/lighttpd && chown www-data.www-data /var/run/lighttpd

EXPOSE 80
VOLUME ["/dokuwiki/data","/dokuwiki/lib/plugins","/dokuwiki/conf","/dokuwiki/lib/tpl","/var/log"]

ENTRYPOINT ["/usr/sbin/lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
