#
# Compute Instance
#
resource "aws_instance" "workload" {
  ami           = "ami-0beaa649c482330f7"
  instance_type = "t3.micro"

  network_interface {
    network_interface_id = aws_network_interface.default.id
    device_index         = 0
  }

  iam_instance_profile = aws_iam_instance_profile.default.name

  tags = {
    Name = "vpc-endpoint-demo"
  }
}

#
# AMI
#
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#
# Networking
#
resource "aws_network_interface" "default" {
  subnet_id = aws_subnet.private.id

  tags = {
    Name = "primary_network_interface"
  }
}

#
# EC2 IAM
#
resource "aws_iam_instance_profile" "default" {
  name = "default_instance_profile"
  role = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "assume_policy" {
  name = "instance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "instance_role" {
  name               = "default_instance_role"
  assume_role_policy = aws_iam_role.assume_policy.assume_role_policy
}

resource "aws_iam_policy" "allow_ssm" {
  name = "allow-ssm"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeAssociation",
                "ssm:GetDeployablePatchSnapshotForInstance",
                "ssm:GetDocument",
                "ssm:DescribeDocument",
                "ssm:GetManifest",
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:ListAssociations",
                "ssm:ListInstanceAssociations",
                "ssm:PutInventory",
                "ssm:PutComplianceItems",
                "ssm:PutConfigurePackageResult",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceAssociationStatus",
                "ssm:UpdateInstanceInformation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "allow_s3" {
  name        = "allow-s3"
  description = "Allows access to PRIMARY bucket"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::${var.primary_bucket_name}/*"
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "attach_ssm" {
  name       = "attach_ssm"
  roles      = [aws_iam_role.instance_role.name]
  policy_arn = aws_iam_policy.allow_ssm.arn
}

resource "aws_iam_policy_attachment" "attach_s3" {
  name       = "attach_s3"
  roles      = [aws_iam_role.instance_role.name]
  policy_arn = aws_iam_policy.allow_s3.arn
}