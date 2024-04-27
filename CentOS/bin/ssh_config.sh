#!/bin/bash
if [ `getent group ssh-uzer` ]; then
  echo "Group ssh-uzer already exists. Good..."
else
  /usr/sbin/groupadd ssh-uzer
fi
# If 1st time copy original config
if [ ! -f /etc/ssh/sshd_config.orig ]; then
  cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
fi
#
rm -f /tmp/sshd_configA.tmp
rm -f /tmp/sshd_configB.tmp
# Remove specific configuration entries from sshd config
# and add our own configured entries
grep -v "AllowGroups" /etc/ssh/sshd_config > /tmp/sshd_configA.tmp
grep -v "PermitRootLogin" /tmp/sshd_configA.tmp > /tmp/sshd_configB.tmp
grep -v "PubkeyAuthentication" /tmp/sshd_configB.tmp > /tmp/sshd_configA.tmp
grep -v "PasswordAuthentication" /tmp/sshd_configA.tmp > /tmp/sshd_configB.tmp
grep -v "ChallengeResponseAuthentication" /tmp/sshd_configB.tmp > /tmp/sshd_configA.tmp
grep -v "GSSAPIAuthentication" /tmp/sshd_configA.tmp > /tmp/sshd_configB.tmp
grep -v "UseDNS" /tmp/sshd_configB.tmp > /tmp/sshd_configA.tmp
#
# Put our config at the bottom
cat ../etc/ssh/sshd_config >> /tmp/sshd_configA.tmp
# move current config to safe spot
TDAY=`date "+%Y%m%d-%s"`
mv -f /etc/ssh/sshd_config /etc/ssh/sshd_config.$TDAY
mv -f /tmp/sshd_configA.tmp /etc/ssh/sshd_config
# restart
systemctl restart sshd
systemctl status sshd --no-pager
#
