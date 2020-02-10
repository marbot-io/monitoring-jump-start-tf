# Free Monitoring Templates for Terraform
Setting up monitoring on AWS is hard. There are countless monitoring possibilities on AWS. Overlooking the important settings is easy. Monitoring Jump Starts connect you with all relevant AWS sources for comprehensive monitoring coverage.

Jump Starts are [CloudFormation templates](https://github.com/marbot-io/monitoring-jump-start) or [Terraform modules](https://github.com/marbot-io/monitoring-jump-start-tf) that you can deploy to your AWS account to setup CloudWatch Alarms, CloudWatch Event Rules, and much more.

At the moment, you can monitor:

| Monitoring goal | Module Source                                                                   |
| --------------- | ------------------------------------------------------------------------------- |
| AWS basics      | `git::https://github.com/marbot-io/monitoring-jump-start-tf.git//modules/basic` |

> **Public beta**: This project is work in progress. If you are looking for a stable soltuion, we recommend our Jump Starts based on [CloudFormation templates](https://github.com/marbot-io/monitoring-jump-start).

## Usage

1. Create a new directory
2. Within the new directory, create a file `main.tf` with the following content:
```
module "basic" {
  source = "git::https://github.com/marbot-io/monitoring-jump-start-tf.git//modules/basic"

  endpoint_id = "" # to get this value: select a Slack channel where marbot belongs to and send a message like this: "@marbot show me my endpoint id"
}
```
3. Run the following commands:
```
terraform init
terraform apply
```

## License
All templates are published under Apache License Version 2.0.

## About
A [marbot.io](https://marbot.io/) project. Engineered by [widdix](https://widdix.net).
