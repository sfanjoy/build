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
else
  echo "Adding User sfanjoy..."
  /usr/sbin/useradd -s /bin/bash sfanjoy
  echo "Setting sfanjoy password..."
  passwd sfanjoy
/usr/sbin/usermod -a -G ssh-uzer sfanjoy
fi
mkdir -p /home/sfanjoy/bin
mkdir -p /home/sfanjoy/rpms
cp ../home/sfanjoy/vimrc /home/sfanjoy/.vimrc
cp ../home/sfanjoy/bashrc /home/sfanjoy/.bashrc
cp ../home/sfanjoy/id_ed25519.pub /home/sfanjoy/.ssh/authorized_keys
chown -R sfanjoy:sfanjoy /home/sfanjoy
echo "User sfanjoy Configured"
