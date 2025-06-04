#!/bin/bash

set -euxo pipefail

sudo sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 systemd.unified_cgroup_hierarchy=1"/' /etc/default/grub

sudo update-grub

if [ $? -eq 0 ]; then
  echo "The grub has updated the cgroups into v2"
else
  echo "The upgrate was fail, please check"
  exit 1
fi
