resource "aws_vpc" "main" {

  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.common_tags, {
    "Name"                                                         = "${var.project_name}-vpc"
    "kubernetes.io/cluster/my-cluster/${var.project_name}-cluster" = "shared"
    //https://docs.aws.amazon.com/eks/latest/userguide/network-reqs.html
  })

}

resource "aws_subnet" "public" {

  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    "kubernetes.io/cluster/my-cluster/${var.project_name}-cluster" = "shared"
    "kubernetes.io/role/elb"                                       = "1"
    "Name"                                                         = "${var.project_name}- public subnet"
  })
}
resource "aws_subnet" "private" {

  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  //map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    "kubernetes.io/cluster/my-cluster/${var.project_name}-cluster" = "shared"
    "kubernetes.io/role/internal-elb"                              = "1"
    "Name"                                                         = "${var.project_name}- private subnet"
  })
}

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.main.id
  tags = merge(var.common_tags, {
    "Name" = "${var.project_name}- igw"
  })
}

resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.common_tags, {
    "Name" = "${var.project_name}- public rt"
  })
}

resource "aws_route_table_association" "public_rt_assoscation" {

  count          = length(var.public_subnet_cidrs)
  route_table_id = aws_route_table.publicrt.id
  subnet_id      = aws_subnet.public[count.index].id
}

resource "aws_eip" "nateip" {
  tags = merge(var.common_tags, {
    "Name" = "${var.project_name}- nateip"
  })
}

resource "aws_nat_gateway" "nate_gateway" {

  allocation_id = aws_eip.nateip.id
  subnet_id     = aws_subnet.public[0].id
  tags = merge(var.common_tags, {
    "Name" = "${var.project_name}- nat"
  })

}

resource "aws_route_table" "privatert" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nate_gateway.id
  }
  tags = merge(var.common_tags, {
    "Name" = "${var.project_name}- public rt"
  })
}

resource "aws_route_table_association" "private_rt_assoscation" {

  count          = length(var.private_subnet_cidrs)
  route_table_id = aws_route_table.privatert.id
  subnet_id      = aws_subnet.private[count.index].id
}

