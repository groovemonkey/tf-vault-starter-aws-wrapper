# Quickly set up a vault enterprise deployment in AWS, using the official Hashicorp vault-enterprise module and its VPC/ACM/ASM example modules.

# 1. Create a new VPC to use for this infrastructure
module "aws-vpc" {
  source  = "hashicorp/vault-ent-starter/aws//examples/aws-vpc"
  version = "0.1.2"

  # required variables
  aws_region           = var.aws_region
  azs                  = var.azs
  resource_name_prefix = var.resource_name_prefix
  private_subnet_tags  = var.private_subnet_tags
}
// OUTPUTS
//   private_subnet_tags
//   vpc_id 

# 2. Create ACM certs and manage via AWS Secrets Manager
module "aws-secrets-manager-acm" {
  source  = "hashicorp/vault-ent-starter/aws//examples/aws-secrets-manager-acm"
  version = "0.1.2"

  # required variables
  aws_region           = var.aws_region
  resource_name_prefix = var.resource_name_prefix

}
// OUTPUTS
//     lb_certificate_arn
//     leader_tls_servername
//     secrets_manager_arn

# 3. Instantiate the Vault Enterprise module!
module "vault-starter" {
  # # Vault Enterprise: uncomment this section
  # source  = "hashicorp/vault-ent-starter/aws"
  # version = "0.1.2"
  # vault_license_filepath = "./vault-ent.hclic"

  # Vault open-source: uncomment this section
  source  = "hashicorp/vault-starter/aws"
  version = "1.0.0"

  resource_name_prefix = var.resource_name_prefix
  private_subnet_tags  = module.aws-vpc.private_subnet_tags

  # Required variables from VPC example module
  vpc_id = module.aws-vpc.vpc_id

  # Required variables from ACM example module
  leader_tls_servername = module.aws-secrets-manager-acm.leader_tls_servername
  secrets_manager_arn   = module.aws-secrets-manager-acm.secrets_manager_arn
  lb_certificate_arn    = module.aws-secrets-manager-acm.lb_certificate_arn

  ## Really nice features
  # user_supplied_ami_id
  # user_supplied_iam_role_name
  # user_supplied_userdata_path
}



