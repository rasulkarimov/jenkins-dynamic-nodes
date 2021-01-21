FROM centos:latest

RUN yum install httpd -y
RUN rm -f /var/www/html/index.html
COPY index.html /var/www/html/

CMD /usr/sbin/httpd -DFOREGROUND && /bin/bash
EXPOSE 80
