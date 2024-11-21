
infrastructure_instances = {
  "infra-euw3" = {
    region                                   = "europe-west3"
    zone                                     = "europe-west3-c"
    external_loadbalancer_subnet             = "10.157.2.0/24"
    subnets = {
      "default-subnet" = {
        subnet_name           = "default-subnet-euw3"
        subnet_ip             = "10.157.0.0/24"
        subnet_region         = "europe-west3"
        subnet_private_access = "true"
        subnet_flow_logs      = "false"
        description           = "Subnet 1"
      },
      "serverless-subnet" = {
        subnet_name           = "serverless-vpc-euw3"
        subnet_ip             = "10.157.1.0/28"
        subnet_region         = "europe-west3"
        subnet_private_access = "true"
        subnet_flow_logs      = "false"
        description           = "Subnet 2"
      }
    }
  },
  /**************************************************************************************************/
  /**         COPY/PASTE THE CONFIG BLOCK AS BELOW TO ADD MANY INSTANCES ON OTHERS REGIONS         **/
  /**************************************************************************************************/
  /* "infra-euw1" = {
    region                                   = "europe-west1"
    zone                                     = "europe-west1-c"
  ...
  }*/
}
