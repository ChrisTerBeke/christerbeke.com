+++
date = 2024-03-04T08:00:00+01:00
title = "tfversion"
tags = ["Open Source", "Terraform"]
+++

[tfversion](https://tfversion.xyz) is an open source Terraform version management tool.
As consultant in the field of Cloud and Infrastructure, we use multiple versions of Terraform on a daily basis.
We found that existing tools to easily switch between versions were not intuitive or maintained well.
So together with [Bruno Schaatsbergen](https://bschaatsbergen.com), we built our own.

The easiest way to get started with `tfversion` is using Homebrew:

```bash
brew install tfversion/tap/tfversion
```

Then you can run the following commands to install and use a version:

```bash
tfversion install 1.7.3

# better: put this in your `ZSH` or `Bash` profile
export PATH="$HOME/.tfversion/bin:$PATH"

tfversion use 1.7.3
```

A full usage guide can be found on the [official website](https://tfversion.xyz).
