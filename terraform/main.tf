# Setup some shared services first for all of the wordpress instances to share
# GKE controlplane, DNS, etc
module "shared_services" {
  source = "./shared-services"

  providers = {
    google      = "google"
    google-beta = "google-beta"
  }
}

# Each wordpress instance would have it's own module
module "wordpress_1" {
  source          = "./wordpress"
  name            = "kimye"
  gke_name        = "${module.shared_services.gke_name}"
  dns_name        = "${module.shared_services.dns_name}"
  private_network = "${module.shared_services.private_network}"
}
