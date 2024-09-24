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
pot mount-in \
  -p $POT_NAME \
  -d "$(pwd)" \
  -m /website

# Copy init shell
pot copy-in \
  -p $POT_NAME \
  -s pot_init.sh \
  -d /pot_init.sh

pot run $POT_NAME

pot exec -p $POT_NAME sh /pot_init.sh

pot set-cmd -p $POT_NAME -c "cd /website && ruby src/main.rb"

pot stop $POT_NAME

pot snap -p $POT_NAME -r
