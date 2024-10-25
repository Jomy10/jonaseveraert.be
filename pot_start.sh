# Ran at boot

POT_NAME=website

# Revert to fresh version of the pot, removing any temp files etc
pot revert -p $POT_NAME

pot start $POT_NAME
pot stop $POT_NAME
