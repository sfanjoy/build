#!/bin/bash
if [ `getent group ssh-uzer` ]; then
  echo "Group ssh-uzer already exists...Good"
else
  /usr/sbin/groupadd ssh-uzer
fi
#
uinfo=`getent passwd sfanjoy`
#
if [[ ${#uinfo} -gt 0 ]]; then
  echo "User sfanjoy already exists...Good"
  exit
fi
echo "Adding User sfanjoy..."
/usr/sbin/useradd -s /bin/bash sfanjoy
echo "Setting sfanjoy password..."
passwd sfanjoy
/usr/sbin/usermod -a -G ssh-uzer sfanjoy
mkdir -p /home/sfanjoy/bin
mkdir -p /home/sfanjoy/rpms
chown -R sfanjoy:sfanjoy /home/sfanjoy
echo "User sfanjoy Configured"
