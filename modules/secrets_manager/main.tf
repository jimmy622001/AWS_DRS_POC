resource "aws_secretsmanager_secret" "secrets" {
  for_each = var.secrets
  
  name                    = "${var.prefix}-${each.key}"
  description             = "Secret for ${each.key}"
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-${each.key}"
    }
  )
}

resource "aws_secretsmanager_secret_version" "secret_values" {
  for_each = var.secrets
  
  secret_id     = aws_secretsmanager_secret.secrets[each.key].id
  secret_string = each.value
}