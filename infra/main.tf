# Create Lamda function by using zip archive
resource "aws_lambda_function" "my_func" {
    filename = data.archive_file.zip.output_path
    source_code_hash = data.archive_file.zip.output_base64sha256
    function_name = "my_func"
    role = aws_iam_role.iam_for_lambda.arn
    handler = "func.handler"
    runtime = "python3.8"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
    "Version" : "2012-10-17",
    "Statement" : [
        {
            "Action" : "sts:AssumeRole",
            "Principal": {
                "Service" : "lambda.amazonaws.com"
            },
            "Effect" : "Allow",
            "Sid" : ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_for_resume_project" {
  name = "aws_iam_policy_for_terraform_resume_lambda_function"
  path = "/"
  description = "IAM Policy to allow access to Dynamo DB by resume role"
  policy = jsonencode(
    {
        "Version" : "2012-10-17",
        "Statement" : [
            {
                "Action" : [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                "Resource" : "arn:aws:logs:*:*:*",
                "Effect" : "Allow"
            },
            {
                "Effect" : "Allow"
                "Action" : [
                    "dynamodb:UpdateItem",
                    "dynamodb:GetItem",
                    "dynamodb:PutItem"
                    
                ],
                "Resource" : "arn:aws:dynamodb:*:*:table/cloudresume"
            }
        ]
    }
  )
}

# Attach IAM role for lambda and policy
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_resume_project.arn
}

# Remove authorization from function URL
# and added CORS. One can add their domain 
# in allow_origins
resource "aws_lambda_function_url" "url1" {
  function_name = aws_lambda_function.my_func.function_name
  authorization_type = "NONE"

  cors{
    allow_credentials = true
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = ["date", "keep-alive"]
    expose_headers = ["keep-alive", "date"]
    max_age = 86400
  }
}