+++
date = 2022-09-16T08:41:01+01:00
title = "Creating a non-classic Google Cloud Global Load Balancer with Terraform"
tags = ["Google Cloud Platform", "Terraform"]
canonicalUrl = "https://xebia.com/blog/creating-a-non-classic-google-cloud-global-load-balancer-with-terraform/"
+++

The [Google Cloud Terraform Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs) has resources to configure a Global External HTTP(S) Load Balancer.
By default however this creates a [classic](https://cloud.google.com/load-balancing/docs/https#identifying_the_mode) load balancer, not a new one.
For new features like [traffic management](https://cloud.google.com/load-balancing/docs/https/traffic-management-global) you cannot use the classic load balancer, so you definitely want to use the new one.

The Google and Terraform documentation is not clear about how to do this properly.
The name `classic` does not even appear once on the documentation pages for the relevant resources.

A typical Global Load Balancing stack looks like this:

```terraform
resource "google_compute_global_address" "default" {
    ...
}

resource "google_compute_backend_service" "default" {
    ...
}

resource "google_compute_url_map" "default" {
    ...
}

resource "google_compute_target_http_proxy" "default" {
    ...
}

resource "google_compute_global_forwarding_rule" "default" {
    ...
}
```

In this stack, `google_compute_backend_service` is the load balancing back-end, and `google_compute_global_forwarding_rule` is the front-end.

In order to use a new load balancer, both the back-end and front-end need to have their `load_balancing_scheme` configured:

```terraform
resource "google_compute_backend_service" "default" {
    ...
    load_balancing_scheme = "EXTERNAL_MANAGED"
}

resource "google_compute_global_forwarding_rule" "default" {
    ...
    load_balancing_scheme = "EXTERNAL_MANAGED"
}
```

## Conclusion

Now you know how to create a non-classic Global Load Balancer in Google Cloud using Terraform.
The configuration is simple, but hard to find based on the available documentation.
