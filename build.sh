podman build \
  -t website \
  --network=host \
  --volume /root/data/jonaseveraert.be/images:/website/assets/images \
  .
