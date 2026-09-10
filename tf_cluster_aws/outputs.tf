# Copyright 2026 Cloudera, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

output "ssh_key_pair" {
  value = {
    name        = aws_key_pair.pvc_base.key_name
    public_key  = trimspace(data.tls_public_key.selected.public_key_openssh)
    type        = aws_key_pair.pvc_base.key_type
    fingerprint = aws_key_pair.pvc_base.fingerprint
  }
  description = "SSH public key"
}

output "vpc" {
  value       = aws_vpc.pvc_base
  description = "AWS VPC"
}

output "availability_zones" {
  value       = module.cluster_network.availability_zones
  description = "AWS Availability Zones"
}

output "cluster" {
  value = {
    public_subnets               = module.cluster_network.public_subnets
    private_subnets              = module.cluster_network.private_subnets
    intra_cluster_security_group = module.cluster_network.intra_cluster_security_group
  }
  description = "Private Cloud cluster"
}

output "gateways" {
  value       = values(aws_eip.pvc-base)
  description = "Elastic IP addresses for gateway node(s)"
}

# Pricing output merges common modules (gateway, services) with
# topology-specific modules defined in the active hosts_*.tf file.
locals {
  costed_modules = merge(local.common_costed_modules, local.topology_costed_modules)
}

output "pricing" {
  description = "Estimated hourly costs for the cluster, including subtotals and a grand total."
  value = merge(
    {
      for name, m in local.costed_modules : name => {
        price_per_hour = try(m.pricing.price_per_hour, 0)
        description    = try(m.pricing.description, "")
        count          = try(length(m.hosts), 0)
        subtotal       = try(m.pricing.price_per_hour, 0) * try(length(m.hosts), 0)
      }
    },
    {
      total = {
        price_per_hour = sum([
          for m in local.costed_modules : try(m.pricing.price_per_hour, 0) * try(length(m.hosts), 0)
        ])
        description = "Total estimated hourly costs for the cluster"
        count = sum([
          for m in local.costed_modules : try(length(m.hosts), 0)
        ])
      }
    }
  )
}
