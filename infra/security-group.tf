module "http_security_group" {
  source  = "cloudposse/security-group/aws"
  version = "2.0.1"

  attributes = [local.config.sg_app_name]

  # Allow unlimited egress
  allow_all_egress = true

  rules = [
    local.config.app,
  ]
  vpc_id = module.vpc.vpc_id
  tags   = local.config.tags
}


module "app_security_group" {
  source  = "cloudposse/security-group/aws"
  version = "2.0.1"

  attributes = [local.config.sg_app_name]

  # Allow unlimited egress
  allow_all_egress = true

  rules = [
    local.config.app,
  ]
  vpc_id = module.vpc.vpc_id
  tags   = local.config.tags
}

module "db_security_group" {
  source  = "cloudposse/security-group/aws"
  version = "2.0.1"

  attributes = [local.config.sg_sql_name]

  # Allow unlimited egress
  allow_all_egress = true

  rules = [{
    key                      = local.config.sql.key
    type                     = local.config.sql.type
    from_port                = local.config.sql.from_port
    to_port                  = local.config.sql.to_port
    protocol                 = local.config.sql.protocol
    source_security_group_id = module.app_security_group.id
    self                     = local.config.sql.self
  }]
  vpc_id = module.vpc.vpc_id
  tags   = local.config.tags
}
