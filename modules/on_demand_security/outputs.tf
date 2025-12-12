output "web_acl_id" {
  description = "ID of the WAF WebACL"
  value       = aws_wafv2_web_acl.dr_web_acl.id
}

output "web_acl_arn" {
  description = "ARN of the WAF WebACL"
  value       = aws_wafv2_web_acl.dr_web_acl.arn
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector"
  value       = aws_guardduty_detector.dr_detector.id
}

output "enable_security_lambda_arn" {
  description = "ARN of the Lambda function for enabling security services"
  value       = aws_lambda_function.enable_security_lambda.arn
}

output "disable_security_lambda_arn" {
  description = "ARN of the Lambda function for disabling security services"
  value       = aws_lambda_function.disable_security_lambda.arn
}