FROM localhost/freebsd14.0-small

RUN pkg install -y \
  sqlite3 \
  ruby \
  curl \
  bash \
  devel/ruby-gems \
  pkgconf \
  npm \
  FreeBSD-clang \
  FreeBSD-runtime-dev \
  FreeBSD-utilities-dev \
  FreeBSD-clibs-dev \
  FreeBSD-lld \
  FreeBSD-libcompiler_rt-dev \
  FreeBSD-libmagic-dev

COPY . /website
WORKDIR /website

RUN gem install pkg-config bundler cgi
RUN bundler install
RUN npm install # bun doesn't work on FreeBSD yet
RUN ruby init.rb

RUN pkg clean -y

CMD ["ruby", "/website/src/main.rb"]
