#!/bin/bash

set -ex
source $(dirname $0)/provision-config.sh

# Setup hosts file to support ping by hostname to each minion in the cluster from apiserver
minion_ip_array=(${MINION_IPS//,/ })
for (( i=0; i<${#MINION_NAMES[@]}; i++)); do
  minion=${MINION_NAMES[$i]}
  ip=${minion_ip_array[$i]}
  if [ ! "$(cat /etc/hosts | grep $minion)" ]; then
    echo "Adding $minion to hosts file"
    echo "$ip $minion" >> /etc/hosts
  fi
done

#yum update -y
yum install -y docker-io git golang e2fsprogs hg openvswitch net-tools bridge-utils

# Build openshift
echo "Building openshift"
pushd /vagrant
  ./hack/build-go.sh
popd
