#!/bin/bash
set -ex
source $(dirname $0)/provision-config.sh

MINION_IP=$4

# Setup hosts file to support ping by hostname to master
if [ ! "$(cat /etc/hosts | grep $MASTER_NAME)" ]; then
  echo "Adding $MASTER_NAME to hosts file"
  echo "$MASTER_IP $MASTER_NAME" >> /etc/hosts
fi

# Setup hosts file to support ping by hostname to each minion in the cluster
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
  cp _output/go/bin/openshift /usr/bin
popd

# run the networking setup
$(dirname $0)/provision-network.sh $@

# create service and start the node
cat <<EOF > /etc/sysconfig/openshift
OPENSHIFT_MASTER=$MASTER_IP
OPENSHIFT_BIND_ADDR=$MINION_IP
EOF

cat <<EOF > /usr/lib/systemd/system/openshift-node.service
[Unit]
Description=openshift node

[Service]
EnvironmentFile=-/etc/sysconfig/openshift
ExecStart=/usr/bin/openshift start

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable openshift-node.service
systemctl start openshift-node.service

# Register with the master
curl -X POST -H 'Accept: application/json' -d "{\"kind\":\"Minion\", \"id\":"${MINION_IP}", \"apiVersion\":\"v1beta1\", \"hostIP\":"${MINION_IP}" }" http://${MASTER_IP}:8080/api/v1beta1/minions
