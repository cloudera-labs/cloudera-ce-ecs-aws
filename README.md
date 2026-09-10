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

# Cloudera On Premise Community Edition

Ansible + Terraform automation for deploying Cloudera Private Cloud on AWS. Constructs a ring-fenced, 10-node cluster accessible via SSH and reverse HTTPS proxies.

- Self-contained DNS, Kerberos, database, and TLS services
- ACME-managed TLS termination on the reverse proxy
- Cloudera Manager with Kerberos and Auto-TLS
- Multiple cluster topologies (Ozone, Kafka, Flink, NiFi, CSA, ECS)
- Fully idempotent — run repeatedly with no unintended state changes

## Quick Start

```bash
cp config-template.yml config.yml    # Set name_prefix, infra_region, common_password, owner
ansible-navigator run playbooks/infrastructure.yml playbooks/services.yml playbooks/cms.yml playbooks/ozone-cluster.yml -e @config.yml
```

## Documentation

> **[View the full documentation site](<YOUR_DOCS_SITE_URL>)**

Setup instructions, configuration reference, and operational guides are also available in the **[docs/](docs/)** directory.

| Section | Description |
|---------|-------------|
| [Getting Started](docs/getting-started/) | Prerequisites, credentials, configuration |
| [Deployment](docs/deployment/) | Infrastructure, services, Cloudera Manager, clusters |
| [Operations](docs/operations/) | Accessing endpoints, SSH, tear down |
| [Reference](docs/reference/) | Architecture, execution environment |
