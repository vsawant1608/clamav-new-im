FROM registry.access.redhat.com/ubi8/nodejs-18:latest

USER root
RUN yum -y update

# copy health check script 
COPY clamd/health/clamdcheck.sh /usr/local/etc/clamdcheck.sh
# see download links here https://www.clamav.net/downloads
RUN yum -y install https://www.clamav.net/downloads/production/clamav-1.1.0.linux.x86_64.rpm
RUN yum -y install nc wget bind-utils iputils
COPY clamd/config/clamd.conf /usr/local/etc/clamd.conf
COPY clamd/config/freshclam.conf /usr/local/etc/freshclam.conf
# add a health check on pod to execute this script
COPY clamd/non-root-start.sh /init
RUN mkdir -p /usr/local/share/clamav /var/log/clamav/
RUN touch /var/log/clamav/freshclam.log
RUN touch /var/log/clamav/clamd.log
RUN chown -R 1001:0 /usr/local/share/clamav /var/log/clamav/ /init /var/log/clamav /usr/local/etc/clamdcheck.sh
RUN chmod -R ug+rwx /usr/local/share/clamav /var/log/clamav/ /init /var/log/clamav /usr/local/etc/clamdcheck.sh
USER 1001
EXPOSE 3310

ENTRYPOINT [ "/init" ]
