output "survey_runner_launcher_address" {
  value = "https://${aws_route53_record.survey_launcher.fqdn}"
}
