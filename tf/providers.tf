# Define required providers and versions
terraform {
  required_version = ">= 0.14"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.53.0, < 6.0.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 3.53.0, < 6.0.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }

    curl = {
      source  = "marcofranssen/curl"
      version = "0.4.5"
    }
  }
}



