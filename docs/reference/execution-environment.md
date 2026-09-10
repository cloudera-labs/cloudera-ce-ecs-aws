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

# Execution Environment

The Ansible Execution Environment (EE) is a container image that packages all dependencies required to run the playbooks.

## What's Included

- **OS:** CentOS Stream 9
- **Ansible:** ansible-core 2.15, ansible-runner 2.4
- **System packages:** Terraform, git, unzip
- **Python packages:** dnspython
- **Galaxy collections:** All from `requirements.yml`
- **CM SDK:** Cloudera Manager API Swagger client

## Building the EE

### Using Hatch (Recommended)

```bash
hatch run build
```

### Manual Build

```bash
podman manifest rm <YOUR_REGISTRY>/<YOUR_IMAGE>:$(hatch version)
pushd builder
ansible-builder build \
  -t localhost/<YOUR_IMAGE>:$(hatch version) \
  --extra-build-cli-args "--load --platform linux/amd64,linux/arm64 --manifest <YOUR_REGISTRY>/<YOUR_IMAGE>:$(hatch version)" \
  --no-cache \
  --squash all
popd
```

!!! warning
    The `--manifest` flag appends images to the manifest. If running multiple times, purge the local manifest first with `podman manifest rm`.

## Pushing to a Registry

Push the resulting manifest to your container registry:

```bash
# Push versioned tag
podman manifest push \
  <YOUR_REGISTRY>/<YOUR_IMAGE>:$(hatch version)

# Push latest tag
podman manifest push \
  <YOUR_REGISTRY>/<YOUR_IMAGE>:$(hatch version) \
  <YOUR_REGISTRY>/<YOUR_IMAGE>:latest
```

!!! warning
    You may need to authenticate with your registry prior to pushing.

## Configuring ansible-navigator

Update `ansible-navigator.yml` to point to your EE image:

```yaml
execution-environment:
  image: <YOUR_REGISTRY>/<YOUR_IMAGE>:latest
```

## Build Arguments

| Arg | Default | Purpose |
|-----|---------|---------|
| `BUILD_VER` | `latest` | Image version tag (shown in shell prompt) |
| `BUILD_DATE` | `unknown` | Build timestamp for OCI labels |
| `BUILD_REVISION` | `unknown` | Git revision for OCI labels |
| `CM_VERSION` | `7.13.1` | Cloudera Manager version for Swagger SDK |
