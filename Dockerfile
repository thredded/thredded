FROM ruby:2.2.1

ENV APP_HOME /thredded
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD . $APP_HOME

RUN sh -c "echo 'deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main' > /etc/apt/sources.list.d/pgdg.list" && \
  wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -

RUN apt-get update -qq && \
  apt-get install -y build-essential libpq-dev libxml2-dev libxslt1-dev \
  nodejs postgresql-common postgresql-9.4 libpq-dev sudo --fix-missing

RUN sh -c "echo 'local all postgres              peer' > /etc/postgresql/9.4/main/pg_hba.conf" && \
    sh -c "echo 'local all all                   peer' >> /etc/postgresql/9.4/main/pg_hba.conf" && \
    sh -c "echo 'host  all all      ::1/128      trust' >> /etc/postgresql/9.4/main/pg_hba.conf" && \
    sh -c "echo 'host  all all      127.0.0.1/32 trust' >> /etc/postgresql/9.4/main/pg_hba.conf"

RUN echo "UPDATE pg_database SET datistemplate=FALSE WHERE datname='template1';" > utf8.sql; \
  echo "DROP DATABASE template1;" >> utf8.sql; \
  echo "CREATE DATABASE template1 WITH owner=postgres template=template0 encoding='UTF8';" >> utf8.sql; \
  echo "UPDATE pg_database SET datistemplate=TRUE WHERE datname='template1';" >> utf8.sql

RUN service postgresql start && \
  sudo -u postgres createuser root -s && \
  createdb root && \
  psql -a -f utf8.sql && \
  rm utf8.sql && \
  bundle install && \
  rake db:create db:migrate dev:seed && \
  service postgresql stop

EXPOSE 9292

CMD service postgresql start; cd spec/dummy; rails s webrick -p 9292;
