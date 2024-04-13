# This Terraform configuration file defines the infrastructure for a Google Cloud Platform (GCP) compute environment.
# It creates :
# 1. A VPC network with two subnetworks
# 2. An instance template
# 3. A managed instance group
# 4. A firewall rule
# 5. A backend service
# 6. A health check
# 7. A target HTTP proxy
# 8. A URL map
# 9. A global forwarding rule

# Data Block: External Environment Data
# This data block retrieves environment variables from an external script and stores them in the "env" variable.
data "external" "env" {
  program = ["${path.module}/env.sh"]
}

# Data Block: Default Service Account
# This data block retrieves the default service account for the project.
data "google_compute_default_service_account" "default" {
}

# Resource Block: VPC Network
# This resource block creates a VPC network with the specified name and properties.
resource "google_compute_network" "vpc_network" {
  project                 = data.external.env.result["project"]
  name                    = "my-awesome-vpc-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

# Resource Block: Subnetwork 1
# This resource block creates a subnetwork with the specified name, IP CIDR range, and network.
resource "google_compute_subnetwork" "subnetwork_1" {
  name          = "my-awesome-vpc-sub-network-1"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc_network.id
}

# Resource Block: Subnetwork 2
# This resource block creates another subnetwork with the specified name, IP CIDR range, and network.
resource "google_compute_subnetwork" "subnetwork_2" {
  name          = "my-awesome-vpc-sub-network-2"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc_network.id
}

# Resource Block: Instance Template (Public)
# This resource block creates an instance template for public instances with the specified properties.
resource "google_compute_instance_template" "inst_template_public" {
  name_prefix = "my-awesome-app-inst-template-public"
  labels = {
    app-name         = "my-awesome-app"
    server-visiblity = "public"
  }

  tags = ["my-awesome-app-server-public"]

  disk {
    source_image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20240319"
    auto_delete  = true
    boot         = true
  }
  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnetwork_1.id
    # access_config block makes the instance public. Uncomment this to make the instance public.
    access_config {
      network_tier = "STANDARD"
    }
  }

  metadata_startup_script = file("./vm-startup-script.sh")

  machine_type = "e2-medium"

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

# Resource Block: Managed Instance Group (Public)
# This resource block creates a managed instance group for public instances with the specified properties.
resource "google_compute_region_instance_group_manager" "mig_public" {
  name               = "my-awesome-app-managed-instance-group-public"
  base_instance_name = "my-awesome-app-server-public"

  version {
    instance_template = google_compute_instance_template.inst_template_public.self_link_unique
  }
  target_size = 1

  named_port {
    name = "my-awesome-app-port"
    port = 8080
  }
}

# Resource Block: Firewall Rule (SSH from IAP Range)
# This resource block creates a firewall rule to allow SSH access from the specified IAP range.
resource "google_compute_firewall" "ssh_from_iap_range" {
  name    = "allow-ingress-from-iap"
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}

# Resource Block: Backend Service (Public)
# This resource block creates a backend service for public instances with the specified properties.
resource "google_compute_backend_service" "backend_service_public" {
  name                  = "my-awesome-app-load-balancer-backend-public"
  protocol              = "HTTP"
  port_name             = "my-awesome-app-port"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  timeout_sec           = 10
  enable_cdn            = false
  health_checks         = [google_compute_health_check.health_check_public.id]
  backend {
    group           = google_compute_region_instance_group_manager.mig_public.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# Resource Block: Health Check (Public)
# see 
# This resource block creates a health check for public instances with the specified properties.
resource "google_compute_health_check" "health_check_public" {
  name = "my-awesome-app-load-balancer-hc-public"
  # request_path        = "/"
  # port                = "8080"
  check_interval_sec  = 1
  timeout_sec         = 1
  unhealthy_threshold = 2
  healthy_threshold   = 2
  http_health_check {
    port         = "8080"
    request_path = "/"
  }
}

# Resource Block: Target HTTP Proxy (Public)
# This resource block creates a target HTTP proxy for public instances with the specified properties.
resource "google_compute_target_http_proxy" "target_http_proxy_public" {
  name    = "my-awesome-app-load-balancer-proxy-public"
  url_map = google_compute_url_map.compute_url_map_public.id
}

# Resource Block: URL Map (Public)
# This resource block creates a URL map for public instances with the specified properties.
resource "google_compute_url_map" "compute_url_map_public" {
  name            = "my-awesome-app-load-balancer-public"
  default_service = google_compute_backend_service.backend_service_public.id
}

# Resource Block: Global Forwarding Rule (Public)
# This resource block creates a global forwarding rule for public instances with the specified properties.
resource "google_compute_global_forwarding_rule" "forwarding_rule_public" {
  name                  = "my-awesome-app-load-balancer-front-end-public"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.target_http_proxy_public.id
}

# Output Block: Environment Variables
# This output block displays the environment variables retrieved from the external script.
output "env" {
  value = data.external.env.result
}
