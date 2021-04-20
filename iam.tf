data "aws_iam_policy_document" "LambdaEdgeAssumeRole" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "redirect_lambda_logging" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:CreateLogGroup"]
    resources = ["arn:aws:logs:*:822757335928:log-group:/aws/lambda/us-east-1.redirect:*"]
  }
  statement {
    actions   = ["logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:822757335928:log-group:/aws/lambda/us-east-1.redirect:*"]
  }
}

resource "aws_iam_role" "redirect" {
  name               = "RedirectLambda"
  description        = "Used by the redirection lambda."
  assume_role_policy = data.aws_iam_policy_document.LambdaEdgeAssumeRole.json

  inline_policy {
    name   = "Logging"
    policy = data.aws_iam_policy_document.redirect_lambda_logging.json
  }
}
