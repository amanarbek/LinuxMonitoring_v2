#!/usr/bin/env bash
### https://mcs.mail.ru/docs/additionals/cases/cases-monitoring/case-node-exporter
### Установка Prometheus
apt update
export VERSION="2.38.0"
groupadd --system prometheus
useradd --system -g prometheus -s /bin/false prometheus
apt install -y wget tar
wget https://github.com/prometheus/prometheus/releases/download/v$VERSION/prometheus-$VERSION.linux-amd64.tar.gz -O - | tar -xzv -C /tmp
mkdir /etc/prometheus
mkdir /var/lib/prometheus
cp /tmp/prometheus-$VERSION.linux-amd64/prometheus /usr/local/bin
cp /tmp/prometheus-$VERSION.linux-amd64/promtool /usr/local/bin
cp -r "/tmp/prometheus-$VERSION.linux-amd64/console"* /etc/prometheus
rm -rf /tmp/prometheus-$VERSION.linux-amd64
###
echo -e "global:
  scrape_interval:     10s
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']" > /etc/prometheus/prometheus.yml
###
chown -R prometheus:prometheus /var/lib/prometheus /etc/prometheus
chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool
###
echo -e "[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries
ExecReload=/bin/kill -HUP \$MAINPID
[Install]
WantedBy=default.target" > /etc/systemd/system/prometheus.service
###
systemctl daemon-reload
systemctl start prometheus.service
systemctl enable prometheus.service
# systemctl status prometheus.service
### Установка Node_exporter
export VERSION="1.3.1"
wget  https://github.com/prometheus/node_exporter/releases/download/v$VERSION/node_exporter-$VERSION.linux-amd64.tar.gz -O - | tar -xzv -C /tmp
cp  /tmp/node_exporter-$VERSION.linux-amd64/node_exporter /usr/local/bin
chown -R prometheus:prometheus /usr/local/bin/node_exporter
###
echo -e "[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
Type=simple
Restart=always
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/node_exporter.service
###
systemctl daemon-reload
systemctl start node_exporter.service
systemctl enable node_exporter.service
# systemctl status node_exporter.service
###
echo -e "  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']" >> /etc/prometheus/prometheus.yml
###
systemctl reload prometheus.service
### Установка Grafana
apt-get install -y software-properties-common wget apt-transport-https
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
apt-get update && apt-get -y install grafana
systemctl start grafana-server.service
systemctl enable grafana-server.service
# systemctl status grafana-server.service
