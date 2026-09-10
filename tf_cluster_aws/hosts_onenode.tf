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

# ------- Onenode Cluster Topology -------
# Single-node deployment: one instance runs all roles (master, worker, SDX, CMS)
# Used by: pvc-community-edition-onenode-aws

module "onenode" {
  source     = "git::https://github.com/cloudera-labs/terraform-cloudera-ce-infrastructure-aws.git//modules/hosts?ref=main"
  depends_on = [aws_key_pair.pvc_base, data.aws_ami.pvc_base]

  providers = {
    aws                    = aws,
    aws.pricing_calculator = aws.price_calculator
  }

  name            = "${var.prefix}-master"
  quantity        = 1
  image_id        = data.aws_ami.pvc_base.image_id
  instance_type   = "r5a.4xlarge"
  ssh_key_pair    = aws_key_pair.pvc_base.key_name
  subnet_ids      = module.cluster_network.private_subnets[*].id
  security_groups = [module.cluster_network.intra_cluster_security_group.id]
  public_ip       = false

  root_volume = {
    volume_size = 250
  }
}

resource "ansible_host" "onenode" {
  for_each = { for idx, host in module.onenode.hosts : idx => host }

  name = format("%s.%s", each.value.tags["Name"], local.vpc_private_domain)

  groups = [
    ansible_group.base_masters.name,
    ansible_group.base_workers.name,
    ansible_group.sdx.name,
    ansible_group.manager.name,
  ]

  variables = {
    ansible_host    = each.value.private_ip
    ansible_user    = local.ami_user
    host_template   = format("Master%s", each.key + 1)
    storage_volumes = jsonencode(lookup(module.onenode.storage_volumes, each.value.id, []))
  }
}

