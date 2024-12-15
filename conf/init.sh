#!/bin/bash

## export all "podman -e foo=bar" variables passed to systemd
export $(xargs -0 -a "/proc/1/environ")

chown -R user:user /downloads

#if the user didn't provide an environment then use default values:
ARIA_AGENT="${ARIA_AGENT:-transmission}"
ARIA_SECRET="${ARIA_SECRET:-changeme}"

sed -i -e "s#\$ARIA_AGENT#${ARIA_AGENT}#g" -e "s#\$ARIA_SECRET#${ARIA_SECRET}#g" /home/user/aria/aria2.conf

##... other boot stuff
