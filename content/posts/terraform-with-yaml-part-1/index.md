+++ 
date = 2023-01-02T16:08:13+01:00
title = "Terraform with YAML: Part 1"
tags = ["Google Cloud Platform", "Terraform", "YAML"]
+++

This post is the first in a series of three about supercharging your Terraform setup using YAML.

Infrastructure as Code (IaC) ...

## Why YAML?

One of the best properties of YAML in my opinition is the absence of syntax overhead.
It allows you to consicely write down parameters and values.
Let's look at a comparison of some Terraform (HCL) code and YAML where we configure some Google Pub/Sub topics and subscriptions:

```terraform
locals {
  config = {
    topics = [
      {
        name = "my-topic"
        labels = {
          environment = "prod"
        }
        subscriptions = [
          {
            name          = "my-subscription"
            push_endpoint = "https://example.com/push"
          }
        ]
      }
    ]
  }
}
```

```yaml
topics:
  - name: my-topic
    labels:
        environment: prod
    subscriptions:
      - name: my-subription
```

As you can see, the difference in number of lines is quite large.
Of course this will change once we add some HCL code to import the YAML configuration, but it quickly adds up when your infrastructure grows.

Loading and converting the YAML file to HCL is very easy.
You can do it in one line even using the `yamldecode` and `file` functions:

```terraform
locals {
  config = yamldecode(file("config.yaml"))
}
```

The result is an HCL represenation of the same data as shown in the earlier example.

For this particular example, the total number of lines of code using plain HCL is 18, of which 9 are purely syntax.
The total number of lines using YAML, including the loading and parsing of the file, is 9.
That's a 50% reduction!

For more information about YAML decoding in Terraform, check the [official documentation](https://developer.hashicorp.com/terraform/language/functions/yamldecode).

Another benefit of YAML over HCL is familiarity.
Many engineers that do not work on infrastructure are not familiar with the HCL syntax and it's quirks.
YAML on the other hand is so simple and widely used that almost every engineer has used it in their career at some point.
This means that if your repository contains YAML for infrastructure configuration, other types of engineers can easily adjust the configuration and deploy it (preferrably using a CI/CD pipeline and proper code review).
This provides a self-sufficient environment for application or data teams that work on top of the base infrastructure.

## A simple example

Let's build a fully working example:

```yaml
project:
  id: my-project-id
  region: europe-west4
bucket:
  name: example-bucket-123
  location: EU
  force_destroy: true
```

```terraform
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.47.0"
    }
  }
}

locals {
  config = yamldecode(file("config.yaml"))
}

provider "google" {
  project = config.project.id
  region  = config.project.region
}

resource "google_storage_bucket" "bucket" {
  name          = config.bucket.name
  location      = config.bucket.location
  force_destroy = config.bucket.force_destroy
}
```

In this example, we create and configure a Cloud Storage bucket.
We use two separate root objects (`project` and `bucket`) to keep the config tidy and readable.

## Using loops

Often we want to configure multiple resources, for example different storage buckets for different applications.
Let's adjust the example above to use a `for_each` loop:

```yaml
project:
  id: my-project-id
  region: europe-west4
buckets:
  - name: example-bucket-123
    location: EU
    force_destroy: true
  - name: example-bucket-456
    location: US
    force_destroy: false
```

```terraform
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.47.0"
    }
  }
}

locals {
  config = yamldecode(file("config.yaml"))
}

provider "google" {
  project = config.project.id
  region  = config.project.region
}

resource "google_storage_bucket" "bucket" {
  for_each = toset(config.buckets)

  name          = each.value.name
  location      = each.value.location
  force_destroy = each.value.force_destroy
}
```

As you can see, with minimal extra code, we can now provision as many buckets as we want.

## Up next

Now we have a basic understanding of the benefits of using YAML configuration files in your Terraform code.
In the next post in this series we will dive into more advanced topics, like how to deal with nested loops, creating multiple resource types from a single YAML configuration, and dynamic variable injection and templating.
