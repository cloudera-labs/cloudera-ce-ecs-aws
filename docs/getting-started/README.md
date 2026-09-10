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

# Prerequisites

All code dependencies are packaged in an Ansible Execution Environment (container image), so setup is minimal.

## Requirements

1. **This project** — the source code
2. **Container runtime** — Docker or Podman
3. **AWS credentials** — via AWS SSO
4. **Cloudera Private Cloud license** — the text file (not the zip)

## Source Code

Clone the project to your workspace:

```bash
git clone https://<YOUR_GIT_HOST>/<YOUR_REPO_NAME>.git
cd <YOUR_REPO_NAME_ONLY>
```

## Execution Environment

Install `ansible-navigator` in a Python virtual environment:

```bash
python -m venv ~/cdp-navigator
source ~/cdp-navigator/bin/activate
pip install ansible-core ansible-navigator
```

!!! note
    You will need either **Docker** or **Podman** installed and running.

!!! tip
    If you need to troubleshoot this setup, check the [Navigator documentation](https://github.com/cloudera-labs/cldr-runner/blob/main/NAVIGATOR.md).

## AWS Credentials

!!! warning
    It is assumed you are using AWS SSO.

Log into AWS to get fresh credentials:

```bash
aws sso login --profile YOUR_AWS_PROFILE
```

Populate your environment with the AWS credentials:

```bash
eval $(aws configure export-credentials --format env --profile YOUR_AWS_PROFILE)
```

!!! warning
    AWS SSO credentials expire after 8 hours. If playbooks fail with credential errors, refresh your session with the commands above.

## CDP License

Set the license file location in your environment:

```bash
export CDP_LICENSE_FILE=LOCAL_FILE_PATH_TO_YOUR_LICENSE
```

!!! tip
    Use the **text file** of the license, not the `.zip` file.
