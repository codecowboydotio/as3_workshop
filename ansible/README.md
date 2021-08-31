# Ansible Simple use cases.

This directory contains a very simple set of use cases for the F5 Ansible collections f5_bigip.
This collection uses the AS3 modules to add a simple configuration and remove it.

## How to use
1. Install a functional BIG-IP
2. Install AS3 on the BIG-IP
3. Install an ansible node with the F5 ansible collection

I have a terraform example here: (https://github.com/codecowboydotio/terraform/tree/main/ansible) that will install an ansible server and a bigip for you.

### Directory structure
Within thei section of the repo there are two directories:

- simple_ansible: This is a simple example of deploying a static AS3 configuration to a BIG-IP.
- parameter_ansile: This is the same simple example but shows how to use paramters to pass variables to the playbook

