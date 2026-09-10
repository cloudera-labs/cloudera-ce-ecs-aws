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

# Services

The services playbook configures all supporting infrastructure services on the provisioned hosts.

## What It Configures

| Service | Host | Purpose |
|---------|------|---------|
| OS & Networking | All hosts | System prerequisites, DNS resolution |
| FreeIPA | Services host | DNS, Kerberos KDC, certificate authority |
| PostgreSQL | Services host | Databases for CM and services |
| pgAdmin | Services host | Database administration UI |
| Caddy | Gateway | Reverse proxy with TLS termination |
| Node Exporter | All hosts | System metrics (when monitoring enabled) |
| Prometheus | Services host | Metrics collection (when monitoring enabled) |
| Grafana | Services host | Metrics dashboards (when monitoring enabled) |

## Run

```bash
ansible-navigator run playbooks/services.yml -e @config.yml
```

## Tags

| Tag | Purpose |
|-----|---------|
| `system` | OS configuration and networking |
| `system_services` | System-level service setup |
| `freeipa` | All FreeIPA tasks |
| `freeipa_server` | FreeIPA server installation |
| `freeipa_client` | FreeIPA client enrollment |
| `database` | PostgreSQL and pgAdmin |
| `pgadmin` | pgAdmin setup |
| `monitoring` | Prometheus, Grafana, Node Exporter |
| `ecs_dns` | ECS DNS record provisioning |

## Feature Toggles

These are controlled via `config.yml` or `group_vars/all.yml`:

| Variable | Default | Effect |
|----------|---------|--------|
| `enable_prometheus` | `true` | Deploys Node Exporter, Prometheus, and Grafana |
| `enable_freeipa_wildcard_profile` | `true` | Creates wildcard certificate profile in FreeIPA |
| `enable_postgres_tls` | `true` | Enrolls PostgreSQL with FreeIPA-signed TLS certs |
| `enable_prereq_freeipa_client` | `true` | Runs prereq_freeipa_client role before enrollment |

## Reverse Proxy Endpoints

After the services playbook completes, the following endpoints are available via the Caddy reverse proxy on the gateway:

- `https://cm.<gateway_ip>.<public_domain>` — Cloudera Manager
- `https://freeipa.<gateway_ip>.<public_domain>` — FreeIPA Web UI
- `https://pgadmin.<gateway_ip>.<public_domain>` — pgAdmin
- `https://knox.<gateway_ip>.<public_domain>` — Knox Gateway

When monitoring is enabled:

- `https://prometheus.<gateway_ip>.<public_domain>` — Prometheus
- `https://grafana.<gateway_ip>.<public_domain>` — Grafana
