# Ran at boot

POT_NAME=website

pot revert -p $POT_NAME

pot start $POT_NAME
pot stop $POT_NAME
