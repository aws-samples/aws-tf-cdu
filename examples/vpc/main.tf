module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = "${var.project}-${var.env_name}"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["10.0.128.0/18", "10.0.192.0/18"]
  public_subnets  = ["10.0.0.0/18", "10.0.64.0/18"]

  #VPN
  # enable_vpn_gateway                 = true
  # propagate_public_route_tables_vgw  = true
  # propagate_private_route_tables_vgw = true
  # customer_gateways = {
  #   IP1 = {
  #     bgp_asn     = 65000
  #     ip_address  = "54.172.100.66"
  #     device_name = "simulated_cgw"
  #   }
  # }

  enable_ipv6                     = var.enable_dual_stack
  assign_ipv6_address_on_creation = var.enable_dual_stack

  public_subnet_ipv6_prefixes  = var.enable_dual_stack ? [0, 1] : []
  private_subnet_ipv6_prefixes = var.enable_dual_stack ? [2, 3] : []

  public_subnet_assign_ipv6_address_on_creation  = var.enable_dual_stack
  private_subnet_assign_ipv6_address_on_creation = var.enable_dual_stack

  create_igw         = true
  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags  = var.vpc_public_subnet_tags
  private_subnet_tags = var.vpc_private_subnet_tags
  vpc_tags            = var.vpc_tags
  tags                = var.tags
}

resource "aws_route53_zone" "pvt_zone" {
  for_each = toset(var.r53_zone_names)

  name    = each.key
  comment = "Managed by Terraform for the project ${var.project}"

  force_destroy = true

  vpc {
    vpc_id = module.vpc.vpc_id
  }

  tags = var.tags
}
