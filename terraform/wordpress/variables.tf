variable "name" {
  description = "Name of the site to be created"
  default     = ""
}

variable "gke_name" {
  description = "Name of the GKE cluster used to join the worker pool to the backplane"
  default     = ""
}

variable "dns_name" {
  description = "name of the DNS zone to add records to"
  default     = ""
}

variable "private_network" {
  description = ""
  default     = ""
}
