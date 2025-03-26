variable "aws_region" {

  type        = string
  default     = "ap-south-1"
  description = "The aws region in which terraform will manage the infrastructure"
}

variable "vpc_cidr" {

  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR"
}

variable "project_name" {

  type    = string
  default = "Demo-EKS"
}
variable "public_subnet_cidrs" {

  type    = list(string)
  default = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]

}

variable "private_subnet_cidrs" {

  type    = list(string)
  default = ["10.0.96.0/19", "10.0.128.0/19", "10.0.160.0/19"]

}

variable "eks_node_role_policies" {
  type = set(string)
  default = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ]

}


variable "common_tags" {

  type = map(string)
  default = {
    "Environment" = "Dev"
    "owner"       = "Vamsi"
  }

}