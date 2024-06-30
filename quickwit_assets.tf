locals {
  quickwit_lambda_indexer_filename  = "indexer/bootstrap.zip"
  quickwit_lambda_searcher_filename = "searcher/bootstrap.zip"
  quickwit_index_config_filename    = "index.yaml"
}

resource "terraform_data" "build_quickwit_lambda" {
  provisioner "local-exec" {
    command = "cd ${path.module}/quickwit/quickwit && cargo lambda build -p quickwit-lambda --disable-optimizations --release --output-format zip --target x86_64-unknown-linux-gnu"
  }
}

resource "aws_s3_bucket" "quickwit_assets_bucket" {
  bucket = "${data.aws_caller_identity.current.account_id}-quickwit-serverless-assets"
}

resource "aws_s3_object" "quickwit_lambda_indexer" {
  bucket = aws_s3_bucket.quickwit_assets_bucket.bucket
  key    = local.quickwit_lambda_indexer_filename
  source = "${path.module}/quickwit/quickwit/target/lambda/indexer/bootstrap.zip"

  depends_on = [terraform_data.build_quickwit_lambda]
}

resource "aws_s3_object" "quickwit_lambda_searcher" {
  bucket = aws_s3_bucket.quickwit_assets_bucket.bucket
  key    = local.quickwit_lambda_searcher_filename
  source = "${path.module}/quickwit/quickwit/target/lambda/searcher/bootstrap.zip"

  depends_on = [terraform_data.build_quickwit_lambda]
}

resource "aws_s3_object" "quickwit_index_config" {
  bucket = aws_s3_bucket.quickwit_assets_bucket.bucket
  key    = local.quickwit_index_config_filename
  source = "${path.module}/${local.quickwit_index_config_filename}"
}
