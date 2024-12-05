# Packer Dynamic Provisioner

Demonstration of using `dynamic` for provisioners within Packer.

## How to Run

Set these Environment Variables for GCP:

```
# GCP Configuration
export GCP_ZONE="us-central1-a"
export GCP_PROJECT_ID=""
export GCP_CREDENTIALS_FILE=""
```

Run Packer:

```
packer init
packer build .
```

## How It Works

What we are trying to accomplish to have all the scripts in a folder get run without having to modify the `image.pkr.hcl` file everytime we add a file to the "scripts/" folder.

To do this we use the `dynamic` key word.

```
build {
  ... omitted for clarity

  dynamic "provisioner" {
    for_each = local.scripts

    labels = ["ansible"]
    content {
      playbook_file = "./scripts/${provisioner.value}"
      use_proxy     = false
    }
  }
}
```

Note the use of `labels`, this is required since the `provisioner` block requires a name.

To demonstrate this, the following two blocks are functionally equivalent.

```
build {
  ... omitted for clarity

  provisioner "ansible" {
    playbook_file = "./scripts/1_script.yml"
    use_proxy     = false
  }

  provisioner "ansible" {
    playbook_file = "./scripts/2_script.yml"
    use_proxy     = false
  }
}
```

```
build {
  ... omitted for clarity

  dynamic "provisioner" {
    for_each = ["1_script.yml", "2_script.yml"]

    labels = ["ansible"]
    content {
      playbook_file = "./scripts/${provisioner.value}"
      use_proxy     = false
    }
  }
}
```
