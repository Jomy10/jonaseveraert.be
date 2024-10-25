FROM localhost/freebsd14.0-small

RUN pkg install -y \
  ruby \
  curl \
  devel/ruby-gems \
  pkgconf \
  npm \
  ImageMagick7 \
  postgresql16-client \
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

RUN pkg delete npm curl
RUN pkg clean -y

ENV APP_ENV=production
CMD ["ruby", "/website/src/main.rb", "--host=https://jonaseveraert.be"]
