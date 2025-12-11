output "step_function_arn" {
  description = "ARN of the DR orchestration Step Function"
  value       = aws_sfn_state_machine.dr_orchestration.arn
}

output "recovery_event_rule_arn" {
  description = "ARN of the CloudWatch Event Rule for DR activation"
  value       = aws_cloudwatch_event_rule.dr_activation.arn
}

output "lambda_pre_recovery_checks_arn" {
  description = "ARN of the pre-recovery checks Lambda function"
  value       = aws_lambda_function.pre_recovery_checks.arn
}

output "lambda_post_recovery_validation_arn" {
  description = "ARN of the post-recovery validation Lambda function"
  value       = aws_lambda_function.post_recovery_validation.arn
}