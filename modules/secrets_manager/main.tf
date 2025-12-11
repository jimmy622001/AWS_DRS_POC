# Create a list of secret names for use in count
locals {
  secret_names_list = keys(var.secrets)
  secret_count = length(local.secret_names_list)
}

resource "aws_secretsmanager_secret" "secrets" {
  count = local.secret_count

  name                    = "${var.prefix}-${local.secret_names_list[count.index]}"
  description             = "Secret for ${local.secret_names_list[count.index]}"
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-${local.secret_names_list[count.index]}"
    }
  )
}

resource "aws_secretsmanager_secret_version" "secret_values" {
  count = local.secret_count

  secret_id     = aws_secretsmanager_secret.secrets[count.index].id
  secret_string = var.secrets[local.secret_names_list[count.index]]
}