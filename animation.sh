#! /bin/bash

#################################################################################
## ISSUE DATE 2019/05/30
## VERSION    v3.0.1
## DESCRIPTION    RUN ANIMATION
## USAGE      ./animation.sh
## SEE https://unix.stackexchange.com/questions/225179/display-spinner-while-waiting-for-some-process-to-finish
## @TROUBLESHOOTING:
## `zsh: ./animation.sh: bad interpreter: /bin/bash^M: no such file or directory`
## For `MAC`: `perl -i -pe 'y|\r||d' ./animation.sh`
#################################################################################
# MAIN SCRIPT
#################################################################################
NUM=1
SP="/-\|"
echo -n ' '
while [ -d /proc/$PPID ]
do
  printf "\b${SP:NUM++%${#SP}:1}"
done
#################################################################################
exit 0
#################################################################################

