# Create pot

set -x
set -e

POT_NAME=website
FREEBSD_VERSION=14.1

pot create \
  -p $POT_NAME \
  -b $FREEBSD_VERSION \
  -t single

# Copy files
pot copy-in \
  -p $POT_NAME \
  -s "$(pwd)" \
  -d /website

# Mount images folder
pot mount-in \
    -p $POT_NAME \
    -d "/root/data/jonaseveraert.be/images" \
    -m "/webiste/assets/images"

# Copy init shell
pot copy-in \
  -p $POT_NAME \
  -s pot_init.sh \
  -d /pot_init.sh

pot start $POT_NAME

pot exec -p $POT_NAME sh /pot_init.sh

pot set-cmd -p $POT_NAME -c "APP_ENV=production sh -c 'cd /website && ruby src/main.rb'"

pot stop $POT_NAME

pot snap -p $POT_NAME -r
