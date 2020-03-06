terraform {
  required_providers {
    aws = ">= 2.48.0"
  }
}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

##########################################################################
#                                                                        #
#                                 TOPIC                                  #
#                                                                        #
##########################################################################

resource "aws_sns_topic" "marbot" {
  count = var.enabled ? 1 : 0
}

resource "aws_sns_topic_policy" "marbot" {
  count  = var.enabled ? 1 : 0
  arn    = join("", aws_sns_topic.marbot.*.arn)
  policy = data.aws_iam_policy_document.topic_policy.json
}

data "aws_iam_policy_document" "topic_policy" {
  statement {
    sid       = "Sid1"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [join("", aws_sns_topic.marbot.*.arn)]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "rds.amazonaws.com",
      ]
    }
  }

  statement {
    sid       = "Sid2"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [join("", aws_sns_topic.marbot.*.arn)]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_sns_topic_subscription" "marbot" {
  count      = var.enabled ? 1 : 0
  depends_on = [aws_sns_topic_policy.marbot]

  topic_arn              = join("", aws_sns_topic.marbot.*.arn)
  protocol               = "https"
  endpoint               = "https://api.marbot.io/${var.stage}/endpoint/${var.endpoint_id}"
  endpoint_auto_confirms = true
  delivery_policy        = <<JSON
{
  "healthyRetryPolicy": {
    "minDelayTarget": 1,
    "maxDelayTarget": 60,
    "numRetries": 100,
    "numNoDelayRetries": 0,
    "backoffFunction": "exponential"
  },
  "throttlePolicy": {
    "maxReceivesPerSecond": 1
  }
}
JSON
}

##########################################################################
#                                                                        #
#                                 ALARMS                                 #
#                                                                        #
##########################################################################

resource "random_id" "id8" {
  byte_length = 8
}



resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  count      = var.enabled ? 1 : 0
  depends_on = [aws_sns_topic_subscription.marbot]

  alarm_name          = "marbot-cpu-utilization-${random_id.id8.hex}"
  alarm_description   = "Average database CPU utilization over last 10 minutes too high (created by marbot)."
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 600
  evaluation_periods  = 1
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.cpu_utilization_threshold
  alarm_actions       = [join("", aws_sns_topic.marbot.*.arn)]
  ok_actions          = [join("", aws_sns_topic.marbot.*.arn)]
  dimensions = {
    DBClusterIdentifier = var.db_cluster_identifier
  }
  treat_missing_data = "notBreaching"
}



resource "aws_cloudwatch_metric_alarm" "cpu_credit_balance" {
  count      = var.enabled ? 1 : 0
  depends_on = [aws_sns_topic_subscription.marbot]

  alarm_name          = "marbot-cpu-credit-balance-${random_id.id8.hex}"
  alarm_description   = "Average database CPU credit balance over last 10 minutes too low, expect a significant performance drop soon (created by marbot)."
  namespace           = "AWS/RDS"
  metric_name         = "CPUCreditBalance"
  statistic           = "Average"
  period              = 600
  evaluation_periods  = 1
  comparison_operator = "LessThanThreshold"
  threshold           = var.cpu_credit_balance_threshold
  alarm_actions       = [join("", aws_sns_topic.marbot.*.arn)]
  ok_actions          = [join("", aws_sns_topic.marbot.*.arn)]
  dimensions = {
    DBClusterIdentifier = var.db_cluster_identifier
  }
  treat_missing_data = "notBreaching"
}



resource "aws_cloudwatch_metric_alarm" "freeable_memory" {
  count      = var.enabled ? 1 : 0
  depends_on = [aws_sns_topic_subscription.marbot]

  alarm_name          = "marbot-freeable-memory-${random_id.id8.hex}"
  alarm_description   = "Average database freeable memory over last 10 minutes too low, performance may suffer (created by marbot)."
  namespace           = "AWS/RDS"
  metric_name         = "FreeableMemory"
  statistic           = "Average"
  period              = 600
  evaluation_periods  = 1
  comparison_operator = "LessThanThreshold"
  threshold           = var.freeable_memory_threshold
  alarm_actions       = [join("", aws_sns_topic.marbot.*.arn)]
  ok_actions          = [join("", aws_sns_topic.marbot.*.arn)]
  dimensions = {
    DBClusterIdentifier = var.db_cluster_identifier
  }
  treat_missing_data = "notBreaching"
}

##########################################################################
#                                                                        #
#                                 EVENTS                                 #
#                                                                        #
##########################################################################

resource "aws_db_event_subscription" "rds_cluster_issue" {
  count      = var.enabled ? 1 : 0
  depends_on = [aws_sns_topic_subscription.marbot]

  sns_topic   = join("", aws_sns_topic.marbot.*.arn)
  source_type = "db-cluster"
  source_ids  = [var.db_cluster_identifier]
}
