# Syzygy Infrastructure

This repository contains the ansible and terraform code for managing
infrastructure within the [syzygy project](http://syzygy.ca). It shares a very
close relationship with
[callysto/infrastructure](https://github.com/callysto/infrastructure) and may
one day be replaced by it. In part, the callysto infrastructure code grew out of
the syzygy code, but
[callysto/infrastrucure](https://github.com/callysto/infrastructure) has greatly
expanded and improved the code base (due largely to the efforts of Joe Topjian
<joe.topjian@cybera.ca> and Andrew Klaus <andrew.klaus@cybera.ca>).  New
development generally takes place in callysto and is then backported to syzygy.


## OpenStack

The Syzygy infrastructure is intended to be portable and to run almost anywhere
a suitable virtual machine can be defined. That said, development takes place
almost exclusively on OpenStack and so there may be some cases where OpenStack
is assumed. In particular the current terraform setup assumes OpenStack as a
provider and would need to be translated for use with other providers. The
ansible playbooks and roles should be more general.

## Packer

Packer may be used to create OpenStack images with pre-installed packages and
settings. This is to help reduce the amount of time it takes to build dev and CI
environments.

### Binaries

The `./packer/bin` directory contains the binaries required to run Packer.
These binaries are bundled in this repository to ensure all project members are
using the same version.

### Makefile

The `./packer/Makefile` provides an easy way to interact with Packer to create
images.

For example, to create the base hub image:

```
  $ make build/hub
```

> Note: review the `Makefile` and Packer build files to ensure their settings
> are appropriate for your environment.

## Terraform

The resources are controlled by terraform so we can destroy and recreate
everything quickly.

All Terraform-related files are stored in the `./terraform` directory.

### Binaries

The `./terraform/bin` directory contains the binaries required to run Terraform.
These binaries are bundled in this repository to ensure all project members are
using the same version.

### Modules

Terraform modules are stored in `./terraform/modules`. The following modules
are defined:

  * `hub`: deploys a standard Syzygy JupyterHub environment.

### Makefile

The `./terraform/Makefile` provides an easy way to interact with Terraform to
deploy and manage infrastructure.

For example, to redeploy the `hub-dev` environment, do

```
  $ make destroy env=hub-dev
  $ make apply env=hub-dev
```

This will use the Terraform binary in `./bin` to apply the Terraform configuration
defined in `./terraform/hub-dev`.

The `Makefile` arguments correspond to the common Terraform commands: `plan`, `apply`,
`destroy`, etc.

The `Makefile` is only a convenience and it is not required. If you want to use Terraform
directly, simply do:

```
$ cd hub-dev
$ ../bin/<arch>/terraform <action>
```

### Deploying an Environment

An "environment" is defined as any collection of related infrastructure.
Environments are grouped in directories under the `terraform` directory.

Use the `Makefile` to deploy an environment:

```
$ make plan env=hub-dev
$ make apply env=hub-dev
```

## Ansible

Resources are _provisioned_ with Ansible. Contrast this with Terraform
which _deploys_ resources.

### Makefile

There's an `ansible/Makefile` which can assist with running various Ansible
commands. Using the `Makefile` makes it easy to ensure the command has all
required information.

If you prefer to not use the `Makefile`, check the contents of the `Makefile`
for all required Ansible arguments and then just run `ansible` or
`ansible-playbook` manually.

A setup task has been added to the Makefile to provide a starting point for new
environments and to take care of some housekeeping tasks.

```
  $ cd ansible
  $ make env=example-2.syzygy.ca setup
```
This target will create the file `host_vars/example-2.syzygy.ca` containing
commonly customized ansible variables. The file should be edited to fit before
proceeding.


## Ansible Inventory

Inventory is handled through the
[ansible-terraform-inventory](https://github.com/jtopjian/ansible-terraform-inventory)
plugin. This plugin reads in the Terraform State of a deployed environment and
creates an appropriate Ansible Inventory result.

## Running Ansible

The instance must be initialized the first time. This will update all packages,
and use a suitable kernel to run zfs with. The instance will reboot once during
the process to use a new kernel version.

```
  $ cd ansible
  $ make env=hub-dev hub/init/check
  $ make env=hub-dev hub/init/apply
```

> Note: `init/check` might fail due to Ansible unable to accurately predict the
> commands it will run.

After a successful initialization, you can continue provisioning the hub with:

```
  $ make env=hub-dev hub/check
  $ make env=hub-dev hub/apply
```

> Note: again, `hub/check` might fail because Ansible.


## Let's Encrypt Integration

Let's Encrypt is used for all SSL certificates. We use
[dehydrated](https://github.com/lukas2511/dehydrated) combined with OpenStack
Designate to generate wildcard certificates. The certificates are stored on the
Clavius server and then pushed to the various Callysto servers.

Dehydrated is stored in the `vendor` directory.

The configuration is stored in `letsencrypt`.
