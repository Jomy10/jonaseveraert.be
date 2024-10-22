FROM localhost/freebsd14.0-small

RUN pkg install -y \
  ruby \
  curl \
  devel/ruby-gems \
  pkgconf \
  npm \
  git \
  FreeBSD-clang \
  FreeBSD-runtime-dev \
  FreeBSD-utilities-dev \
  FreeBSD-clibs-dev \
  FreeBSD-lld \
  FreeBSD-libcompiler_rt-dev \
  FreeBSD-libmagic-dev

RUN git clone https://github.com/Jomy10/libkeycloak /libkeycloak
WORKDIR /libkeycloak

RUN gem install colorize
RUN ruby build.rb build dynamic
RUN cp build/libkeycloak.so /usr/local/lib/libkeycloak.so

COPY . /website
WORKDIR /website

RUN gem install pkg-config bundler cgi
RUN bundler install
RUN npm install # bun doesn't work on FreeBSD yet
RUN ruby init.rb

RUN pkg uninstall npm curl git
RUN pkg clean -y

CMD ["ruby", "/website/src/main.rb"]
