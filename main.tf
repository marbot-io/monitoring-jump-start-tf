module "basic" {
  source      = "./modules/basic"

  endpoint_id = var.endpoint_id
  stage       = var.stage
  test        = var.test
}
