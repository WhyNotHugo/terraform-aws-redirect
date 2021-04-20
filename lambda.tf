data "template_file" "aliases" {
  template = <<EOF
%{for source, target in var.alias_domains~}
${source}:${target}
%{endfor~}
EOF
}

data "archive_file" "redirect_lambda" {
  type        = "zip"
  output_path = "${path.module}/tmp/redirect.zip"

  source {
    content  = file("${path.module}/redirect.py")
    filename = "redirect.py"
  }

  source {
    content  = data.template_file.aliases.rendered
    filename = "aliases"
  }
}

resource "aws_lambda_function" "redirect" {
  function_name = "redirect"
  role          = aws_iam_role.redirect.arn

  # TODO: dead_letter_config

  filename         = data.archive_file.redirect_lambda.output_path
  handler          = "redirect.handle"
  publish          = true
  runtime          = "python3.8"
  source_code_hash = data.archive_file.redirect_lambda.output_base64sha256
}
