packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }

    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

locals {
  date           = formatdate("HHmm", timestamp())
  bucket_name    = "hashi-${local.os_name}"
  os_name        = "ubuntu-2204"
  gcp_image_name = join("-", [local.bucket_name, "gcp", local.os_name, local.date])

  common_tags = {
    os         = "ubuntu"
    os-version = "22_04"
    owner      = "platform-team"
    built-by   = "packer"
    build-date = local.date
  }

  build_tags = {
    build-time   = timestamp()
    build-source = basename(path.cwd)
  }

  # Get all scripts in the folder dynamically
  scripts = fileset("./scripts", "*.yml")
}

source "googlecompute" "ubuntu-lts" {
  project_id       = var.gcp_configuration.project_id
  zone             = var.gcp_configuration.zone
  credentials_file = var.gcp_configuration.credentials_file

  source_image = "ubuntu-2204-jammy-v20240614"
  ssh_username = "packer"

  image_storage_locations = ["us"]
  image_labels            = local.common_tags
}

build {
  name = "hashi-build"

  source "source.googlecompute.ubuntu-lts" {
    name       = "gcp-ubuntu"
    image_name = local.gcp_image_name
  }

  dynamic "provisioner" {
    for_each = local.scripts

    labels = ["ansible"]
    content {
      playbook_file = "./scripts/${provisioner.value}"
      use_proxy     = false
    }
  }
}