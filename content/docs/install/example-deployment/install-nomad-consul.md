---
title: Install Nomad & Consul
weight: 10
---

As root run:

```shell
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

apt-get update
apt-get install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update -y
apt install -y nomad consul docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

mkdir -p /opt/nomad/plugins
cd /opt/nomad/plugins
wget https://releases.hashicorp.com/nomad-driver-podman/0.5.2/nomad-driver-podman_0.5.2_linux_amd64.zip
unzip nomad-driver-podman_0.5.2_linux_amd64.zip
rm nomad-driver-podman_0.5.2_linux_amd64.zip
```

## Configure and Start Consul

```hcl {filename="/etc/consul.d/consul.hcl"}
datacenter = "dc1"

bind_addr = "{{ GetPrivateIP }}"
client_addr = "{{ GetPrivateInterfaces | exclude \"type\" \"ipv6\" | join \"address\" \" \" }} {{ GetAllInterfaces | include \"flags\" \"loopback\" | join \"address\" \" \" }}"
advertise_addr = "{{ GetInterfaceIP \"ens18\"}}"

log_level = "WARN"

data_dir = "/opt/consul"

server = true
bootstrap_expect = 1

ui_config {
  enabled = true
}
```

```shell
systemctl enable consul
systemctl start consul
```

Check consul is running by going to http://knot.getknot.dev:8500

## Configure and Start Nomad

```hcl {filename="/etc/nomad.d/nomad.hcl"}
datacenter = "dc1"

data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"

plugin_dir = "/opt/nomad/plugins/"

consul {
  address = "127.0.0.1:8500"
}

server {
  enabled          = true
  bootstrap_expect = 1
}

client {
  enabled = true
}

plugin "docker" {
  config {
    allow_privileged = true
    allow_caps = [ "ALL" ]
    volumes {
      enabled = true
    }
  }
}
```

```shell
systemctl enable nomad
systemctl start nomad
```

Check nomad is running by going to http://knot.getknot.dev:4646
