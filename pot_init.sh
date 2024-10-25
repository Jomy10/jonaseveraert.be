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

pw useradd \
    website \
    -d /website \
    -m

cd /website
gem install pkg-config bundler cgi
bundler install
# bun install --> bun does not work on FreeBSD yet
npm install

pkg delete -y npm curl
pkg clean -y
