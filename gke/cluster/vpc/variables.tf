variable "subnets" {
  type    = map(string)
  # this is based on default network's config
  default = {
    us-central1	             = "10.128.0.0/20"
    europe-west1             = "10.132.0.0/20"
    us-west1                 = "10.138.0.0/20"
    asia-east1               = "10.140.0.0/20"
    us-east1                 = "10.142.0.0/20"
    asia-northeast1          = "10.146.0.0/20"
    asia-southeast1          = "10.148.0.0/20"
    us-east4                 = "10.150.0.0/20"
    australia-southeast1     = "10.152.0.0/20"
    europe-west2             = "10.154.0.0/20"
    europe-west3             = "10.156.0.0/20"
    southamerica-east1       = "10.158.0.0/20"
    asia-south1              = "10.160.0.0/20"
    northamerica-northeast1  = "10.162.0.0/20"
    europe-west4             = "10.164.0.0/20"
    europe-north1            = "10.166.0.0/20"
    us-west2                 = "10.168.0.0/20"
    asia-east2               = "10.170.0.0/20"
    europe-west6             = "10.172.0.0/20"
    asia-northeast2          = "10.174.0.0/20"
    asia-northeast3          = "10.178.0.0/20"
    us-west3                 = "10.180.0.0/20"
    us-west4                 = "10.182.0.0/20"
  }
}

variable "vpc_name" {
  type        = string
  description = "VPC to create the cluster in."

  validation {
    condition     = length(var.vpc_name) > 5 && length(var.vpc_name) < 64
    error_message = "Length of the name of the vpc shoud be from 6 characters to 64 characters."
  }
}