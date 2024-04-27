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
rm -f /tmp/ewt_sshdA.tmp
rm -f /tmp/ewt_sshdB.tmp
# Remove specific configuration entries from sshd config
# and add our own configured entries
grep -v "AllowGroups" /etc/ssh/sshd_config > /tmp/ewt_sshdA.tmp
grep -v "PermitRootLogin" /tmp/ewt_sshdA.tmp > /tmp/ewt_sshdB.tmp
grep -v "PubkeyAuthentication" /tmp/ewt_sshdB.tmp > /tmp/ewt_sshdA.tmp
grep -v "PasswordAuthentication" /tmp/ewt_sshdA.tmp > /tmp/ewt_sshdB.tmp
grep -v "ChallengeResponseAuthentication" /tmp/ewt_sshdB.tmp > /tmp/ewt_sshdA.tmp
grep -v "GSSAPIAuthentication" /tmp/ewt_sshdA.tmp > /tmp/ewt_sshdB.tmp
grep -v "UseDNS" /tmp/ewt_sshdB.tmp > /tmp/ewt_sshdA.tmp
#
# Put our config at the bottom
cat /root/config/etc/ssh/sshd_config >> /tmp/ewt_sshdA.tmp
# move current config to safe spot
TDAY=`date "+%Y%m%d-%s"`
mv -f /etc/ssh/sshd_config /etc/ssh/sshd_config.$TDAY
mv -f /tmp/ewt_sshdA.tmp /etc/ssh/sshd_config
# restart
systemctl restart sshd
systemctl status sshd --no-pager
#
