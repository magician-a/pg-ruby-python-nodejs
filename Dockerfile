
FROM ubuntu:14.04
MAINTAINER Oleksandr Roman <oleksandr.roman@perfectial.com>

RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

### Update the base image
RUN apt-get update && apt-get dist-upgrade -qy
RUN apt-get install -y curl vim htop wget supervisor build-essential  pwgen
ADD /tripod-projects /root/tripod-projects

RUN apt-get install -y python2.7 python2.7-dev python-setuptools python-pip git libjpeg8-dev python-imaging

### Install RVM
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN \curl -sSL https://get.rvm.io | bash -s stable
RUN echo 'source /etc/profile.d/rvm.sh' >> ~/.bashrc
RUN /usr/local/rvm/bin/rvm-shell -c "rvm requirements"

### Install Ruby 2.2.1
RUN /usr/local/rvm/bin/rvm-shell -c "rvm autolibs enable"
RUN /usr/local/rvm/bin/rvm-shell -c "rvm install 2.2.1"

### Install wkhtmltopdf
RUN apt-get install xvfb -y
RUN wget http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb
RUN apt-get -f install
RUN apt-get install fontconfig libfontconfig1 libjpeg-turbo8 libxrender1 xfonts-75dpi -y
RUN dpkg -i wkhtmltox-0.12.2.1_linux-trusty-amd64.deb
RUN echo 'xvfb-run --server-args="-screen 0, 1024x768x24" /usr/bin/wkhtmltopdf $*' > /usr/bin/wkhtmltopdf.sh
RUN chmod a+rx /usr/bin/wkhtmltopdf.sh
#RUN ln -s /usr/bin/wkhtmltopdf.sh /usr/local/bin/wkhtmltopdf

### CSVEdit
RUN wget -O - https://www.clazzes.org/gpg/pba-archiver.clazzes.org.asc | apt-key add -
RUN apt-key update
RUN wget --directory-prefix=/etc/apt/sources.list.d/ http://deb.clazzes.org/debian/sources.list.d/squeeze/squeeze-csvedit-1.list
RUN apt-get update
RUN apt-get install -y csvedit


### Install nodejs npm
RUN curl -sL https://deb.nodesource.com/setup_4.x |  bash -
RUN apt-get install -y nodejs
RUN npm update -g
RUN npm install -g bower
RUN npm install -g yo
RUN npm install -g grunt
RUN npm install -g grunt-cli


RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q postgresql-9.3 postgresql-contrib-9.3 postgresql-9.3-postgis-2.1 libpq-dev sudo

# /etc/ssl/private can't be accessed from within container for some reason
# (@andrewgodwin says it's something AUFS related)
RUN mkdir /etc/ssl/private-copy; mv /etc/ssl/private/* /etc/ssl/private-copy/; rm -r /etc/ssl/private; mv /etc/ssl/private-copy /etc/ssl/private; chmod -R 0700 /etc/ssl/private; chown -R postgres /etc/ssl/private

ADD postgresql.conf /etc/postgresql/9.3/main/postgresql.conf
ADD pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf
RUN chown postgres:postgres /etc/postgresql/9.3/main/*.conf
ADD run /usr/local/bin/run
RUN chmod +x /usr/local/bin/run

VOLUME ["/var/lib/postgresql"]


EXPOSE 5432
#ENTRYPOINT  ["/usr/local/bin/run "]

#ENTRYPOINT ["/bin/bash", "/scripts/run.sh"]
#CMD [""]
CMD /usr/local/bin/run &

# Install RabbitMQ 3.5
RUN cd /tmp && \
    wget http://www.rabbitmq.com/rabbitmq-signing-key-public.asc && \
    apt-key add rabbitmq-signing-key-public.asc && \
    echo "deb http://www.rabbitmq.com/debian/ testing main" | tee /etc/apt/sources.list.d/rabbitmq.list && \
    apt-get update && \
    apt-get install -y --force-yes rabbitmq-server && \
    rabbitmq-plugins enable rabbitmq_management && \
    service rabbitmq-server stop && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD  service rabbitmq-server start

### Install Redis
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C7917B12
RUN echo "deb http://ppa.launchpad.net/chris-lea/redis-server/ubuntu trusty main" | sudo tee /etc/apt/sources.list.d/redis.list
RUN apt-get update && apt-get -y install redis-server
EXPOSE      6379
#ENTRYPOINT  ["/usr/bin/redis-server"]
CMD /usr/bin/redis-server


# Add scripts
ADD scripts /scripts
RUN chmod +x /scripts/*.sh
RUN touch /.firstrun

# Command to run
ENTRYPOINT ["/scripts/run.sh"]
CMD [""]

# Expose listen port
EXPOSE 5672
EXPOSE 15672

# Expose our log volumes
VOLUME ["/var/log/rabbitmq"]

RUN pip install celery
RUN which celery
RUN celery --version


