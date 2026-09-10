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

# ------- Cluster Network and Prefix List -------

module "cluster_network" {
  source = "git::https://github.com/cloudera-labs/terraform-cloudera-ce-infrastructure-aws.git//modules/network?ref=main"

  prefix = var.prefix
  vpc_id = aws_vpc.pvc_base.id
}

resource "aws_vpc_security_group_egress_rule" "pvc_base" {
  security_group_id = module.cluster_network.intra_cluster_security_group.id
  description       = "All traffic"
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
  tags              = { Name = "${var.prefix}-pvc-base" }
}

resource "aws_ec2_managed_prefix_list" "pvc_base" {
  name           = "${var.prefix}-pvc-base-ingress"
  address_family = "IPv4"
  max_entries    = length(var.vpc_ingress_cidr)
  
  dynamic "entry" {
    for_each = var.vpc_ingress_cidr
    content {
      cidr        = entry.value
      description = "${var.prefix}-pvc-base-ingress"
    }
  }
}

# ------- Security Groups -------

locals {
  sg_ssh_proxy_name     = var.ssh_security_group_name != "" ? var.ssh_security_group_name : "${var.prefix}-pvc-base-ssh-proxy"
  sg_knox_gateway_name  = var.knox_gateway_security_group_name != "" ? var.knox_gateway_security_group_name : "${var.prefix}-pvc-base-knox-gateway"
  sg_reverse_proxy_name = var.reverse_proxy_security_group_name != "" ? var.reverse_proxy_security_group_name : "${var.prefix}-pvc-base-reverse-proxy"
}

resource "aws_security_group" "ssh_proxy" {
  vpc_id      = aws_vpc.pvc_base.id
  name        = local.sg_ssh_proxy_name
  description = "SSH traffic [${var.prefix}]"
  tags        = { Name = local.sg_ssh_proxy_name }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_proxy" {
  security_group_id = aws_security_group.ssh_proxy.id
  description       = "SSH traffic"
  prefix_list_id    = aws_ec2_managed_prefix_list.pvc_base.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  tags              = { Name = "${var.prefix}-pvc-base-ssh" }
}

resource "aws_security_group" "reverse_proxy" {
  vpc_id      = aws_vpc.pvc_base.id
  name        = local.sg_reverse_proxy_name
  description = "Reverse Proxy traffic [${var.prefix}]"
  tags        = { Name = local.sg_reverse_proxy_name }
}

resource "aws_vpc_security_group_ingress_rule" "reverse_proxy" {
  security_group_id = aws_security_group.reverse_proxy.id
  description       = "Reverse Proxy traffic"
  prefix_list_id    = aws_ec2_managed_prefix_list.pvc_base.id
  from_port         = var.reverse_proxy_port
  ip_protocol       = "tcp"
  to_port           = var.reverse_proxy_port
  tags              = { Name = "${var.prefix}-pvc-base-reverse-proxy" }
}

resource "aws_security_group" "knox_gateway" {
  vpc_id      = aws_vpc.pvc_base.id
  name        = local.sg_knox_gateway_name
  description = "Knox Gateway traffic [${var.prefix}]"
  tags        = { Name = local.sg_knox_gateway_name }
}

resource "aws_vpc_security_group_ingress_rule" "knox_gateway" {
  security_group_id = aws_security_group.knox_gateway.id
  description       = "Knox Gateway traffic"
  prefix_list_id    = aws_ec2_managed_prefix_list.pvc_base.id
  from_port         = var.knox_gateway_port
  ip_protocol       = "tcp"
  to_port           = var.knox_gateway_port
  tags              = { Name = "${var.prefix}-pvc-base-knox-gateway" }
}
