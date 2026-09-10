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

# ------- Ansible Inventory (Groups) -------
# Defines the complete group hierarchy for all topologies.
# Groups with no hosts are harmless — Ansible plays targeting
# empty groups are simply skipped.

resource "ansible_group" "ssh_proxy" {
  name = "ssh_proxy"
  variables = {
    ansible_ssh_private_key_file = local.private_key_file
  }
}

resource "ansible_group" "reverse_proxy" {
  name = "reverse_proxy"
  variables = {
    ansible_ssh_private_key_file = local.private_key_file
  }
}

resource "ansible_group" "freeipa" {
  name = "freeipa"
}

resource "ansible_group" "postgres" {
  name = "postgresql"
}

resource "ansible_group" "pgadmin" {
  name = "pgadmin"
}

resource "ansible_group" "manager" {
  name = "cloudera_manager"
}

resource "ansible_group" "knox" {
  name = "knox_gateway"
}

resource "ansible_group" "sdx" {
  name = "sdx"
}

resource "ansible_group" "base_masters" {
  name = "base_masters"
}

resource "ansible_group" "base_workers" {
  name = "base_workers"
}

resource "ansible_group" "ecs_masters" {
  name = "ecs_masters"
}

resource "ansible_group" "ecs_workers" {
  name = "ecs_workers"
}

resource "ansible_group" "base" {
  name = "base"
  children = [
    ansible_group.base_masters.name,
    ansible_group.base_workers.name,
    ansible_group.sdx.name,
    ansible_group.knox.name,
  ]
}

resource "ansible_group" "ecs" {
  name = "ecs"
  children = [
    ansible_group.ecs_masters.name,
    ansible_group.ecs_workers.name,
  ]
}

resource "ansible_group" "cluster" {
  name = "cluster"
  children = [
    ansible_group.base.name,
    ansible_group.ecs.name,
  ]
}

resource "ansible_group" "deployment" {
  name = "deployment"
  children = [
    ansible_group.cluster.name,
    ansible_group.manager.name
  ]
}

resource "ansible_group" "proxied_servers" {
  name = "proxied_servers"
  children = [
    ansible_group.deployment.name,
    ansible_group.freeipa.name,
    ansible_group.pgadmin.name,
    ansible_group.postgres.name,
  ]
  variables = {
    ansible_ssh_private_key_file = local.private_key_file
    ansible_ssh_common_args      = "-o ProxyCommand='ssh -i ${local.private_key_file} -o User=${local.ami_user} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p -q ${aws_eip.pvc-base[0].public_ip}'"
  }
}
