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
- paramter_ansile: This is the same simple example but shows how to use paramters to pass variables to the playbook

### Playbooks
There are two playbooks here with a very simple use case:

### Addition of an AS3 configuration
```
---
- name: AS3
  hosts: f5
  connection: httpapi
  gather_facts: false

  # Connection Info
  vars:
    ansible_host: x.x.x.x
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
```

The playbook above adds the onfiguration that is found in my as2.json file to the BIG-IP that is configured in the variables section of the playbook.

The task reads in a local file from disk. This file is the as3 declaration.

```
{
     "class": "AS3",
     "action": "deploy",
     "persist": true,
     "declaration": {
         "class": "ADC",
         "schemaVersion": "3.0.0",
         "id": "example-declaration-01",
         "label": "Sample 1",
         "remark": "Simple HTTP application with round robin pool",
         "Sample_01": {
             "class": "Tenant",
             "defaultRouteDomain": 0,
             "Application_1": {
                 "class": "Application",
                 "template": "generic",
             "MyAS3VIP": {
                 "class": "Service_HTTP",
                 "virtualAddresses": [
                     "10.1.1.1"
                 ],
                 "pool": "web_pool"
             },
             "web_pool": {
                 "class": "Pool",
                 "monitors": [
                     "http"
                 ],
                 "members": [
                     {
                       "servicePort": 80,
                       "serverAddresses": [
                         "2.2.2.2",
                         "3.3.3.3"
                       ]
                     }
                 ]
             }
         }
     }
  }
}
```




### Removal of an AS3 configuration
The removal playbook is similar in nature, in that it still has the variables to define the BIG-IP at the beginning.

```
---
- name: AS3
  hosts: f5
  connection: httpapi
  gather_facts: false
  collections:
    - f5networks.f5_bigip

  # Connection Info
  vars:
    ansible_host: x.x.x.x
    ansible_user: admin
    ansible_httpapi_password: password
    ansible_httpapi_port: 443
    ansible_network_os: f5networks.f5_bigip.bigip
    ansible_httpapi_use_ssl: yes
    ansible_httpapi_validate_certs: no

  tasks:

    - name: Remove one tenant - AS3
      bigip_as3_deploy:
        tenant: Sample_01
        state: absent
```

The main difference with this playbook is the task:

```
    - name: Remove one tenant - AS3
      bigip_as3_deploy:
        tenant: Sample_01
        state: absent
```

The task simply references the tenant and uses the ansible "state" directive to declare the tenant as absent - this will remove the tenant.

## Let's run this

In order to run this do the following things:

On your ansible machine, clone this repository.

```
git clone https://github.com/codecowboydotio/as3_workshop

cd as3_workshop/ansible/simple_ansible

ls -la

drwxr-xr-x. 2 root root   75 Aug 31 15:06 .
drwxr-xr-x. 3 root root   45 Aug 31 15:13 ..
-rw-r--r--. 1 root root  515 Aug 31 15:06 add.yml
-rw-r--r--. 1 root root 1166 Aug 31 08:54 as3_simple.json
-rw-r--r--. 1 root root   14 Aug 31 14:06 hosts
-rw-r--r--. 1 root root  503 Aug 31 14:19 remove.yml
```

There are four files:
- hosts: This is an ansible hosts file that is used to place the BIG-IP host(s) inside of
- as3_simple.json: This is an AS3 declaration that creates a simple tenant, load balancing pool and members.
- add.yml: This is an ansible playbook that will use the as3_simple.json file and add the tenant information to the BIG-IP
- remove.yml: This is an ansible playbook to remove the tenant created by the "add.yml" playbook.

In order to configure the environment you will need to edit the playbooks and hosts file to suit your environment:

```
vi hosts


[f5]
x.x.x.x
```

Change the x.x.x.x to the IP address of your BIG-IP management address.

```
vi add.yml

  # Connection Info
  vars:
    ansible_host: x.x.x.x
    ansible_user: admin
    ansible_httpapi_password: password
    ansible_httpapi_port: 443
```

Change the variables in the playbook to reflect your environment. 
- ansible_host: This is the IP address of your BIG-IP
- ansible_user: This is the username (that has admin) on the BIG-IP
- ansible_httpapi_password: This is the password of the user that you are using
- ansible_httpapi_port: This is the port that the management interface is running on (usually 443)

Once all of the changes have been made, you can run the add playbook like this:

```
[f5]
13.54.144.60

[root@ip-10-100-1-222 simple_ansible]# more add.yml
---
- name: AS3
  hosts: f5
  connection: httpapi
  gather_facts: false

  # Connection Info
  vars:
    ansible_host: 13.54.144.60
    ansible_user: admin
    ansible_httpapi_password: password
    ansible_httpapi_port: 443
    ansible_network_os: f5networks.f5_bigip.bigip
    ansible_httpapi_use_ssl: yes
    ansible_httpapi_validate_certs: no

  tasks:

    - name: Deploy or Update AS3
      f5networks.f5_bigip.bigip_as3_deploy:
          content: "{{ lookup('file', 'as3_simple.json') }}"
      tags: [ deploy ]

[root@ip-10-100-1-222 simple_ansible]# ansible-playbook add.yml -i hosts

PLAY [AS3] ************************************************************************************************************************

TASK [Deploy or Update AS3] *******************************************************************************************************
ok: [13.54.144.60]

PLAY RECAP ************************************************************************************************************************
13.54.144.60               : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

This has created a tenant on the BIG-IP.
You may now log into the BIG-IP and ensure that the tenant has been created successfully.


