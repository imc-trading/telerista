#!/bin/bash
set -ex

mkdir -p /etc/telegraf/telegraf.d/
echo "[global_tags]" > /etc/telegraf/telegraf.d/tags.conf
for tag in ${!TAG_*}; do
  echo " ${tag:4} = \"\${${tag}}\"" >> /etc/telegraf/telegraf.d/tags.conf
done

if [ "${1:0:1}" = '-' ]; then
    set -- telegraf "$@"
fi


exec "$@"
