# Vault enterprise starter module demo

This is an all-in-one demo (single terraform file) of our team's Vault Enterprise AWS example module.


## Structure
This module acts as a wrapper around three other modules:

1. The official Hashicorp [Vault Enterprise on AWS module](https://registry.terraform.io/modules/hashicorp/vault-ent-starter/aws/latest).
1. Hashicorp's example [AWS VPC](https://registry.terraform.io/modules/hashicorp/vault-ent-starter/aws/latest/examples/aws-vpc) module.
1. Hashicorp's example [AWS Secrets Manager / ACM Cert Setup](https://registry.terraform.io/modules/hashicorp/vault-ent-starter/aws/latest/examples/aws-secrets-manager-acm) module. 

The goal is to get an experimentation-ready Vault Enterprise environment up and running in AWS with a minimum of fuss.


## Instructions
First, make sure you're sitting in the main directory of this project:

`cd $THIS_REPO`

Initialize Terraform:

`terraform init`

### Create the VPC
`terraform plan --target module.aws-vpc`
`terraform apply --target module.aws-vpc`

### Create everything else
Now a terraform apply will work to get the rest of the infrastructure provisioned.
`terraform plan`
`terraform apply`


## Connect to a Vault instance
First, connect to your new cluster by opening the AWS console and choosing one of the Vault instances to connect to.

```
# I have a shell alias that automatically connects me to the AWS Console; you may do this differently:
awsconsole
```

When you've selected an instance, click "Connect" (top right) and use Session Manager, since these Vault instances are not in a public subnet.

A web-based shell window will open in your browser.


## Initialize your Vault Cluster

```
sudo -i
vault operator init
```

Copy the output of this command and store it securely (e.g. in a password manager) -- it contains recovery keys, along with your initial root token.

Run some vault commands with this token:

```
export VAULT_TOKEN="<your Vault token>"
vault operator raft list-peers

```

Provided that everything is working, you can expect to see output similar to
```
root@ip-10-0-50-226:~# vault operator raft list-peers
Node                   Address             State       Voter
----                   -------             -----       -----
i-0674d4863a900c3c8    10.0.50.226:8201    leader      true
i-04302cdfb11a4c1e5    10.0.67.65:8201     follower    true
i-07d85011d2ac72473    10.0.87.189:8201    follower    true
i-079e1d7b9af28e1b9    10.0.44.60:8201     follower    true
i-03bca2a7566af7dc2    10.0.15.141:8201    follower    true
```


### Autopilot Configuration

Check your current autopilot settings with `vault operator raft autopilot get-config`.

If you'd like to change any of the settings, e.g. [dead server cleanup](https://www.vaultproject.io/docs/concepts/integrated-storage/autopilot#dead-server-cleanup), you can do it now:

```
vault operator raft autopilot set-config \
    -cleanup-dead-servers=true \
    -dead-server-last-contact-threshold=10m \
    -min-quorum=3
```

## You're Done!
Congratulations; you've set up a production ready Vault cluster. Here are some additional resources to help you run Vault professionally:

* The [Vault Reference Architecture](https://learn.hashicorp.com/tutorials/vault/reference-architecture), which this module is an implementation of.
* [Vault Operations](https://learn.hashicorp.com/collections/vault/operations)
* [General Vault Learn Docs](https://learn.hashicorp.com/vault)


## Notes and Common Errors

### Enterprise Version

I've written this wrapper so that you can switch to setting up Vault Enterprise instead of the open-source version, if you like. If you want to do that, follow these steps:

1. Put at valid Vault Enterprise license file into the base directory of this repository (i.e. next to this README.md file), and call it `vault-ent.hclic`.
2. In `main.tf`, *uncomment* the 'enterprise' section in the module.vault-starter resource (lines 35-38)
3. In `main.tf`, *comment out* the 'open-source' section in the module.vault-starter resource (lines 40-42)
4. Run `terraform init` again (or rather, just follow the instructions from the beginning again).

----------------------------


### Staged Apply

If you don't plan/apply this in stages, you'll get the following error, since no subnets exist in the VPC before the VPC gets created, and Terraform's `for_each` doesn't trust us to supply data of the correct type:

```
Error: Invalid for_each argument
│
│   on .terraform/modules/vault-ent-starter/modules/vm/main.tf line 55, in data "aws_subnet" "subnet":
│   55:   for_each = toset(var.vault_subnets)
│     ├────────────────
│     │ var.vault_subnets is a list of string, known only after apply
│
│ The "for_each" value depends on resource attributes that cannot be determined until apply, so Terraform cannot predict how many
│ instances will be created. To work around this, use the -target argument to first apply only the resources that the for_each depends on.
╵
```