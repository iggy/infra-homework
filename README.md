# NuCMS

## Requirements

* terraform
* kubectl
* helm


## Getting Started

* console.cloud.google.com
* Menu -> APIs & Services -> Credentials
* Create credentials -> Service account
* New Service Account
  * Service account name = `terraform`
  * Role = `Project -> Editor`
  * Key Type = `JSON`

## Terraform

* `terraform plan`
* `terraform apply`

## Notes

* There's a bit of a circular dependency between setting up the GKE cluster and
  using it in the helm provider. I've solved that various ways in the past, but
  here I just did it manually by running
  `gcloud container clusters get-credentials gke --region us-central1`
  after the helm failed to run.
* See `TODO`s, `FIXME`s, and other inline docs in the tf code
