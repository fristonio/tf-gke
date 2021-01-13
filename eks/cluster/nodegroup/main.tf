resource "aws_iam_role" "eks_ng" {
  name = "${var.cluster_name}-ng"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_ng_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_ng.name
}

resource "aws_iam_role_policy_attachment" "eks_ng_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_ng.name
}

resource "aws_iam_role_policy_attachment" "eks_ng_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_ng.name
}

resource "aws_eks_node_group" "eks_ng" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = aws_iam_role.eks_ng.arn

  subnet_ids      = var.subnets

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = [
    var.instance_type
  ]

  disk_size = var.disk_size
  ami_type  = var.ami_type

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_ng_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_ng_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_ng_AmazonEC2ContainerRegistryReadOnly,
  ]
}
