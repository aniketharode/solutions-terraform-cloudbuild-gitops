# Copyright 2022 Google LLC
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

data "google_compute_network" "peer" {
  project = var.peer_gcp_project
  name    = var.peer_network_name
}

data "terraform_remote_state" "peer" {
  backend = "local"

  config = {
    path = "../${var.peer_network_name}/terraform.tfstate"
  }
}

module "vpn_shared_secret" {
  source = "../vpn-secret"
}

resource "google_compute_vpn_gateway" "gateway" {
  project = var.project
  name    = "${var.network}-vpn-gateway"
  network = "projects/${var.project}/global/networks/${var.network}"
  region  = "asia-south1"
}

resource "google_compute_address" "vpn_static_ip" {
  project = var.project
  name    = "${var.network}-vpn-static-ip"
  region  = google_compute_vpn_gateway.gateway.region
}

resource "google_compute_forwarding_rule" "fr_esp" {
  project = var.project
  name    = "${var.network}-fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.gateway.self_link
  region      = google_compute_vpn_gateway.gateway.region
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  project = var.project
  name    = "${var.network}-fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.gateway.self_link
  region      = google_compute_vpn_gateway.gateway.region
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  project = var.project
  name    = "${var.network}-fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.gateway.self_link
  region      = google_compute_vpn_gateway.gateway.region
}

resource "google_compute_vpn_tunnel" "tunnel" {
  project             = var.project
  name                = "${var.network}-to-${var.peer_network_name}"
  peer_ip             = data.terraform_remote_state.peer.outputs.vpn_gateway_ip
  shared_secret       = module.vpn_shared_secret.secret_data
  target_vpn_gateway  = google_compute_vpn_gateway.gateway.self_link
  region              = google_compute_vpn_gateway.gateway.region
  router              = google_compute_vpn_gateway.gateway.network # Using network for routing
}