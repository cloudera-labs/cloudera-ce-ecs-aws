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

# Accessing the Deployment

## Deployment Summary Page

After deployment completes, a summary HTML page is generated locally:

```bash
python -m webbrowser file://${PWD}/<name_prefix>-summary.html
```

The summary page is also accessible via the reverse proxy:

```
https://<GATEWAY_PUBLIC_IP>.<public_domain>
```

The summary page lists all available endpoints and a brief list of hosts and their Ansible groups.

## Service Endpoints

All services are accessed through the Caddy reverse proxy on the gateway host:

| Service | URL |
|---------|-----|
| Cloudera Manager | `https://cm.<gateway_ip>.<public_domain>` |
| Knox Gateway | `https://knox.<gateway_ip>.<public_domain>/gateway/homepage/home` |
| FreeIPA | `https://freeipa.<gateway_ip>.<public_domain>` |
| pgAdmin | `https://pgadmin.<gateway_ip>.<public_domain>` |
| Prometheus | `https://prometheus.<gateway_ip>.<public_domain>` |
| Grafana | `https://grafana.<gateway_ip>.<public_domain>` |

!!! note
    Prometheus and Grafana endpoints are only available when `enable_prometheus: true`.

## TLS Certificates

If using the default self-signed TLS option (`caddy_self_signed: true`), the self-signed root CA is saved to your project directory after deployment.

You can install this CA into your local truststore to avoid browser certificate warnings:

=== "macOS"
    ```bash
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain <name_prefix>-caddy-root-ca.crt
    ```

=== "Linux"
    ```bash
    sudo cp <name_prefix>-caddy-root-ca.crt /usr/local/share/ca-certificates/
    sudo update-ca-certificates
    ```

## Default Credentials

| Service | Username | Password |
|---------|----------|----------|
| Cloudera Manager | `admin` | `<cloudera_manager_admin_password>` |
| FreeIPA | `admin` | `<freeipa_password>` |
| pgAdmin | `<owner_email>` | `<pgadmin_default_password>` |
| PostgreSQL | `<database_admin_user>` | `<database_admin_password>` |

All passwords default to `{{ common_password }}` unless explicitly overridden in `config.yml`.
