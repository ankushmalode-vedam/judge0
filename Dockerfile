#FROM judge0/compilers:1.4.0 AS production
FROM ankushvedam/judge0-compilers:929337457fed1364286400b1e33e8dde5392f842 AS production

ENV JUDGE0_HOMEPAGE "https://judge0.com"
LABEL homepage=$JUDGE0_HOMEPAGE

ENV JUDGE0_SOURCE_CODE "https://github.com/judge0/judge0"
LABEL source_code=$JUDGE0_SOURCE_CODE

ENV JUDGE0_MAINTAINER "Herman Zvonimir Došilović <hermanz.dosilovic@gmail.com>"
LABEL maintainer=$JUDGE0_MAINTAINER

#ENV PATH "/usr/local/ruby-2.7.0/bin:/opt/.gem/bin:$PATH"
#ENV PATH "/usr/local/ruby-3.3.8/bin:/opt/.gem/bin:$PATH"
ENV GEM_HOME "/opt/.gem/"
ENV PATH "/usr/local/ruby-2.7.0/bin:$GEM_HOME/bin:$PATH"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      cron \
      libpq-dev \
      sudo \
      nodejs \
      npm && \
    echo "gem: --no-document" > /root/.gemrc && \
    gem install bundler:2.1.4 && \
    npm install -g --unsafe-perm aglio@2.3.0 && \
    rm -rf /var/lib/apt/lists/*

RUN ruby -v && \
    gem -v && \
    bundle _2.1.4_ --version

EXPOSE 2358

WORKDIR /api

COPY Gemfile* ./
RUN RAILS_ENV=production bundle _2.1.4_
#RUN RAILS_ENV=production bundle

COPY cron /etc/cron.d
RUN cat /etc/cron.d/* | crontab -

COPY . .

ENTRYPOINT ["/api/docker-entrypoint.sh"]
CMD ["/api/scripts/server"]

RUN useradd -u 1000 -m -r judge0 && \
    echo "judge0 ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers && \
    chown judge0: /api/tmp/

USER judge0

ENV JUDGE0_VERSION "1.13.1"
LABEL version=$JUDGE0_VERSION


FROM production AS development

CMD ["sleep", "infinity"]
