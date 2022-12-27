# terraform {
#   backend "remote" {
#     organization = "project-terraform"

#     workspaces {
#       name = "2Tier-dev"
#     }
#   }
# }

terraform {
  cloud {
    organization = "terraformpract_22"

    workspaces {
      name = "terraform_twotier"
    }
  }
}

