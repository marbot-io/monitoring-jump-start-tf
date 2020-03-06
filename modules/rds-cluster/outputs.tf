output "topic_name" {
  value = join("",aws_sns_topic.marbot.*.name)
}

output "topic_arn" {
  value = join("", aws_sns_topic.marbot.*.arn)
}
