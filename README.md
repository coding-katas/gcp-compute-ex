# GCP Compute exercice


### APIs to be enabled

- Identity and Access Management (IAM) API
- Compute Engine API

---

### Activate CloudShell to setup Lab

Execute below commands in CloudShell

- `cd gcp-compute-ex/tf/`
- `terraform init`
- `terraform apply --auto-approve`

---

### Allow Load Balancer to reach VM Instances

- Go to VPC Network&rarr;Firewall and click on Create Firewall Rule
- Name: allow-on-8080-from-load-balancer-ip-range
- Network: customer-vpc-network
- Targets: Specified Target Tags
- Target Tags: customer-app-server-public
- Source IP Ranges: 130.211.0.0/22, 35.191.0.0/16
- Ports: TCP:8080

---

### Verify website is working

- Go to Network Services&rarr;Load Balancing
- Click on Frontends
- Click on customer-app-load-balancer-front-end-public
- Copy External IP Address
- Go to http://<<External_IP_Address>>

---

### Clean up

- Delete VPC Firewall Rules that belong to customer-vpc-network Network
- Go back to CloudShell
- Make sure you are inside ./tf/ directory
- Execute `terraform destroy --auto-approve`
