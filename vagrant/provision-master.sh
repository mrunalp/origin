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

# Install the required packages
yum install -y docker-io git golang e2fsprogs hg net-tools bridge-utils

# Build openshift
echo "Building openshift"
pushd /vagrant
  ./hack/build-go.sh
  cp _output/go/bin/openshift /usr/bin
  ./hack/install-etcd.sh
popd

# Create systemd service
cat <<EOF > /etc/sysconfig/openshift
OPENSHIFT_MASTER=$MASTER_IP
OPENSHIFT_BIND_ADDR=$MASTER_IP
EOF

cat <<EOF > /usr/lib/systemd/system/openshift-master.service
[Unit]
Description=openshift master

[Service]
EnvironmentFile=-/etc/sysconfig/openshift
ExecStart=/usr/bin/openshift start

[Install]
WantedBy=multi-user.target
EOF

# Start the service
systemctl daemon-reload
systemctl enable openshift-master.service
systemctl start openshift-master.service
