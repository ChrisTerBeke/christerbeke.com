+++ 
date = 2023-04-05T11:22:10+02:00
title = "Guarantee unique keys in Terraform"
tags = ["Terraform"]
+++

When using Terraform to dynamically create resources based on lists of maps you probaby have run into this issue.
Consider the following list of maps that represents IAM access on a generic cloud resource:

```hcl
locals = {
    members = [
        {
            member   = "contact@christerbeke.com"
            resource = "projects/12345"
            role     = "roles/owner"
        },
        {
            member   = "test@christerbeke.com"
            resource = "projects/12345"
            role     = "roles/reader"
        }
    ]
}
```

If we want to iterate over this list to create a dynamic amount of resources (using `for_each`) we need to convert it to a `map`.
However there is no way you can construct an map key from any of the separate attributes and guarantee uniqueness.
So how can we solve this?

The trick is to create a combination of all the attributes.
But simply concatenating all the attributes in a string results in very long keys.
To solve this, and get predictable key lengths, we can use an md5 hash:

```hcl
locals = {
    unique_members = { for key, member in local.members : md5("${member.member}/${member.resource}/${member.role}") => member }
}
```

This results in the following data:

```hcl
{
    "0f334c4500b1faab57203343199d5c86" = {
        member   = "contact@christerbeke.com"
        resource = "projects/12345"
        role     = "roles/owner"
    },
    "c02f629ef8bf2b413a203c4dcafa60c1" = {
        member   = "test@christerbeke.com"
        resource = "projects/12345"
        role     = "roles/reader"
    }
}
```

Now we can use it in our `for_each` iterator:

```hcl
resource "iam_member" "default" {
    for_each = local.unique_members

    member   = each.value.member
    resource = each.value.resource
    role     = each.value.role
}
```

Now you know a simple trick to convert a list of maps into an iterable map with unique keys.

As a bonus you now get alerted about duplicate list entries, as they would result in dulicate map keys causing Terraform to throw an error!
