
variable "infrastructure_instances" {
  type = map(object({
    region                                   = string
    zone                                     = string
    external_loadbalancer_subnet             = string
    subnets = map(object({
      subnet_name                      = string
      subnet_ip                        = string
      subnet_region                    = string
      subnet_private_access            = optional(string, "false")
      subnet_private_ipv6_access       = optional(string)
      subnet_flow_logs                 = optional(string, "false")
      subnet_flow_logs_interval        = optional(string, "INTERVAL_5_SEC")
      subnet_flow_logs_sampling        = optional(string, "0.5")
      subnet_flow_logs_metadata        = optional(string, "INCLUDE_ALL_METADATA")
      subnet_flow_logs_filter          = optional(string, "true")
      subnet_flow_logs_metadata_fields = optional(list(string), [])
      description                      = optional(string)
      purpose                          = optional(string)
      role                             = optional(string)
      stack_type                       = optional(string)
      ipv6_access_type                 = optional(string)
    }))
  }))
}
