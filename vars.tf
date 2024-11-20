variable "region" {
  default = "eu-west-2"
}

variable "ami_id" {
  type = map(string)
  default = {
    ubuntu = "ami-03ceeb33c1e4abcd1"
    linux  = "ami-0abb41dc69b6b6704"
  }
}

variable "instance_type" {
  default = "t3.medium"
}

variable "key_name" {
  default = "PERSONALACCOUNT"
#   default = "ADITYANEWKEYITC"
}

variable "subnet_ids" {
  type    = list(string)
  default = ["subnet-06d63f443b5cec3af", "subnet-07fde5cc5ffb01580", "subnet-01e9eb9a0384143dd"]
#   default = ["subnet-01a8be27831a6da4e", "subnet-03a6d21428c5cb0e9", "subnet-0fda47b6bd01a3216"]
}

variable "security_group_id" {
  default = "sg-027239d25e2c27e25"
#   default = "sg-00c8b561dc6b524c6"
}

variable "instance_count" {
  default = 2
}
