resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-ng"
  subnet_ids      = aws_subnet.private[*].id
  node_role_arn   = aws_iam_role.node.arn
  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 5
  }
  update_config {
    max_unavailable = 1
  }
  #https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html#AmazonEKS-Type-Nodegroup-amiType
  ami_type       = "AL2_x86_64"
  disk_size      = 20
  capacity_type  = "ON_DEMAND"
  instance_types = ["t2.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.node_eksworkernode
  ]
  # provisioner "local-exec" {
  #   command = "aws eks update-kubeconfig --name Demo-EKS-Dev-cluster --region ap-south-1 --profile default"


  # }

}


resource "aws_iam_role" "node" {
  name               = "${var.project_name}-worker-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_node.json
  tags = merge(var.common_tags, {
    "Name" = "${var.project_name}-worker-role"
  })
}

resource "aws_iam_role_policy_attachment" "node_eksworkernode" {

  for_each   = var.eks_node_role_policies
  role       = aws_iam_role.node.name
  policy_arn = each.value
}