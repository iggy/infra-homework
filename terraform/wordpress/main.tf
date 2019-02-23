# DNS
# resource "google_dns_record_set" "dns" {
#   name = "${var.name}.${var.dns_name}"
#   type = "A"
#   ttl  = 300
#
#   managed_zone = "${var.dns_name}"
#
#   rrdatas = ["${google_compute_instance.frontend.network_interface.0.access_config.0.nat_ip}"]
# }

# DB
# FIXME keep getting errors about `An unknown error occurred` on DB instance creation
# TODO replicas
resource "google_sql_database_instance" "db" {
  # Let tf autogenerate a DB name so we don't have to deal with google not
  # allowing reuse of names
  # name             = "db-instance-${var.name}-1"
  database_version = "MYSQL_5_7"

  # region is weird here because of gce historical anomalies
  # we wouldn't normally specify it, but we do here for completeness
  region = "us-central1"

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = "false"
      private_network = "${var.private_network}"
    }

    user_labels {
      db_name     = "${var.name}"
      environment = "prd"
    }

    # location_preference {
    #   zone = "${google_container_node_pool.preemptible_nodes.zone}"
    # }

    # TODO See if this can be useful
    # activation_policy = ALWAYS, NEVER or ON_DEMAND
  }
}

resource "google_sql_database" "wordpress" {
  name      = "wp-db"
  instance  = "${google_sql_database_instance.db.name}"
  charset   = "utf8"
  collation = "utf8_general_ci"
}

resource "google_sql_user" "wordpress" {
  name     = "wp-user"
  instance = "${google_sql_database_instance.db.name}"
  host     = "%"
  password = "${random_id.wp_password.hex}"
}

resource "random_id" "wp_password" {
  byte_length = 8
}

# Shared storage
# resource "google_filestore_instance" "files" {
# }

# Redis

# K8s workers
# TODO should probably have 2 pools of preemptible and non-preemptible
resource "google_container_node_pool" "preemptible_nodes" {
  name       = "node-pool-${var.name}"
  region     = "us-central1"
  cluster    = "${var.gke_name}"
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

# object storage/static files
resource "google_storage_bucket" "static" {
  name = "nucms-static-${var.name}"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

# TODO terraform fails here until you go setup your kubeconfig
# `gcloud container clusters get-credentials gke --region us-central1`
# helm chart to deploy WordPress
resource "helm_release" "wordpress" {
  name  = "wordpress-${var.name}"
  chart = "stable/wordpress"

  set {
    name  = "mariadb.enabled"
    value = "false"
  }

  set {
    name  = "externalDatabase.host"
    value = "${google_sql_database_instance.db.connection_name}"
  }

  set {
    name  = "externalDatabase.user"
    value = "${google_sql_user.wordpress.name}"
  }

  set {
    name  = "externalDatabase.password"
    value = "${random_id.wp_password.hex}"
  }

  set {
    name  = "externalDatabase.database"
    value = "${google_sql_database.wordpress.name}"
  }

  set {
    name  = "service.annotations"
    value = "TODO annotations for GCE LB setup"
  }
}
