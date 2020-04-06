
resource "google_compute_network" "cloudflow_network" {
  project                         = data.google_project.cloudflow_project.project_id
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
  name                            = "cloudflow-network"
}

resource "google_compute_route" "default_gateway" {
  name             = "default-gateway"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.cloudflow_network.name
  next_hop_gateway = "default-internet-gateway"
}

resource "google_compute_subnetwork" "cloudflow_subnetwork" {
  project       = data.google_project.cloudflow_project.project_id
  name          = "cloudflow-subnetwork"
  ip_cidr_range = "172.30.0.0/24"
  network       = google_compute_network.cloudflow_network.self_link
  region        = var.gcp_region
}
