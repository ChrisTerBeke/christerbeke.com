+++ 
date = 2023-07-14T08:00:00+01:00
title = "Terraform with YAML: Part 2"
tags = ["Google Cloud Platform", "Terraform", "YAML"]
canonicalUrl = "https://xebia.com/blog/terraform-with-yaml-part-2"
+++

> This post is the second in a series of three about supercharging your Terraform setup using YAML.

In part one of this series we learned how to use YAML to simplify the configuration of Terraform resources.
We mainly focussed on reducing syntax overhead of the HCL language and making the configuration accessible to non-infra engineers.

In this second part we will dive into some more advanced techniques and patterns.

## Dynamic blocks

A powerful feature of Terraform is [dynamic blocks](https://developer.hashicorp.com/terraform/language/expressions/dynamic-blocks).
They allow you to specify multiple nested blocks by looping over a set or map.

In the following example we add a lifecycle rule to a storage bucket that automatically deletes objects after 3 days.
We also add a lifecycle rule to automatically abort an incomplete upload after 1 day.

```terraform
resource "google_storage_bucket" "bucket" {
  name          = "my-awesome-bucket"
  location      = "EU"
  force_destroy = false

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 3
    }
  }

  lifecycle_rule {
    action {
      type = "AbortIncompleteMultipartUpload"
    }
    condition {
      age = 1
    }
  }
}
```

You can imagine that if we add even more lifecyle rules, the syntax of this resources becomes long and tedious to read.
Luckily we have dynamic blocks to relief some of our pain.

In the following example we use a dynamic block with a local map to apply the same lifecycle rules:

```terraform
locals {
    lifecycle_rules = {
        "Delete" = 3
        "AbortIncompleteMultipartUpload" = 1
    }
}

resource "google_storage_bucket" "bucket" {
  name          = "my-awesome-bucket"
  location      = "EU"
  force_destroy = false

  dynamic "lifecycle_rule" {
    for_each = local.lifecycle_rules

    content {
        action = {
            type = lifecycle_rule.key
        }
        condition {
            age = lifecycle_rule.value
        }
    }
  }
}
```

As you can see, the amount of boilerplate code is already significantly reduced.
Now let's apply our YAML magic to it and see what happens.

```yaml
bucket:
  name: example-bucket-123
  location: EU
  force_destroy: true
  lifecycle_rules:
    Delete: 3
    AbortIncompleteMultipartUpload: 1
```

```terraform
locals {
  config = yamldecode(file("config.yaml"))
}

resource "google_storage_bucket" "bucket" {
  name          = config.bucket.name
  location      = config.bucket.location
  force_destroy = config.bucket.force_destroy

  dynamic "lifecycle_rule" {
    for_each = config.bucket.lifecycle_rules

    content {
      action = {
        type = lifecycle_rule.key
      }
      condition {
        age = lifecycle_rule.value
      }
    }
  }
}
```

By specifying the actual rules in our YAML config file, it became very clear which rules we are enforcing on our bucket.

## Multiple resource types

Now let's see how we can define more than a single resource based on a YAML configuration file.
Here is an example of this for storage bucket IAM members:

```yaml
bucket:
  name: example-bucket-123
  location: EU
  force_destroy: true
  admins:
    - "group:storage-admins@company.com"
    - "user:john-break-glass@company.com"
```

```terraform
locals {
  config = yamldecode(file("config.yaml"))
}

resource "google_storage_bucket" "bucket" {
  name          = config.bucket.name
  location      = config.bucket.location
  force_destroy = config.bucket.force_destroy
}

resource "google_storage_bucket_iam_member" "admins" {
  for_each = toset(config.bucket.admins)

  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.admin"
  member = each.key
}
```

One pattern used here is to group configuration together in YAML and spread it out over multiple Terraform resources.
This reduces the amount of locations in the code you need to touch in order to change your infrastructure.

## Up next

Now we know the basics of YAML in Terraform, as well as some more advanced situation that it can be useful in.
In the next and final part of this series, we will dive into templating and schema validation.
We'll also have a quick look at how to automate the injection of YAML config files using Terragrunt.
