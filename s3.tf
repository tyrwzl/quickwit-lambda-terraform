resource "aws_s3_bucket" "quickwit_index_bucket" {
  bucket = "${data.aws_caller_identity.current.account_id}-quickwit-index"
}
