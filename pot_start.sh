# Ran at boot

POT_NAME=website

exitfn() {
  trap SIGINT
  pot stop $POT_NAME
  exit
}

# Revert to fresh version of the pot, removing any temp files etc
pot revert -p $POT_NAME

trap "exitfn" INT

pot start $POT_NAME

trap SIGINT # restore signal hendling
