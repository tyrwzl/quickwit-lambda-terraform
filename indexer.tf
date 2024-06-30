resource "aws_lambda_function" "quickwit_indexer" {
  function_name = "quickwit-indexer"
  s3_bucket     = aws_s3_bucket.quickwit_assets_bucket.bucket
  s3_key        = aws_s3_object.quickwit_lambda_indexer.key
  handler       = "main"
  runtime       = "provided.al2023"
  timeout       = 900
  memory_size   = 3008
  role          = aws_iam_role.quickwit_indexer.arn

  environment {
    variables = {
      "QW_LAMBDA_INDEX_BUCKET"     = aws_s3_bucket.quickwit_index_bucket.bucket
      "QW_LAMBDA_INDEX_CONFIG_URI" = "s3://${aws_s3_bucket.quickwit_assets_bucket.bucket}/${local.quickwit_index_config_filename}"
      "QW_LAMBDA_INDEX_ID"         = var.quickwit_index_name
      "QW_LAMBDA_METASTORE_BUCKET" = aws_s3_bucket.quickwit_index_bucket.bucket
      "RUST_LOG"                   = "quickwit=info"
    }
  }
}

resource "aws_iam_role" "quickwit_indexer" {
  name = "quickwit-indexer-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "quickwit_indexer_lambda_basic" {
  role       = aws_iam_role.quickwit_indexer.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "quickwit_indexer_lambda_service" {
  name = "QuickwitIndexerLambdaService"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:GetObject*",
          "s3:GetBucket*",
          "s3:List*",
          "s3:DeleteObject*",
          "s3:PutObject",
          "s3:PutObjectLegalHold",
          "s3:PutObjectRetention",
          "s3:PutObjectTagging",
          "s3:PutObjectVersionTagging",
          "s3:Abort*"
        ],
        "Resource" : [
          "${aws_s3_bucket.quickwit_assets_bucket.arn}",
          "${aws_s3_bucket.quickwit_assets_bucket.arn}/*",
          "${aws_s3_bucket.quickwit_index_bucket.arn}",
          "${aws_s3_bucket.quickwit_index_bucket.arn}/*",
        ],
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "quickwit_indexer_lambda_service" {
  role       = aws_iam_role.quickwit_indexer.name
  policy_arn = aws_iam_policy.quickwit_indexer_lambda_service.arn
}
