# Copyright 2019 Google LLC
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


locals {
  env = "onprem"
}

provider "google" {
  project = var.project
}

module "vpc" {
  source  = "../../modules/vpc"
  project = var.project
  env     = local.env
}

module "firewall" {
  source  = "../../modules/firewall"
  project = var.project
  subnet  = module.vpc.subnet
}


module "vpn" {
  source             = "../../modules/vpn-classic"
  project            = var.project
  network            = module.vpc.network
  peer_gcp_project   = var.project # In a real scenario, this could be a different project
  peer_network_name  = "dev"       # Name of the peer VPC network
  secret_data        = module.vpn_secret.secret_data
}