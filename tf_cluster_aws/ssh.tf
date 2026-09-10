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

# ------- SSH Keypair -------

locals {
  create_keypair = var.ssh_private_key_file == null ? true : false

  private_key_file = local.create_keypair ? abspath(local_sensitive_file.pem_file[0].filename) : abspath(pathexpand(var.ssh_private_key_file))
}

resource "tls_private_key" "generated_private_key" {
  count     = local.create_keypair ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "pem_file" {
  count                = local.create_keypair ? 1 : 0
  filename             = "../${var.prefix}-ssh-key.pem"
  file_permission      = "600"
  directory_permission = "700"
  content              = tls_private_key.generated_private_key[0].private_key_pem
}

data "tls_public_key" "selected" {
  private_key_openssh = local.create_keypair ? tls_private_key.generated_private_key[0].private_key_openssh : file(abspath(pathexpand(var.ssh_private_key_file)))
}

resource "aws_key_pair" "pvc_base" {
  key_name   = "${var.prefix}-pvc-ce"
  public_key = trimspace(data.tls_public_key.selected.public_key_openssh)
}
