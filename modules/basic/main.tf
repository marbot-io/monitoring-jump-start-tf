terraform {
  required_providers {
    aws = ">= 2.48.0"
  }
}

provider "aws" {}

data "aws_caller_identity" "default" {}



##########################################################################
#                                                                        #
#                                 TOPIC                                  #
#                                                                        #
##########################################################################

resource "aws_sns_topic" "default" {
}

resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.default.arn
  policy = data.aws_iam_policy_document.topic_policy.json
}

data "aws_iam_policy_document" "topic_policy" {
  statement {
    sid     = "Sid1"
    effect  = "Allow"
    actions = ["sns:Publish"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com", "budgets.amazonaws.com", "rds.amazonaws.com", "s3.amazonaws.com", "backup.amazonaws.com"]
    }
    resources = [aws_sns_topic.default.arn]
  }
  statement {
    sid     = "Sid2"
    effect  = "Allow"
    actions = ["sns:Publish"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [aws_sns_topic.default.arn]
    condition {
      test = "StringEquals"
      variable = "AWS:SourceOwner"
      values= [
        data.aws_caller_identity.default.account_id
      ]
    }
  }
  statement {
    sid     = "Sid3"
    effect  = "Allow"
    actions = ["sns:Publish"]
    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }
    resources = [aws_sns_topic.default.arn]
    condition {
      test = "StringEquals"
      variable = "AWS:Referer"
      values= [
        data.aws_caller_identity.default.account_id
      ]
    }
  }
}

