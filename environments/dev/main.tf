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
# limitations under the License.


locals {
  env = "dev"
}

# provider "google" {
#   project = "${var.project}"
# }

# module "vpc" {
#   source  = "../../modules/vpc"
#   project = "${var.project}"
#   env     = "${local.env}"
# }

# module "http_server" {
#   source  = "../../modules/http_server"
#   project = "${var.project}"
#   subnet  = "${module.vpc.subnet}"
# }

# module "firewall" {
#   source  = "../../modules/firewall"
#   project = "${var.project}"
#   subnet  = "${module.vpc.subnet}"
# }

provider "google" {
  project = "palace-accounting" # <-- Replace with your GCP project ID
  region  = "asia-south1"
}

resource "google_storage_bucket" "terraform-bucket-example-11" {
  name          = "palace-accounting-my-unique-bucket-1" # Replace with a globally unique bucket name
  location      = "asia-south1"
  force_destroy = true # Set to true for easy cleanup during development, remove in production
}
