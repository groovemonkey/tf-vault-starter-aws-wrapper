# Important (or shared) variables for the Vault module and the required example/prerequisite modules

variable "aws_region" {
    type = string
    description = "The AWS region you want your region-specific resources provisioned in."
    default = "us-west-2"
}

variable "azs" {
    type = list(string)
    description = "A valid list of Availability Zones (AZs) to deploy your regional resources into."
    default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "resource_name_prefix" {
    type = string
    description = "all of your resources will have their identifiers prefixed with this string, so you can tell them apart."
    default = "tutorialinux"
}

variable "private_subnet_tags" {
    type = map(string)
    description = "Explicitly passing in the subnet tags that we'll deploy Vault into, so that both the VPC prereq module and the vault-ent module have the same data and don't depend on each other."
    default = { "Vault": "deploy" }
}
