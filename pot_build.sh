# Create pot

set -xe

POT_NAME=website
FREEBSD_VERSION=14.2

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
    -d "/images/home" \
    -m "/website/assets/images"

# Copy init shell
pot copy-in \
  -p $POT_NAME \
  -s pot_init.sh \
  -d /pot_init.sh

pot start $POT_NAME

pot exec -p $POT_NAME sh /pot_init.sh

pot set-cmd -p $POT_NAME -c "sh start_server.sh $PGPASSWORD"

pot stop $POT_NAME

pot snap -p $POT_NAME -r
