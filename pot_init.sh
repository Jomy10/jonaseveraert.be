# used by pot.sh

set -x
set -e

[ -w /etc/pkg/FreeBSD.conf ] && sed -i '' 's/quarterly/latest/' /etc/pkg/FreeBSD.conf
ASSUME_ALWAYS_YES=yes pkg bootstrap
touch /etc/rc.conf
sysrc sendmail_enable="NONE"

#########################

pkg install -y \
  sqlite3 \
  ruby \
  curl \
  bash \
  devel/ruby-gems \
  pkgconf \
  npm

pkg clean -y

cd /website
gem install pkg-config
gem install bundler
bundler install
# bun install --> bun does not work on FreeBSD yet
npm install
ruby init.rb
