# Normally, I would use a remote state setup, but then you get into circular
# dependencies with creating the bucket to store the state which requires state
# :mindblown:
# That would also come into play for a CD setup

# terraform {
#   backend "gcs" {
#     bucket = "nucms-infra"
#     prefix = "terraform/state"
#   }
# }
provider "google" {
  credentials = "${file("/Users/jackb109/Downloads/nuorder-devops-20190219-iggy-957dc242b8c7.json")}"
  project     = "nuorder-devops-20190219-iggy"
  region      = "us-central1"
}

provider "google-beta" {
  credentials = "${file("/Users/jackb109/Downloads/nuorder-devops-20190219-iggy-957dc242b8c7.json")}"
  project     = "nuorder-devops-20190219-iggy"
  region      = "us-central1"
}

# Container Registry is deployed for every account
# this is to fetch the info for it
data "google_container_registry_repository" "project" {}

output "gcr_location" {
  value = "${data.google_container_registry_repository.project.repository_url}"
}
