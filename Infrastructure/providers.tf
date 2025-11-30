terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "7.12.0"
    }
  }
}

provider "google" {
  # Configuration options
  project = "myservicedemoproject"
  region = "asia-south1"
  
}