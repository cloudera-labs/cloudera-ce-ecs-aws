<!-- Copyright 2026 Cloudera, Inc.

     Licensed under the Apache License, Version 2.0 (the "License");
     you may not use this file except in compliance with the License.
     You may obtain a copy of the License at

         https://www.apache.org/licenses/LICENSE-2.0

     Unless required by applicable law or agreed to in writing, software
     distributed under the License is distributed on an "AS IS" BASIS,
     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     See the License for the specific language governing permissions and
     limitations under the License. -->

# Clusters

After deploying infrastructure, services, and Cloudera Manager, deploy the base cluster followed by the ECS cluster.

## Ozone Base Cluster

The Ozone Base Cluster provides the foundational CDP Private Cloud Base services required by the ECS experience cluster.

### Run

```bash
ansible-navigator run playbooks/ozone-cluster.yml -e @config.yml
```

### Playbook Steps

1. **Host Service Prerequisites** — creates required system users/groups on base cluster hosts
2. **Database Configuration** — provisions Ranger, Hive, and Knox databases in PostgreSQL
3. **Reverse Proxy** — configures the Knox reverse proxy entry in Caddy
4. **CSD/Parcel Management** — downloads Custom Service Descriptors and activates CDH parcels
5. **Cluster Provisioning & Service Configuration** — establishes the cluster, registers hosts, and configures services in dependency order
6. **Host Role Topology Setup** — defines host templates and assigns roles to specific nodes
7. **Cluster Initialization & Startup** — performs first-run execution, restarts stale services, and validates health

### Tags

| Tag | Purpose |
|-----|---------|
| `prereqs` | Host service prerequisites |
| `databases` | PostgreSQL database creation |
| `reverse_proxy` | Knox reverse proxy setup |
| `csds` | CSD and parcel configuration |
| `cluster` | All cluster provisioning tasks |
| `hosts` | Host registration |
| `parcels` | Parcel activation |
| `services` | Service configuration |
| `host_template` | Host template and role assignment |
| `state` | Cluster startup and state management |

### Core Services

ZooKeeper, HDFS, Ozone, YARN, Kafka, HBase, Solr, Ranger, Atlas, Hive, Hive-on-Tez, Tez, Knox

### Host Template Distribution

| Template | Roles |
|----------|-------|
| **SDX** | Atlas Server, HDFS Balancer, Hive Gateway, Knox Gateway, Ozone Gateway, Ozone Recon, S3 Gateway, Ranger (Admin/UserSync/TagSync), Tez Gateway |
| **Master1** | HBase Master, HDFS NameNode, Ozone Manager, Storage Container Manager, ZooKeeper Server |
| **Master2** | HBase Master, Ozone Manager, Storage Container Manager, YARN ResourceManager/JobHistory, ZooKeeper Server |
| **Master3** | HBase Master, HDFS Secondary NameNode, Hive Metastore, HiveServer2, Ozone Manager, Storage Container Manager, Solr Server, ZooKeeper Server, Kafka KRaft |
| **Workers** | HBase RegionServers, HDFS DataNodes, Kafka Brokers, Ozone DataNodes, YARN NodeManagers |

## ECS Cluster

The ECS (Embedded Container Service) Cluster deploys the CDP Private Cloud Data Services control plane on top of the Ozone Base Cluster.

### Run

```bash
ansible-navigator run playbooks/ecs-cluster.yml -e @config.yml
```

### Playbook Steps

1. **Password Validation** — asserts `cloudera_ecs_admin_password` meets complexity requirements
2. **Parcel Configuration** — appends ECS parcel repository to Cloudera Manager
3. **Cluster Provisioning** — creates the ECS experience cluster and registers ECS hosts
4. **Parcel Activation** — activates ECS parcels on the cluster
5. **Service Configuration** — establishes Docker and ECS services with host templates
6. **Host Role Assignment** — assigns ECSMaster and ECSWorker templates to hosts
7. **Control Plane Installation** — installs the CDP control plane with embedded database and vault
8. **Ingress Certificate** — patches the ECS service config with the Caddy ingress certificate (when using self-signed TLS)
9. **CoreDNS Patching** — updates the CoreDNS configmap to use sequential DNS forwarding policy
10. **Prometheus Ingress Patching** — disables SSL redirect on Prometheus ingresses (Caddy handles TLS termination)

### Tags

| Tag | Purpose |
|-----|---------|
| `cluster` | All cluster provisioning tasks |
| `hosts` | Host registration |
| `parcels` | Parcel activation |
| `services` | Service configuration (Docker, ECS) |
| `host_template` | Host template and role assignment |
| `coredns` | CoreDNS and Prometheus ingress patching |

### Services

| Service | Purpose |
|---------|---------|
| Docker | Container runtime on all ECS hosts |
| ECS | Embedded Container Service (control plane, Kubernetes, Longhorn storage) |

### Host Template Distribution

| Template | Roles |
|----------|-------|
| **ECSMaster** | Docker Server, ECS Server |
| **ECSWorker** | Docker Server, ECS Agent |

### After Completion

Once the ECS cluster playbook finishes:

- The CDP Private Cloud Data Services console is accessible at `https://console-cdp.apps.ecs.<gateway_ip>.<public_domain>`
- Default admin credentials: `admin` / `<cloudera_ecs_admin_password>`
- The base Ozone cluster serves as the datalake for Data Services

## Runtime

The Ozone Base Cluster deployment takes approximately **10–20 minutes**. The ECS Cluster deployment takes approximately **30–60 minutes**, the majority of which is the control plane installation.

!!! tip
    Both cluster playbooks are idempotent — running them again will not modify an already-configured cluster.
