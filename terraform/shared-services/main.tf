# DNS
resource "google_dns_managed_zone" "parent_zone" {
  name        = "cms-iggy-fun"
  dns_name    = "cms.iggy.fun."
  description = "cms.iggy.fun"

  labels = {
    environment = "prod"
  }
}

# VPC
# resource "google_compute_network" ""
resource "google_compute_network" "private_network" {
  name                    = "private-network"
  auto_create_subnetworks = "true"
  description             = "Private network for backend services"
}

resource "google_compute_global_address" "private_ip_address" {
  provider      = "google-beta"
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "${google_compute_network.private_network.self_link}"
}

# K8s
# We build the k8s backplane here and then the worker pools are per WordPress
# instance (to keep them separate) otherwise we could use the upstream module
resource "google_container_cluster" "primary" {
  name = "gke"

  # we specify region here because otherwise the provider tries to automagically
  # put it in a zone
  region = "us-central1"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  initial_node_count = 1

  remove_default_node_pool = true

  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    username = ""
    password = ""
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    preemptible = true

    # labels = {
    #   foo = "bar"
    # }
    #
    # tags = ["foo", "bar"]
  }
}
