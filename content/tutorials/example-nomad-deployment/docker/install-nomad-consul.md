---
title: Nomad & Consul
weight: 10
---

## Install the Software

To install Nomad and Consul, run the following commands as **root**:

```shell
# Install Nomad and Consul
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

apt-get update -y
apt-get install -y nomad consul
```

---

### Docker Installation

To install Docker, run the following commands:

```shell
# Install Docker
apt-get update -y
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

---

## Configure and Start Consul

Create the Consul configuration file at `/etc/consul.d/consul.hcl` with the following content:

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

Start and enable Consul:

```shell
systemctl enable consul
systemctl start consul
```

Verify Consul is running by visiting:
**http://knot.getknot.dev:8500**

---

## Configure and Start Nomad

Create the Nomad configuration file at `/etc/nomad.d/nomad.hcl` with the following content:

```hcl {filename="/etc/nomad.d/nomad.hcl"}
datacenter = "dc1"

data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"

plugin_dir = "/opt/nomad/data/plugins/"

consul {
  address = "127.0.0.1:8500"
}

server {
  enabled          = true
  bootstrap_expect = 1
}

client {
  enabled = true

  options = {
    "driver.allowlist" = "docker,exec"
  }
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

Start and enable Nomad:

```shell
systemctl enable nomad
systemctl start nomad
```

Verify Nomad is running by visiting:
**http://knot.getknot.dev:4646**
