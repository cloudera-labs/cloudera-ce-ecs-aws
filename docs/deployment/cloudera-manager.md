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

# Cloudera Manager

The CMS playbook installs and configures Cloudera Manager Server and agents across the deployment.

## What It Does

1. Creates CM databases in PostgreSQL
2. Enables the Cloudera Manager package repository
3. Installs and configures CM Server
4. Configures the Caddy reverse proxy entry for CM
5. Waits for CM to become ready
6. Enables Auto-TLS (using FreeIPA as the CA)
7. Installs CM agents on all cluster hosts
8. Configures external LDAP authentication (via FreeIPA)
9. Sets up Cloudera Management Services (monitoring, reporting)
10. Installs the CDP license

## Run

```bash
ansible-navigator run playbooks/cms.yml -e @config.yml
```

## Tags

| Tag | Purpose |
|-----|---------|
| `postgresql` | CM database creation |
| `cm_repo` | Package repository setup |
| `cm_server` | CM Server installation |
| `cm_agent` | CM Agent installation on cluster hosts |

## After Completion

Once the CMS playbook finishes:

- Cloudera Manager is accessible at `https://cm.<gateway_ip>.<public_domain>`
- Default admin credentials: `admin` / `<cloudera_manager_admin_password>`
- Auto-TLS is enabled — all CM-managed services use FreeIPA-signed certificates
- External authentication is configured — FreeIPA groups `cdp-admins` and `cdp-users` are mapped to CM roles

## Knox Gateway Proxy

The playbook also configures a Knox reverse proxy entry, accessible at:

- `https://knox.<gateway_ip>.<public_domain>/gateway/homepage/home`
