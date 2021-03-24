#!/bin/bash
#Mysql install
apt-get update
apt-get install mysql-common debsums libaio1 libmecab2 gnupg2 wget -y
#wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
#dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
apt-get update
export MYSQL_ROOT_PASSWORD=123456
export DEBIAN_FRONTEND=noninteractive
echo "percona-server-server-5.7 percona-server-server-5.7/root-pass password $MYSQL_ROOT_PASSWORD" | debconf-set-selections
echo "percona-server-server-5.7 percona-server-server-5.7/re-root-pass password $MYSQL_ROOT_PASSWORD" | debconf-set-selections
apt-get install percona-server-server-5.7 -y

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

cat << EOF >/etc/consul.d/mysql.json
{
  "service": {
    "name": "mysql",
    "tags": [
      "db"
    ],
    "port": 22,
    "check": {
      "args": [
        "tcp",
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

# filebeat
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-oss-7.11.0-amd64.deb
dpkg -i filebeat-*.deb

sudo mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.BCK

cat <<\EOF > /etc/filebeat/filebeat.yml
filebeat.modules:
  - module: system
    syslog:
      enabled: true
    auth:
      enabled: false
filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false
setup.dashboards.enabled: false
setup.template.name: "filebeat"
setup.template.pattern: "filebeat-*"
setup.template.settings:
  index.number_of_shards: 1
processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
  - add_cloud_metadata: ~
output.elasticsearch:
  hosts: [ "elk.service.opsschool.consul:9200" ]
  index: "filebeat-%{[agent.version]}-%{+yyyy.MM.dd}"
## OR
#output.logstash:
#  hosts: [ "127.0.0.1:5044" ]
EOF

systemctl enable filebeat.service
systemctl start filebeat.service
