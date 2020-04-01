# Free Monitoring Templates for Terraform

Setting up monitoring on AWS is hard. There are countless monitoring possibilities on AWS. Overlooking the important settings is easy. Monitoring Jump Starts connect you with all relevant AWS sources for comprehensive monitoring coverage.

Jump Starts are [CloudFormation templates](https://github.com/marbot-io/monitoring-jump-start) or Terraform modules that you can deploy to your AWS account to setup CloudWatch Alarms, CloudWatch Event Rules, and much more.

At the moment, you can monitor:

| Monitoring goal      | Terraform registry                                                             |
| -------------------- | ------------------------------------------------------------------------------ |
| AWS basics           | https://registry.terraform.io/modules/marbot-io/marbot-monitoring-basic        |
| Auto Scaling Group   | https://registry.terraform.io/modules/marbot-io/marbot-monitoring-asg          |
| EC2 instance         | https://registry.terraform.io/modules/marbot-io/marbot-monitoring-ec2-instance |
| RDS cluster (Aurora) | https://registry.terraform.io/modules/marbot-io/marbot-monitoring-rds-cluster  |
| SQS queue            | https://registry.terraform.io/modules/marbot-io/marbot-monitoring-sqs-queue    |

## Usage

> This example connects you to all relevant sources of errors, warnings, and notifications published by AWS services, and forwards them to Slack managed by marbot.

1. Create a new directory
2. Within the new directory, create a file `main.tf` with the following content:
```
provider "aws" {}

module "marbot-monitoring-basic" {
  source  = "marbot-io/marbot-monitoring-basic/aws"
  #version = "x.y.z"    # we recommend to pin the version

  endpoint_id      = "" # to get this value, select a Slack channel where marbot belongs to and send a message like this: "@marbot show me my endpoint id"
  budget_threshold = 10 # in USD (optional)
}
```
3. Run the following commands:
```
terraform init
terraform apply
```

## Update procedure

1. Update the modules's `version` to the latest version
2. Run the following commands:
```
terraform get
terraform apply
```

## License
All modules are published under Apache License Version 2.0.

## About
A [marbot.io](https://marbot.io/) project. Engineered by [widdix](https://widdix.net).
