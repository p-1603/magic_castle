terraform {
  required_version = ">= 1.2.1"
}

module "ovh" {
  source         = "git::https://github.com/ComputeCanada/magic_castle.git//ovh"
  config_git_url = "https://github.com/ComputeCanada/puppet-magic_castle.git"
  config_version = "main"

  cluster_name = "phoenix"
  domain       = "calculquebec.cloud"
  image        = "Rocky Linux 8"

  instances = {
    mgmt   = { type = "s1-2", tags = ["puppet", "mgmt", "nfs"], count = 1 }
    login  = { type = "s1-2", tags = ["login", "public", "proxy"], count = 1 }
    node   = { type = "s1-2", tags = ["node"], count = 1 }
  }

  volumes = {
    nfs = {
      home     = { size = 10 }
      project  = { size = 50 }
      scratch  = { size = 50 }
    }
  }
  public_keys = [file("~/.ssh/id_rsa.pub")]

  nb_users     = 10
  # Shared password, randomly chosen if blank
  guest_passwd = ""

}

output "accounts" {
  value = module.ovh.accounts
}

output "public_ip" {
  value = module.ovh.public_ip
}

## Uncomment to register your domain name with CloudFlare
# module "dns" {
#   source           = "git::https://github.com/ComputeCanada/magic_castle.git//dns/cloudflare"
#   email            = "you@example.com"
#   name             = module.ovh.cluster_name
#   domain           = module.ovh.domain
#   public_instances = module.ovh.public_instances
#   ssh_private_key  = module.ovh.ssh_private_key
#   sudoer_username  = module.ovh.accounts.sudoer.username
# }

## Uncomment to register your domain name with Google Cloud
# module "dns" {
#   source           = "git::https://github.com/ComputeCanada/magic_castle.git//dns/gcloud"
#   email            = "you@example.com"
#   project          = "your-project-id"
#   zone_name        = "you-zone-name"
#   name             = module.ovh.cluster_name
#   domain           = module.ovh.domain
#   public_instances = module.ovh.public_instances
#   ssh_private_key  = module.ovh.ssh_private_key
#   sudoer_username  = module.ovh.accounts.sudoer.username
# }

# output "hostnames" {
#   value = module.dns.hostnames
# }