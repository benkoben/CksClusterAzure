variable "ssh_pub_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "tags" {
  type = map(any)
  default = {
    "environment" = "dev"
    "purpose"     = "education"
    "lockstatus"  = "unlocked"
  }
}
