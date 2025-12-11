output "macie_account_id" {
  description = "ID of the Macie account"
  value       = aws_macie2_account.main.id
}

output "dlp_findings_bucket" {
  description = "S3 bucket for DLP findings"
  value       = aws_s3_bucket.dlp_findings.id
}

output "pci_data_identifier_id" {
  description = "ID of the PCI data identifier"
  value       = aws_macie2_custom_data_identifier.pci_data.id
}

output "bank_account_identifier_id" {
  description = "ID of the bank account data identifier"
  value       = aws_macie2_custom_data_identifier.bank_account.id
}

output "ssn_identifier_id" {
  description = "ID of the SSN data identifier"
  value       = aws_macie2_custom_data_identifier.ssn.id
}