resource "aws_sns_topic_subscription" "default" {
  depends_on = [aws_sns_topic_policy.default]
  topic_arn = aws_sns_topic.default.arn
  protocol = "https"
  endpoint = "https://api.marbot.io/${var.stage}/endpoint/${var.endpoint_id}"
  endpoint_auto_confirms = true
  delivery_policy = <<JSON
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
#                                 EVENTS                                 #
#                                                                        #
##########################################################################

resource "aws_cloudwatch_event_rule" "root_user_login" {
  depends_on = [aws_sns_topic_subscription.default]
  description = "A root user login was detected, better use IAM users instead (created by marbot)."
  event_pattern = <<JSON
{
  "detail-type": [
    "AWS Console Sign In via CloudTrail"
  ],
  "detail": {
    "userIdentity": {
      "arn": [
        "arn:aws:iam::${data.aws_caller_identity.default.account_id}:root"
      ]
    }
  }
}
JSON
}

resource "aws_cloudwatch_event_target" "root_user_login" {
  rule      = aws_cloudwatch_event_rule.root_user_login.name
  target_id = "marbot"
  arn       = aws_sns_topic.default.arn
}



# TODO CloudWatchAlarmFiredEvent
# TODO CloudWatchAlarmOrphanedEvent
# TODO CloudWatchAlarmAutoCloseEvent



resource "aws_cloudwatch_event_rule" "batch_failed" {
  depends_on = [aws_sns_topic_subscription.default]
  description = "A Batch job failed (created by marbot)."
  event_pattern = <<JSON
{
  "source": [ 
    "aws.batch"
  ],
  "detail-type": [
    "Batch Job State Change"
  ],
  "detail": {
    "status": [
      "FAILED"
    ]
  }
}
JSON
}

resource "aws_cloudwatch_event_target" "batch_failed" {
  rule      = aws_cloudwatch_event_rule.batch_failed.name
  target_id = "marbot"
  arn       = aws_sns_topic.default.arn
}



resource "aws_cloudwatch_event_rule" "code_pipeline_failed" {
  depends_on = [aws_sns_topic_subscription.default]
  description = "A CodePipeline execution failed (created by marbot)."
  event_pattern = <<JSON
{
  "source": [ 
    "aws.codepipeline"
  ],
  "detail-type": [
    "CodePipeline Pipeline Execution State Change"
  ],
  "detail": {
    "state": [
      "FAILED"
    ]
  }
}
JSON
}

resource "aws_cloudwatch_event_target" "code_pipeline_failed" {
  rule      = aws_cloudwatch_event_rule.code_pipeline_failed.name
  target_id = "marbot"
  arn       = aws_sns_topic.default.arn
}



resource "aws_cloudwatch_event_rule" "code_pipeline_notifications" {
  depends_on = [aws_sns_topic_subscription.default]
  description = "CodePipeline notifications (created by marbot)."
  event_pattern = <<JSON
{
  "source": [ 
    "aws.codepipeline"
  ],
  "detail-type": [
    "CodePipeline Stage Execution State Change"
  ],
  "detail": {
    "state": [
      "SUCCEEDED"
    ]
  }
}
JSON
}

resource "aws_cloudwatch_event_target" "code_pipeline_notifications" {
  rule      = aws_cloudwatch_event_rule.code_pipeline_notifications.name
  target_id = "marbot"
  arn       = aws_sns_topic.default.arn
}



resource "aws_cloudwatch_event_rule" "code_build_failed" {
  depends_on = [aws_sns_topic_subscription.default]
  description = "A CodeBuild build failed (created by marbot)."
  event_pattern = <<JSON
{
  "source": [ 
    "aws.codebuild"
  ],
  "detail-type": [
    "CodeBuild Build State Change"
  ],
  "detail": {
    "build-status": [
      "FAILED"
    ]
  }
}
JSON
}

resource "aws_cloudwatch_event_target" "code_build_failed" {
  rule      = aws_cloudwatch_event_rule.code_build_failed.name
  target_id = "marbot"
  arn       = aws_sns_topic.default.arn
}



resource "aws_cloudwatch_event_rule" "code_deploy_failed" {
  depends_on = [aws_sns_topic_subscription.default]
  description = "A CodeDeploy deployment or instance failed (created by marbot)."
  event_pattern = <<JSON
{
  "source": [ 
    "aws.codedeploy"
  ],
  "detail-type": [
    "CodeDeploy Deployment State-change Notification",
    "CodeDeploy Instance State-change Notification"
  ],
  "detail": {
    "state": [
      "FAILURE"
    ]
  }
}
JSON
}

resource "aws_cloudwatch_event_target" "code_deploy_failed" {
  rule      = aws_cloudwatch_event_rule.code_deploy_failed.name
  target_id = "marbot"
  arn       = aws_sns_topic.default.arn
}



resource "aws_cloudwatch_event_rule" "health_issue" {
  depends_on = [aws_sns_topic_subscription.default]
  description = "AWS is experiencing events that may impact you (created by marbot)."
  event_pattern = <<JSON
{
  "source": [ 
    "aws.health"
  ],
  "detail-type": [
    "AWS Health Event"
  ],
  "detail": {
    "eventTypeCategory": [
      "issue",
      "scheduledChange"
    ]
  }
}
JSON
}

resource "aws_cloudwatch_event_target" "health_issue" {
  rule      = aws_cloudwatch_event_rule.health_issue.name
  target_id = "marbot"
  arn       = aws_sns_topic.default.arn
}



resource "aws_cloudwatch_event_rule" "auto_scaling_failed" {
  depends_on = [aws_sns_topic_subscription.default]
  description = "EC2 Instances controlled by an Auto Scaling Group failed to launch or terminate (created by marbot)."
  event_pattern = <<JSON
{
  "source": [ 
    "aws.autoscaling"
  ],
  "detail-type": [
    "EC2 Instance Launch Unsuccessful",
    "EC2 Instance Terminate Unsuccessful"
  ]
}
JSON
}

resource "aws_cloudwatch_event_target" "auto_scaling_failed" {
  rule      = aws_cloudwatch_event_rule.auto_scaling_failed.name
  target_id = "marbot"
  arn       = aws_sns_topic.default.arn
}




resource "aws_cloudwatch_event_rule" "guard_duty_finding" {
  depends_on = [aws_sns_topic_subscription.default]
  description = "Findings from AWS GuardDuty (created by marbot)."
  event_pattern = <<JSON
{
  "source": [ 
    "aws.guardduty"
  ],
  "detail-type": [
    "GuardDuty Finding"
  ]
}
JSON
}

resource "aws_cloudwatch_event_target" "guard_duty_finding" {
  rule      = aws_cloudwatch_event_rule.guard_duty_finding.name
  target_id = "marbot"
  arn       = aws_sns_topic.default.arn
}



resource "aws_cloudwatch_event_rule" "emr_failed" {
  depends_on = [aws_sns_topic_subscription.default]
  description = "EMR step or auto scaling policy failed (created by marbot)."
  event_pattern = <<JSON
{
  "source": [ 
    "aws.emr"
  ],
  "detail-type": [
    "EMR Auto Scaling Policy State Change",
    "EMR Step Status Change"
  ],
  "detail": {
    "state": [
      "FAILED"
    ]
  }
}
JSON
}

resource "aws_cloudwatch_event_target" "emr_failed" {
  rule      = aws_cloudwatch_event_rule.emr_failed.name
  target_id = "marbot"
  arn       = aws_sns_topic.default.arn
}



resource "aws_cloudwatch_event_rule" "ebs_failed" {
  depends_on = [aws_sns_topic_subscription.default]
  description = "EBS snapshot failed (created by marbot)."
  event_pattern = <<JSON
{
  "source": [ 
    "aws.ec2"
  ],
  "detail-type": [
    "EBS Snapshot Notification",
    "EBS Multi-Volume Snapshots Completion Status"
  ],
  "detail": {
    "result": [
      "failed"
    ]
  }
}
JSON
}

resource "aws_cloudwatch_event_target" "ebs_failed" {
  rule      = aws_cloudwatch_event_rule.ebs_failed.name
  target_id = "marbot"
  arn       = aws_sns_topic.default.arn
}



resource "aws_cloudwatch_event_rule" "ssm_failed" {
  depends_on = [aws_sns_topic_subscription.default]
  description = "SSM maintenance window execution failed (created by marbot)."
  event_pattern = <<JSON
{
  "source": [ 
    "aws.ssm"
  ],
  "detail-type": [
    "Maintenance Window Execution State-change Notification"
  ],
  "detail": {
    "status": [
      "FAILED",
      "TIMED_OUT"
    ]
  }
}
JSON
}

resource "aws_cloudwatch_event_target" "ssm_failed" {
  rule      = aws_cloudwatch_event_rule.ssm_failed.name
  target_id = "marbot"
  arn       = aws_sns_topic.default.arn
}



# TODO RDSInstanceIssue
# TODO RDSClusterIssue



resource "aws_cloudwatch_event_rule" "glue_job_failed" {
  depends_on = [aws_sns_topic_subscription.default]
  description = "Glue job failed (created by marbot)."
  event_pattern = <<JSON
{
  "source": [ 
    "aws.glue"
  ],
  "detail-type": [
    "Glue Job State Change"
  ],
  "detail": {
    "state": [
      "FAILED",
      "TIMEOUT"
    ]
  }
}
JSON
}

resource "aws_cloudwatch_event_target" "glue_job_failed" {
  rule      = aws_cloudwatch_event_rule.glue_job_failed.name
  target_id = "marbot"
  arn       = aws_sns_topic.default.arn
}


# TODO continue with EC2SpotInstanceInterruptionEvent
