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

# ------- VPC -------

locals {
  vpc_name           = var.vpc_name != "" ? var.vpc_name : "${var.prefix}-pvc-base"
  vpc_private_domain = var.private_domain
  igw_name           = var.igw_name != "" ? var.igw_name : "${var.prefix}-pvc-base-igw"
}

resource "aws_vpc" "pvc_base" {
  cidr_block           = var.vpc_cidr
  tags                 = { Name = local.vpc_name }
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "pvc_base" {
  vpc_id = aws_vpc.pvc_base.id
  tags   = { Name = local.igw_name }
}

resource "aws_vpc_dhcp_options" "pvc_base" {
  domain_name         = local.vpc_private_domain
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = { Name = "${var.prefix}-pvc-base" }
}

resource "aws_vpc_dhcp_options_association" "pvc_base" {
  vpc_id          = aws_vpc.pvc_base.id
  dhcp_options_id = aws_vpc_dhcp_options.pvc_base.id
}
