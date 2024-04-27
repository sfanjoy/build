#!/bin/bash
# Load Bash Utility Libraries
. ./bash/Hash.sh

# Production Firewall
#
if [ -z "$1" ]; then
        echo "Usage: firewall.sh <command> options";
        echo ""
        echo "    firewall.sh create <internal | external>"
        echo "      * Creates the appropriate firewall for internal or external hosts"
        echo ""
        echo "    firewall.sh reset"
        echo "      * Resets the firewall to no access"
        echo ""
        echo ""
        netstat -i
        exit
fi
#
declare -A ihosts # internal net hosts
declare -A ehosts # external net hosts
declare -a addrs
declare -a exempt

  ehosts["scott"]="73.131.107.183" # Scott Xfinity
  ehosts["lime"]="74.120.51.1"     # Lime Data Center Firewall
  ehosts["lowcountry"]="64.139.69.33"  # Mt Pleasant office Xfinity
  ehosts["ewt02"]="108.61.132.174" # ewt02 Vultr Host
  ehosts["ewt04"]="209.222.0.66" # ewt03 Vultr Host

  ihosts["colo1"]="10.33.64.227"  # Lime Data Center
  ihosts["colo2"]="10.42.55.131"  # Lime Data Center
  ihosts["colo2E"]="10.42.55.0/255.255.255.0" # EzCast
  ihosts["loco4"]="10.22.176.10"   # Lowcountry Data Center Host
  ihosts["loco3"]="10.22.176.11"   # Lowcountry VM on Ripper
  ihosts["loco3E"]="10.22.176.0/28"   # EzCast

if [ $1 == "create" ]; then
  exempt+=`hostname`
  if [ $2 == "internal" ]; then
    except_values ihosts exempt addrs
  elif [ $2 == "external" ]; then
    except_values ehosts exempt addrs
  else
    echo "Bad option"
    exit -1
  fi
  echo "Creating $2 firewall..."

  firewall-cmd --zone=public --set-target=DROP --permanent
  for addr in ${addrs[@]}
  do
    echo "Adding host: $addr"
    firewall-cmd --zone=work --add-source=$addr --permanent
  done

  if [ $2 == "external" ]; then
    echo "No external proprietary open ports yet..."
  elif [ $2 == "internal" ]; then
  # Server ports
    firewall-cmd --zone=work --add-port=7001/tcp --permanent
    firewall-cmd --zone=work --add-port=7031/tcp --permanent
    firewall-cmd --zone=work --add-port=7032/tcp --permanent
    firewall-cmd --zone=work --add-port=7049/tcp --permanent
    firewall-cmd --zone=work --add-port=7052/tcp --permanent
    firewall-cmd --zone=work --add-port=7061/tcp --permanent
  # EzCast Setup
    firewall-cmd --zone=work --add-port=7701/tcp --permanent
    firewall-cmd --zone=work --add-port=7702-8999/udp --permanent
  else
    echo "Unknown command"
    exit -1
  fi
  firewall-cmd --zone=work --add-service=ssh --permanent
  firewall-cmd --reload
elif [ $1 == "reset" ]; then
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
  firewall-cmd --runtime-to-permanent
  firewall-cmd --reload
else
  echo "Unknown command"
fi
#
echo ""
echo ""
echo "Current Firewall Zones"
echo ""
echo ""
firewall-cmd --list-all-zones --permanent
systemctl restart firewalld
systemctl status firewalld
