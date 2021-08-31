# Ansible Simple use cases.

This directory contains a very simple set of use cases for the F5 Ansible collections f5_bigip.
This collection uses the AS3 modules to add a simple configuration and remove it.

## How to use
1. Install a functional BIG-IP
2. Install AS3 on the BIG-IP
3. Install an ansible node with the F5 ansible collection

### Playbooks
There are two playbooks here with a very simple use case:

### Addition of an AS3 configuration
---
- name: AS3
  hosts: f5
  connection: httpapi
  gather_facts: false

  # Connection Info
  vars:
    ansible_host: 3.24.162.144
    ansible_user: admin
    ansible_httpapi_password: password
    ansible_httpapi_port: 443
    ansible_network_os: f5networks.f5_bigip.bigip
    ansible_httpapi_use_ssl: yes
    ansible_httpapi_validate_certs: no

  tasks:

    - name: Deploy or Update AS3
      f5networks.f5_bigip.bigip_as3_deploy:
          content: "{{ lookup('file', 'as3.json') }}"
      tags: [ deploy ]





### Removal of an AS3 configuration

