#!/bin/bash
# Load Bash Utility Libraries
. ./bash/Hash.sh

# Production Firewall
#
if [ -z "$1" ]; then
        echo "Usage: firewall.sh <command> options";
        echo ""
        echo "    firewall.sh help"
        echo "      * List helpful firewall commands"
        echo ""
        echo "    firewall.sh add-ip <ip>"
        echo "      * Give <ip> access to machine"
        echo ""
        echo "    firewall.sh reset"
        echo "      * Resets the firewall to no access"
        echo ""
        echo ""
        exit
fi
#
if [ $1 == "reset" ]; then
  echo "Resetting firewall..."
  rm -f /etc/firewalld/zones/*
  firewall-cmd --complete-reload
  systemctl restart firewalld
  systemctl status firewalld
# iterate through the default zones
  for zone in drop block public external dmz work home internal trusted nm-shared
  do
#   iterate through default services
      for srv in $(firewall-cmd --list-services --zone=$zone)
      do
        echo "Removing service $srv from $zone"
        firewall-cmd --zone=$zone --remove-service=$srv
        firewall-cmd --zone=$zone --remove-service=$srv --permanent
      done
  done
  firewall-cmd --zone=work --add-service=ssh --permanent
  firewall-cmd --runtime-to-permanent
  firewall-cmd --reload
if [ $1 == "add-ip" ]; then
  firewall-cmd --zone=work --add-source=$2 --permanent
  firewall-cmd --runtime-to-permanent
  firewall-cmd --reload
elif [ $1 == "help" ]; then
  echo "firewall-cmd --list-all-zones"
  echo "firewall-cmd --zone=work --add-source=<ip> --permanent"
  echo "firewall-cmd --zone=work --add-port=7001/tcp --permanent"
  echo "firewall-cmd --zone=work --add-port=7702-8999/udp --permanent"
  echo "firewall-cmd --runtime-to-permanent"
  echo "firewall-cmd --reload"
else
  echo "Unknown command"
fi
echo ""
echo ""
echo "Current Firewall Zones"
echo ""
echo ""
firewall-cmd --list-all-zones --permanent
systemctl restart firewalld
systemctl status firewalld
