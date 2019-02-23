output "gke_name" {
  value = "${google_container_cluster.primary.name}"
}

output "dns_name" {
  value = "${google_dns_managed_zone.parent_zone.name}"
}

output "private_network" {
  value = "${google_compute_network.private_network.self_link}"
}

# allow authentication and connectivity to the GKE Cluster
output "client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
}
