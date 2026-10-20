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

# Data Services

Once the [ECS cluster](clusters.md#ecs-cluster) and its Control Plane are running, you can optionally provision Cloudera data services. These are not part of the core deployment stages — each service has its own dedicated playbook that you run on demand.

| Service | Playbook |
|---------|----------|
| Cloudera AI Workbench | `cai-workbench.yml` |
| Cloudera Data Engineering | `cde-service.yml` |
| Cloudera Data Warehouse | `cdw-service.yml` |

!!! warning "One data service at a time"
    The default ECS cluster (1 ECS Master, 3 ECS Workers) is sized to run **only one data service at a time**. To run multiple data services concurrently, increase the number of ECS Worker nodes by raising the `quantity` of the `ecs_workers` module in `tf_cluster_aws/hosts_ecs.tf` before running the infrastructure playbook. See [Customizing Node Sizing](infrastructure.md#customizing-node-sizing).

## Prerequisites

The data service playbooks authenticate against the ECS Control Plane APIs, so you must first generate Control Plane credentials and make them available to the Execution Environment.

1. Log in to the Control Plane UI at `https://console-cdp.apps.ecs.<gateway_ip>.<public_domain>`
2. Go to your **User Profile**
3. Generate an **Access Key** and **Private Key**
4. Export the keys and the Control Plane endpoint URL as environment variables:

    ```bash
    export CDP_ACCESS_KEY_ID=<ACCESS_KEY_ID_FROM_ECS_CONTROL_PLANE>
    export CDP_PRIVATE_KEY=<PRIVATE_KEY_FROM_ECS_CONTROL_PLANE>
    export CDP_ENDPOINT_URL=https://console-cdp.apps.ecs.<gateway_ip>.<public_domain>
    ```

5. Uncomment the CDP variables in the `environment-variables.pass` list of `ansible-navigator.yml` so they are passed through to the Execution Environment:

    ```yaml
    environment-variables:
      pass:
        # ...
        - CDP_ACCESS_KEY_ID
        - CDP_PRIVATE_KEY
        - CDP_ENDPOINT_URL
    ```

!!! warning
    Treat the Control Plane access keys as secrets — do not commit them to the repository.

## Cloudera AI Workbench

### Run

```bash
ansible-navigator run playbooks/cai-workbench.yml -e @config.yml
```

### Playbook Steps

1. **Workbench Creation** — creates the `<name_prefix>-ml` Cloudera AI workspace with governance and metrics enabled
2. **Reverse Proxy** — configures a Caddy entry for wildcard domain access to the workbench
3. **TLS Certificate** — generates a wildcard TLS certificate for the workbench domain via FreeIPA
4. **Kubernetes Secret** — creates the TLS secret used by the workbench ingress

## Cloudera Data Engineering

### Run

```bash
ansible-navigator run playbooks/cde-service.yml -e @config.yml
```

### Playbook Steps

1. **LDAP Provider** — uploads the FreeIPA CA certificate to the Control Plane LDAP provider
2. **Service Enablement** — enables the `<name_prefix>-de` Data Engineering service in the ECS environment
3. **Reverse Proxy** — configures a Caddy entry for service access
4. **TLS Certificate** — generates a wildcard TLS certificate for the service domain via FreeIPA

## Cloudera Data Warehouse

### Run

```bash
ansible-navigator run playbooks/cdw-service.yml -e @config.yml
```

### Playbook Steps

1. **LDAP Provider** — uploads the FreeIPA CA certificate to the Control Plane LDAP provider
2. **Cluster Creation** — creates the Data Warehouse cluster in the ECS environment
3. **Database Catalog** — waits for the default Database Catalog to reach the `Running` state

!!! note
    Virtual Warehouses (Impala, Hive) are not created by the playbook. Create them from the Data Warehouse UI once the Database Catalog is running.
