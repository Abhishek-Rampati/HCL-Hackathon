resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public_subnet" {
  name          = "public-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  # Public subnet generally with external IP access via route to Internet Gateway
}

resource "google_compute_subnetwork" "private_subnet" {
  name                     = "private-subnet"
  ip_cidr_range            = "10.0.2.0/24"
  region                   = var.region
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access  = true  # allows private subnet to access Google APIs without external IP
}

resource "google_container_cluster" "primary" {
  name     = "my-gke-cluster"
  location = var.region

  initial_node_count = 3
  node_locations    = [var.zone1, var.zone2]

  networking_mode = "VPC_NATIVE"
  network        = google_compute_network.vpc_network.id
  subnetwork     = google_compute_subnetwork.public_subnet.name
}

resource "google_project_iam_member" "gke_admin" {
  project = var.project_id
  role    = "roles/container.clusterAdmin"
  member  = "user:admin@example.com"
}

resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc_network.name

  allow{
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.0.0.0/16"]
}

resource "google_artifact_registry_repository" "repo" {
  provider  = google
  location  = var.region
  repository_id = "hcl-hackathon-repo"
  description   = "Docker images repo"
  format        = "DOCKER"
}
