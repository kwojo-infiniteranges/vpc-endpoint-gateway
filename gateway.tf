#
# Endpoint
#
resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = [aws_route_table.private.id]

  tags = {
    Name = "demo-s3-endpoint"
  }
}

#
# Desired Access
#
resource "aws_vpc_endpoint_policy" "allow_all_s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : [
          "s3:PutObject",
          "s3:GetObject"
        ],
        "Resource" : "arn:aws:s3:::vpc-endpoint-demo-2022-12-14/*"
      }
    ]
  })
}

/*
#
# Access Denied to Intended Target
#
resource "aws_vpc_endpoint_policy" "allow_all_s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  policy = jsonencode({
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "VisualEditor0",
			"Effect": "Allow",
      "Principal" : {
          "AWS" : "*"
      },
			"Action": [
				"s3:PutObject",
				"s3:GetObject"
			],
			"Resource": "arn:aws:s3:::aux-vpc-endpoint-demo-2022-12-14/*"
		}
	]
})
}
*/

/*
#
# Full Access
#
resource "aws_vpc_endpoint_policy" "allow_all_s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowAll",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : [
          "s3:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}
*/