#!/bin/bash

# load ip.txt
TARGET_IPS=$(cat ip.txt)
LOCAL_IP="192.168.0."
COUNTER=2

# loop through each ip
for ip in $TARGET_IPS; do
  # ssh into each ip and run the following command
  ssh -o StrictHostKeyChecking=no -i ~/.ssh/github-ssh ubuntu@$ip "sudo rm /etc/netplan/01-netcfg.yaml && sudo touch /etc/netplan/01-netcfg.yaml && sudo chmod 666 /etc/netplan/01-netcfg.yaml"
  TEMPLATE=$(
    cat <<EOF
network:
  version: 2
  ethernets:
    ens4:
      dhcp4: 'no'
      dhcp6: 'no'
      addresses:
        - $LOCAL_IP$COUNTER/24
EOF
  )
  echo "$TEMPLATE" | ssh -o StrictHostKeyChecking=no -i ~/.ssh/github-ssh ubuntu@$ip "sudo tee -a /etc/netplan/01-netcfg.yaml"
  ssh -o StrictHostKeyChecking=no -i ~/.ssh/github-ssh ubuntu@$ip "sudo netplan apply"
  COUNTER=$((COUNTER + 1))
done
