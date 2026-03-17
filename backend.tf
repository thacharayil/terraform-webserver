terraform {
  backend "s3" {
    bucket = "git-terraform-state.thacharayil.space"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}
