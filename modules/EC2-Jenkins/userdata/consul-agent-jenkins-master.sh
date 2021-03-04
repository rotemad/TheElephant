#!/bin/bash
#Jenkins Install
apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io git openjdk-8-jdk -y
usermod -aG docker ubuntu
mkdir -p /home/ubuntu/jenkins_home
chown -R ubuntu:ubuntu /home/ubuntu/jenkins_home
systemctl enable docker
systemctl start docker
docker run -d --restart=always -p 8080:8080 -p 50000:50000 -v /home/ubuntu/jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock --env JAVA_OPTS="-Djenkins.install.runSetupWizard=false" jenkins/jenkins
docker exec -it `docker ps -q` /usr/local/bin/install-plugins.sh github workflow-aggregator docker build-monitor-plugin greenballs
docker restart `docker ps -q`

#Consul agent install
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update
apt-get install consul dnsmasq -y

cat << EOF >/etc/dnsmasq.d/10-consul
# Enable forward lookup of the 'consul' domain:
server=/consul/127.0.0.1#8600
EOF

systemctl restart dnsmasq

cat << EOF >/etc/systemd/resolved.conf
[Resolve]
DNS=127.0.0.1
Domains=~consul
EOF

systemctl restart systemd-resolved.service


useradd consul
mkdir --parents /etc/consul.d
chown --recursive consul:consul /etc/consul.d

IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
cat << EOF > /etc/consul.d/agent_config.json
{
  "advertise_addr": "$IP",
  "client_addr": "0.0.0.0",
  "data_dir": "/opt/consul",
  "datacenter": "opsschool",
  "encrypt": "jrlBUPF89ipG6nVorTPL5zYy92/jGn4jWpSeX3zcAy8=",
  "disable_remote_exec": true,
  "disable_update_check": true,
  "leave_on_terminate": true,
  "retry_join": ["provider=aws tag_key=consul-server tag_value=true"],
  "enable_script_checks": true,
  "server": false
}
EOF
chown --recursive consul:consul /etc/consul.d/agent_config.json
chmod 640 /etc/consul.d/agent_config.json

touch /usr/lib/systemd/system/consul.service
cat << EOF > /usr/lib/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl
[Service]
Type=notify
User=consul
Group=consul
ExecStart=/usr/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF

cat << EOF >/etc/consul.d/jenkins-worker.json
{
  "service": {
    "name": "Jenkins-Master",
    "tags": [
      "jenkins-master"
    ],
    "port": 8080,
    "check": {
      "args": [
        "curl",
        "localhost"
      ],
      "interval": "10s"
    }
  }
}
EOF

systemctl daemon-reload
systemctl enable consul
systemctl start consul

#Node Exporter
node_exporter_ver="0.18.0"

wget \
  https://github.com/prometheus/node_exporter/releases/download/v$node_exporter_ver/node_exporter-$node_exporter_ver.linux-amd64.tar.gz \
  -O /tmp/node_exporter-$node_exporter_ver.linux-amd64.tar.gz

tar zxvf /tmp/node_exporter-$node_exporter_ver.linux-amd64.tar.gz

cp ./node_exporter-$node_exporter_ver.linux-amd64/node_exporter /usr/local/bin

useradd --no-create-home --shell /bin/false node_exporter

chown node_exporter:node_exporter /usr/local/bin/node_exporter

mkdir -p /var/lib/node_exporter/textfile_collector
chown node_exporter:node_exporter /var/lib/node_exporter
chown node_exporter:node_exporter /var/lib/node_exporter/textfile_collector

tee /etc/systemd/system/node_exporter.service &>/dev/null << EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --collector.textfile.directory /var/lib/node_exporter/textfile_collector \
 --no-collector.infiniband
[Install]
WantedBy=multi-user.target
EOF

rm -rf /tmp/node_exporter-$node_exporter_ver.linux-amd64.tar.gz \
  ./node_exporter-$node_exporter_ver.linux-amd64

systemctl daemon-reload
systemctl start node_exporter
status --no-pager node_exporter
systemctl enable node_exporter