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

# Tear Down

Remove the entire deployment — all AWS resources are destroyed, leaving no trace.

## Run

```bash
ansible-navigator run playbooks/infrastructure-teardown.yml -e @config.yml
```

## What It Destroys

- All EC2 instances (gateway, services, masters, workers, CMS, SDX)
- Elastic IP addresses
- VPC, subnets, internet gateway, security groups
- SSH keypair (AWS-side; the local `.pem` file remains)
- Terraform state is cleaned up

!!! warning
    This is a destructive, irreversible operation. All data on the cluster hosts will be permanently lost.

!!! tip
    The local files (`terraform.tfstate`, SSH key, summary HTML) remain in your project directory. Delete them manually if you want a completely clean slate.

## Partial Tear Down

If you only want to remove the Terraform-managed infrastructure without destroying everything:

```bash
cd tf_cluster_aws
terraform destroy
```

This gives you more control over what gets removed and lets you inspect the plan before confirming.
