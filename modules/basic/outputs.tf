output "topic_name" {
  value = aws_sns_topic.default.name
}

output "topic_arn" {
  value = aws_sns_topic.default.arn
}
