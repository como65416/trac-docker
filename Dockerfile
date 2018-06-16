FROM ubuntu:18.04

ENV PROJECT_NAME my_project
ENV ADMIN_NAME admin
ENV ADMIN_PASSWORD paSsW0rd
ENV BASE_DIR /var/local/trac
ENV HTPASSWD_PATH $BASE_DIR/.htpasswd
ENV PROJECT_PATH $BASE_DIR/$PROJECT_NAME
ENV DB_LINK sqlite:db/trac.db
EXPOSE 80

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python python-babel python-pip python-setuptools python-dev
RUN pip install Genshi
COPY ./file/Trac-1.2.2.tar.gz /tmp/Trac-1.2.2.tar.gz
RUN cd /tmp && tar zxvf Trac-1.2.2.tar.gz && cd Trac-1.2.2 && python ./setup.py install
RUN mkdir -p $BASE_DIR
RUN trac-admin $PROJECT_PATH initenv $PROJECT_NAME $DB_LINK
RUN apt-get install -y apache2-utils
RUN htpasswd -b -c $BASE_DIR/.htpasswd $ADMIN_NAME $ADMIN_PASSWORD
RUN trac-admin $PROJECT_PATH permission add $ADMIN_NAME TRAC_ADMIN

CMD tracd -p 80 --basic-auth="$PROJECT_NAME,$HTPASSWD_PATH,env" $PROJECT_PATH
