# AS3 simple use cases with Terraform and Ansible.

This repo has three simple use cases for terraform and ansible configurations using AS3 and a BIG-IP.

## Project Structure

```
as3_workshop
|
----ansible
|
--------parameter_ansible
|
--------simple_ansible
|
----terraform
```

Each directory contains a simple example - and a dedicated readme to help you decipher the code.

- ansible: This is the top level for the ansible examples - uses v2 modules.
- ansible/parameter_ansible: This has examples of using JINJA2 templates with a BIG-IP configuration using AS3.
- ansible/simple_ansible: This has examples of using AS3 and ansible with a static AS3 configuration.
- terraform: This has examples of using terraform and ansible to configure a bigip using variables and terraform template files.


## Collaborating
Make sure if you find errors or omissions that you do pull requests and we can make this better over time for everyone :)
