resource "aws_kms_key" "main" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  policy                  = var.key_policy

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-key"
    }
  )
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.prefix}-key"
  target_key_id = aws_kms_key.main.key_id
}