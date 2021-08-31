# Terraform Simple use cases.

This directory contains a very simple set of use cases for the F5 terraform provider on the BIG-IP.

## How to use
1. Install a functional BIG-IP
2. Install AS3 on the BIG-IP
3. Install terraform on a server that has access to the BIG-IP management port.

I have a terraform example here: (https://github.com/codecowboydotio/terraform/tree/main/ansible) that will install an ansible server and a bigip for you.


### The action
This is a little different from the ansible examples in that terraform uses a single declarative script to perform the configuration of my BIG-IP.


### Addition of an AS3 configuration

The terraform below declares a provider, and pulls in variables from my vars file.
This allows my to set the IP address, username, password and port of my BIG-IP.

```
variable "bigip_ip" { default = "x.x.x.x" }
variable "bigip_username" { default = "admin" }
variable "bigip_password" { default = "password" }
variable "bigip_port" { default = "443" }
variable "vip_address" { default = "x.x.x.x" }
```

Each of the variables should be tailored to your exaact parameters.


The bigip_as.tf is the main terraform file that performs the actions.


```
provider "bigip" {
  address = var.bigip_ip
  username = var.bigip_username
  password = var.bigip_password
  port = var.bigip_port
}


data "template_file" "init" {
  template = file("as3_simple.tpl")
  vars = {
    VIP_ADDRESS = var.vip_address
  }
}

resource "bigip_as3" "config" {
  as3_json = data.template_file.init.rendered
}

```
The provider block pulls in the variables from the vars file.

The next block prepares my template file. This file is the AS3 configuration that contains the VIP_ADDRESS as a variable. The template file is "filled out" at run time with the variabled that are passed into it.

In this case, the variable that is passed into the template file is from the vars.tf file.

Finally, we have a bigip_as3 block. 
This performs two tasks.
1. It renders the template file for me.
2. It applies the configuration to the BIG-IP (as defined in the provider).



## Let's run this

In order to run this do the following things:

On your machine, clone this repository.

```
git clone https://github.com/codecowboydotio/as3_workshop

cd as3_workshop/terraform
```

update the vars.tf file as appropriate.
Run a terraform init.

```
[root@fedora terraform]# terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of f5networks/bigip...
- Finding latest version of hashicorp/template...
- Installing hashicorp/template v2.2.0...
- Installed hashicorp/template v2.2.0 (signed by HashiCorp)
- Installing f5networks/bigip v1.11.0...
- Installed f5networks/bigip v1.11.0 (signed by a HashiCorp partner, key ID 8D69F031B13946D3)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

```


### Run an add

To run an add simply do the following

```
[root@fedora terraform]# terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # bigip_as3.config will be created
  + resource "bigip_as3" "config" {
      + application_list = (known after apply)
      + as3_json         = jsonencode(
            {
              + action      = "deploy"
              + class       = "AS3"
              + declaration = {
                  + Sample_01     = {
                      + Application_1      = {
                          + MyAS3VIP = {
                              + class            = "Service_HTTP"
                              + pool             = "web_pool"
                              + virtualAddresses = [
                                  + "13.54.144.60",
                                ]
                            }
                          + class    = "Application"
                          + template = "generic"
                          + web_pool = {
                              + class    = "Pool"
                              + members  = [
                                  + {
                                      + serverAddresses = [
                                          + "2.2.2.2",
                                          + "3.3.3.3",
                                        ]
                                      + servicePort     = 80
                                    },
                                ]
                              + monitors = [
                                  + "http",
                                ]
                            }
                        }
                      + class              = "Tenant"
                      + defaultRouteDomain = 0
                    }
                  + class         = "ADC"
                  + id            = "example-declaration-01"
                  + label         = "Sample 1"
                  + remark        = "Simple HTTP application with round robin pool"
                  + schemaVersion = "3.0.0"
                }
              + persist     = true
            }
        )
      + id               = (known after apply)
      + ignore_metadata  = false
      + tenant_list      = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
bigip_as3.config: Creating...
bigip_as3.config: Creation complete after 5s [id=Sample_01]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

```

Terraform will run a plan, show you the generated spec, which includes your "filled out" template, and then apply the template to the BIG-IP.

### Run a remove
In order to remove the configuration you can run a terraform destroy.

Similar to the addition, terraform will run a plan and remove the configuration that is in the state file.

```
[root@fedora terraform]# terraform destroy -auto-approve
bigip_as3.config: Refreshing state... [id=Sample_01]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # bigip_as3.config will be destroyed
  - resource "bigip_as3" "config" {
      - application_list = "Application_1" -> null
      - as3_json         = jsonencode(
            {
              - action      = "deploy"
              - class       = "AS3"
              - declaration = {
                  - Sample_01     = {
                      - Application_1      = {
                          - MyAS3VIP = {
                              - class            = "Service_HTTP"
                              - pool             = "web_pool"
                              - virtualAddresses = [
                                  - "13.54.144.60",
                                ]
                            }
                          - class    = "Application"
                          - template = "generic"
                          - web_pool = {
                              - class    = "Pool"
                              - members  = [
                                  - {
                                      - serverAddresses = [
                                          - "2.2.2.2",
                                          - "3.3.3.3",
                                        ]
                                      - servicePort     = 80
                                    },
                                ]
                              - monitors = [
                                  - "http",
                                ]
                            }
                        }
                      - class              = "Tenant"
                      - defaultRouteDomain = 0
                    }
                  - class         = "ADC"
                  - id            = "example-declaration-01"
                  - label         = "Sample 1"
                  - remark        = "Simple HTTP application with round robin pool"
                  - schemaVersion = "3.0.0"
                }
              - persist     = true
            }
        ) -> null
      - id               = "Sample_01" -> null
      - ignore_metadata  = false -> null
      - tenant_list      = "Sample_01" -> null
    }

Plan: 0 to add, 0 to change, 1 to destroy.
bigip_as3.config: Destroying... [id=Sample_01]
bigip_as3.config: Destruction complete after 3s

Destroy complete! Resources: 1 destroyed.

```
