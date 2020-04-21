
#   --cluster-version $CLUSTER_VERSION  \
#   --image-type cos \
#   --machine-type n1-standard-4 \
#   --num-nodes 5 \
#   --enable-autoscaling \
#   --max-nodes=7 \
#   --min-nodes=1 \
#   --no-enable-legacy-authorization \
#   --no-enable-autoupgrade

resource "google_container_cluster" "cloudflow_services" {
  name       = "cloudflow-services"
  location = var.gcp_region
  network = google_compute_network.cloudflow_network.self_link
  subnetwork = google_compute_subnetwork.cloudflow_subnetwork.self_link

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

    # ip_allocation_policy {
    #     use_ip_aliases                = true
    # cluster_secondary_range_name  = format("k8pods-%s", local.slice)
    # services_secondary_range_name = format("k8services-%s", local.slice)
    # }

#  private_cluster_config {
#     enable_private_endpoint = true
#     enable_private_nodes    = true
#     master_ipv4_cidr_block  = var.master_ipv4_cidr_block
#   }

  master_auth {
    username = "cloudflow"
    password = "cloudflowsandbox1023"

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

variable "node_machine_type" {
    default = "n1-standard-1"
}

variable "node_disk_size_gb" {
    default = 10
}

variable "node_disk_type" {
    default = "pd-standard"
}

variable "node_service_account" {
    default = "terraform@cloudflow-1023b.iam.gserviceaccount.com"
}

data "google_compute_zones" "available" {
  region = var.gcp_region
}

resource "google_container_node_pool" "cloudflow_node_pool" {
  name       = "cloudflow-node-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.cloudflow_services.name
  node_count = 3

  node_config {
    preemptible  = true
    machine_type = var.node_machine_type
    disk_size_gb = var.node_disk_size_gb
    disk_type    = var.node_disk_type
    service_account = var.node_service_account
    metadata = {
      disable-legacy-endpoints = "true"
    }
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

output "cloudflow_endpoint" {
  value = google_container_cluster.cloudflow_services.endpoint
}

# provider "kubernetes" {
#   host = "https://${google_container_cluster.cloudflow_services.endpoint}"

#   //  username = "${google_container_cluster.vitalfish_services.master_auth.0.username}"
#   //  password = "${google_container_cluster.vitalfish_services.master_auth.0.password}"
#   client_certificate = "${base64decode(google_container_cluster.cloudflow_services.master_auth.0.client_certificate)}"
#   client_key             = "${base64decode(google_container_cluster.cloudflow_services.master_auth.0.client_key)}"
#   cluster_ca_certificate = "${base64decode(google_container_cluster.cloudflow_services.master_auth.0.cluster_ca_certificate)}"
# }

# resource "kubernetes_namespace" "cloudflow_services" {
#   metadata {
#     name = "cloudflow-services"
#   }
# }

