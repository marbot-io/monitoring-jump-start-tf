variable "endpoint_id" {
  type        = string
  description = "Your marbot endpoint ID (to get this value: select a Slack channel where marbot belongs to and send a message like this: \"@marbot show me my endpoint id\")."
}

variable "enabled" {
  type        = bool
  description = "Turn the module on or off"
  default     = true
}

variable "stage" {
  type        = string
  description = "marbot stage (never change this!)."
  default     = "v1"
}

variable "db_cluster_identifier" {
  type        = string
  description = "The cluster identifier of the RDS Aurora cluster that you want to monitor."
}

variable "cpu_utilization_threshold" {
  type        = number
  description = "The maximum percentage of CPU utilization."
  default     = 80
}

variable "cpu_credit_balance_threshold" {
  type        = number
  description = "The minimum number of CPU credits (t2 instances only) available."
  default     = 20
}

variable "freeable_memory_threshold" {
  type        = number
  description = "The minimum amount of available random access memory in Byte."
  default     = 64000000 # 64 Megabyte in Byte
}
