# IAM User for Parameter Store access
resource "aws_iam_user" "k8s_parameter_store_reader" {
  name = "k8s-parameter-store-reader"
}

# IAM Policy for reading /jyo-liar/k8s path in Parameter Store
resource "aws_iam_policy" "k8s_parameter_store_read" {
  name        = "k8s-parameter-store-read-policy"
  description = "Policy to read parameters under /jyo-liar/k8s path"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/jyo-liar/k8s/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:DescribeParameters"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "k8s_parameter_store_reader_attachment" {
  user       = aws_iam_user.k8s_parameter_store_reader.name
  policy_arn = aws_iam_policy.k8s_parameter_store_read.arn
}

# Access Key for k8s_parameter_store_reader
resource "aws_iam_access_key" "k8s_parameter_store_reader" {
  user = aws_iam_user.k8s_parameter_store_reader.name
}

# Outputs for Access Key
output "k8s_parameter_store_reader_access_key_id" {
  description = "Access Key ID for k8s-parameter-store-reader"
  value       = aws_iam_access_key.k8s_parameter_store_reader.id
}

output "k8s_parameter_store_reader_secret_access_key" {
  description = "Secret Access Key for k8s-parameter-store-reader"
  value       = aws_iam_access_key.k8s_parameter_store_reader.secret
  sensitive   = true
}
