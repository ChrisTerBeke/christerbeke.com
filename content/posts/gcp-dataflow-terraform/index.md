+++
date = 2022-07-28T08:41:01+01:00
title = "A declarative approach for Dataflow Flex Templates"
tags = ["Google Cloud Platform", "Terraform"]
original_url = "https://xebia.com/blog/a-declarative-approach-for-dataflow-flex-templates/"
+++

Google Cloud offers a managed Apache Beam solution called Dataflow.
Since some time now Dataflow has a feature called Flex Templates.
Flex Templates use Docker [containers](https://binx.io/2022/04/21/what-is-a-container/) instead of Dataflow's custom templates.
The benefit is that Docker is a known standard and the container can run in different environments.
However, a custom metadata JSON file is still needed to point to the Docker image in your registry.

> Both the CLI and the Terraform approach require you to push the Docker image to a registry.

## Using the gcloud CLI

To generate and upload the JSON file you can run `gcloud dataflow flex-template build`.
The input for this command is a bit of JSON that defines the pipeline name and parameters:

```json
{
    "name": "My Apache Beam pipeline",
    "parameters": [
        {
            "name": "output_table",
            "label": "BigQuery output table name.",
            "helpText": "Name of the BigQuery output table name.",
            "regexes": ["([^:]+:)?[^.]+[.].+"]
        }
    ]
}
```

Let's see what is in Cloud Storage after running the command:

```json
{
    "image": "eu-docker.pkg.dev/my-gcp-project-id/dataflow-templates/example:latest",
    "sdkInfo": {
        "language": "PYTHON"
    },
    "metadata": {
        "name": "My Apache Beam pipeline",
        "parameters": [
            {
                "name": "output_table",
                "label": "BigQuery output table name.",
                "helpText": "Name of the BigQuery output table name.",
                "regexes": ["([^:]+:)?[^.]+[.].+"]
            }
        ]
    }
}
```

The command only adds the Docker image location and some Beam SDK before uploading it to Cloud Storage.

## Using Terraform

While this works fine, it goes against the declarative approach of Terraform and other infrastructure as code tools.
Let's see what it takes to generate and manage this metadata JSON file in Terraform:

```terraform
resource "google_storage_bucket_object" "flex_template_metadata" {
    bucket       = "my-unique-bucket"
    name         = "dataflow-templates/example/metadata.json"
    content_type = "application/json"

    content = jsonencode({
        image = "eu-docker.pkg.dev/my-gcp-project-id/dataflow-templates/example:latest"
        sdkInfo = {
            language = "PYTHON"
        }
        metadata = {
            name = "My Apache Beam pipeline"
            parameters = [
                {
                    name = "output_table"
                    label = "BigQuery output table name."
                    helpText = "Name of the BigQuery output table name.",
                    regexes = ["([^:]+:)?[^.]+[.].+"]
                }
            ]
        }
    })
}
```

We can reference the storage file path in our Flex Template job:

```terraform
resource "google_dataflow_flex_template_job" "flex_template_job" {
    provider = google-beta

    name                    = "example_pipeline"
    region                  = "europe-west4"
    container_spec_gcs_path = "gs://${google_storage_bucket_object.flex_template_metadata.bucket}/${google_storage_bucket_object.flex_template_metadata.name}"

    parameters = {
        output_table = "my-gcp-project-id/example_dataset/example_table"
    }
}
```

Run `terraform apply` to create both the template file and the Dataflow job.

## Updating the Dataflow job

We have one issue remaining.
A change in the template data does not trigger an update of the Dataflow job.
For this to work, we need an attribute on the Dataflow job resource to change.
We can do this by including an MD5 hash of the file contents in the storage path:

```terraform
locals {
    template_content = jsonencode({
        image = "eu-docker.pkg.dev/my-gcp-project-id/dataflow-templates/example:latest"
        sdkInfo = {
            language = "PYTHON"
        }
        metadata = {
            name = "My Apache Beam pipeline"
            parameters = [
                {
                    name = "output_table"
                    label = "BigQuery output table name."
                    helpText = "Name of the BigQuery output table name.",
                    regexes = ["([^:]+:)?[^.]+[.].+"]
                }
            ]
        }
    })
    template_gcs_path = "dataflow-templates/example/${base64encode(md5(local.template_content))}/metadata.json"
}

resource "google_storage_bucket_object" "flex_template_metadata" {
    bucket = "my-unique-bucket"
    name   = local.template_gcs_path
    ...
}
```

A change in the template data will trigger a change in the MD5 hash.
This will trigger a change in the template storage path that we also reference in the Dataflow job resource.
Running `terraform apply` now correctly updates both the JSON data in storage as well as the Dataflow flex job.
If you are using a batch mode it will create a new job instance.

## Conclusion

Dataflow Flex Templates allow you to use Docker images Dataflow jobs.
A `gcloud` CLI command is required to build and upload some JSON metadata.
We can replicate this behavior using Terraform code.
This allows for a 100% declarative infrastructure-as-code solution.

For a full code example, check my Dataflow Flex Terraform module on [GitHub](https://github.com/ChrisTerBeke/terraform-playground/tree/main/terraform/modules/gcp_dataflow_flex).

This post [originally appeared on Binx.io](https://binx.io/2022/07/28/a-declarative-approach-for-dataflow-flex-templates/).
