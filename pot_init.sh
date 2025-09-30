# used by pot_build.sh

set -xe

[ -w /etc/pkg/FreeBSD.conf ] && sed -i '' 's/quarterly/latest/' /etc/pkg/FreeBSD.conf
ASSUME_ALWAYS_YES=yes pkg bootstrap
touch /etc/rc.conf
sysrc sendmail_enable="NONE"

pkg install -y \
  npm \
  postgresql16-client

cd /website
npm i
ASTRO_DB_REMOTE_URL="libsql://postgres:$1@localhost:5432/website" \
  npm run build --port 6000

cd /
cat > start_server.sh <<SH
cd /website
node ./dist/server/entry.mjs
SH

pkg clean -y
