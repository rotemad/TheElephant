#!/bin/bash
#Docker install
apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io -y
usermod -aG docker ubuntu
systemctl enable docker
systemctl start docker

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

cat << EOF >/etc/consul.d/prom-grafana.json
{
  "service": {
    "name": "prom-grafana",
    "tags": [
      "monitoring"
    ],
  "checks": [
   {
    "id": "Grafana",
    "name": "Grafana Status",
    "tcp": "localhost:3000",
    "interval": "10s",
    "timeout": "1s"
  },
  {
    "id": "Prometheus",
    "name": "Prometheus Status",
    "tcp": "localhost:9090",
    "interval": "10s",
    "timeout": "1s"
  }
  ]
  }
}
EOF

systemctl daemon-reload
systemctl enable consul
systemctl start consul

#Prom conf
IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
mkdir /etc/prometheus
cat << EOF >/etc/prometheus/prometheus.yml
# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
    - targets: ['localhost:9090']

#  - job_name: 'node_exporter'
#    scrape_interval: 15s
#    static_configs:
#      - targets: 
#        - '172.17.0.1:9100'

  - job_name: 'Consul_service_exporters'
    consul_sd_configs:
      - server: '$IP:8500'
    relabel_configs:
      - source_labels: ['__address__']
        target_label: '__address__'
        regex: '(.*):.*'
        separator: ':'
        replacement: '\$1:9100'
      - source_labels: [__meta_consul_node]
        target_label: instance

  - job_name: 'Consul-server'
    metrics_path: '/v1/agent/metrics'
    consul_sd_configs:
      - server: '$IP:8500'
        services:
          - consul
    relabel_configs:  
      - source_labels: ['__address__']
        target_label: '__address__'
        regex: '(.*):.*'
        separator: ':'
        replacement: '\$1:8500'
EOF

#Grafana install
apt-get install -y apt-transport-https
apt-get install -y software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
apt-get update
apt-get install grafana -y

cat << EOF >/etc/grafana/provisioning/datasources/default.yaml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    url: http://localhost:9090


  - name: Prometheus-k8s
    type: prometheus
    url: http://my-prometheus-server-default.service.opsschool.consul:9090
EOF

sed -i '/# enable anonymous access/a enabled = true' /etc/grafana/grafana.ini
sed -i '/;default_home_dashboard_path/a default_home_dashboard_path = /etc/grafana/provisioning/dashboards/dashboard.json' /etc/grafana/grafana.ini

wget https://grafana.com/api/dashboards/1860/revisions/22/download -O /etc/grafana/provisioning/dashboards/dashboard.json

cat << EOF >/etc/grafana/provisioning/dashboards/default.yaml
apiVersion: 1

providers:
 - name: 'default'
   orgId: 1
   folder: ''
   folderUid: ''
   type: file
   options:
     path: /etc/grafana/provisioning/dashboards
EOF

systemctl enable grafana-server.service
systemctl start grafana-server.service

docker run -d --name=prometheus --restart=unless-stopped -p 9090:9090 -v /etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
#docker run -d --name=grafana --restart=unless-stopped -p 3000:3000 grafana/grafana

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
