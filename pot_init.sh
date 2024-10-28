# used by pot.sh

set -x
set -e

[ -w /etc/pkg/FreeBSD.conf ] && sed -i '' 's/quarterly/latest/' /etc/pkg/FreeBSD.conf
ASSUME_ALWAYS_YES=yes pkg bootstrap
touch /etc/rc.conf
sysrc sendmail_enable="NONE"

#########################

pkg install -y \
  ruby \
  curl \
  devel/ruby-gems \
  pkgconf \
  npm \
  ImageMagick7 \
  postgresql16-client

cd /website
gem install pkg-config bundler cgi
bundler install
# bun install --> bun does not work on FreeBSD yet
npm install

cd /
cat > start_server.sh <<SH
cd /website
PGPASSWORD=$1 APP_ENV=production /usr/local/bin/ruby src/main.rb
SH

echo "APP_ENV=production" >> "/root/.shrc"

pkg delete -y npm curl
pkg clean -y
