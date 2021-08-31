# Ansible Simple use cases.

This directory contains a very simple set of use cases for the F5 Ansible collections f5_bigip.
This collection uses the AS3 modules to add a simple configuration and remove it.

## How to use
1. Install a functional BIG-IP
2. Install AS3 on the BIG-IP
3. Install an ansible node with the F5 ansible collection

I have a terraform example here: (https://github.com/codecowboydotio/terraform/tree/main/ansible) that will install an ansible server and a bigip for you.

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

    VIP_ADDRESS: 1.1.1.1

  tasks:

    - name: Update AS3 template
      template:
        src: as3_simple.j2
        dest: as3_simple.json

    - name: Deploy or Update AS3
      f5networks.f5_bigip.bigip_as3_deploy:
          content: "{{ lookup('file', 'as3_simple.json') }}"
      tags: [ deploy ]
```

The playbook above does two things: 
1. It creates an AS3 json declaration from a jinja2 template 
2. It uploads that configuration to the BIG-IP.

The first task reads in variables from the command line - or uses the default variable VIP_ADDRESS and passes this to a jinja2 template.
The second task reads in a local file from disk. This file is the as3 declaration.


The jinja2 template is an AS3 declaration with the addition of a JINJA variable called VIP_ADDRESS
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
                     "{{ VIP_ADDRESS }}"
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

The task fills out the variable and replaces it with the variable before sending the delcaration.
This declaration could easily be extended to cater for multiple variables - this is an example of using a single variable.





### Removal of an AS3 configuration
The removal playbook this time is similar, but the tenant name is passed in as a variable.

There are two tasks in this playbook, the first simply checks that the tenant variable has been passed into the playbook - this is different from the add.yml playbook. This playbook does not add a default variable. I chose to show this simply to demonstrate that there are different ways to approach using variables in your playbooks.

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

    - name: Check all vars are present
      assert:
        that:
          - tenant != ""
        fail_msg: "'tenant' does not exist"
        success_msg: "attempting to remove tenant: {{ tenant }}"

    - name: Remove one tenant - AS3
      bigip_as3_deploy:
        tenant: "{{ tenant }}"
        state: absent
```

The main difference with this playbook is the task:

```
    - name: Remove one tenant - AS3
      bigip_as3_deploy:
        tenant: "{{ tenant }}"
        state: absent
```

The tenant name is read in as a variable from the command line.

## Let's run this

In order to run this do the following things:

On your ansible machine, clone this repository.

```
git clone https://github.com/codecowboydotio/as3_workshop

cd as3_workshop/ansible/parameter_ansible

ls -la

[root@ip-10-100-1-222 parameter_ansible]# ll
total 28
-rw-r--r--. 1 root root  652 Aug 31 05:57 add.yml
-rw-r--r--. 1 root root 1175 Aug 31 05:57 as3_simple.j2
-rw-r--r--. 1 root root   18 Aug 31 05:57 hosts
-rw-r--r--. 1 root root 7930 Aug 31 05:57 README.md
-rw-r--r--. 1 root root  710 Aug 31 05:57 remove.yml

```

There are four files:
- hosts: This is an ansible hosts file that is used to place the BIG-IP host(s) inside of
- as3_simple.j2: This is a JINJA2 template that will be "filled out" at run time by the first task.
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
[root@ip-10-100-1-222 parameter_ansible]# more hosts
[f5]
13.54.144.60
[root@ip-10-100-1-222 parameter_ansible]# more add.yml
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

    VIP_ADDRESS: 1.1.1.1

  tasks:

    - name: Update AS3 template
      template:
        src: as3_simple.j2
        dest: as3_simple.json

    - name: Deploy or Update AS3
      f5networks.f5_bigip.bigip_as3_deploy:
          content: "{{ lookup('file', 'as3_simple.json') }}"
      tags: [ deploy ]

[root@ip-10-100-1-222 parameter_ansible]# ansible-playbook add.yml -i hosts -e VIP_ADDRESS=5.5.5.5

PLAY [AS3] ************************************************************************************************************************

TASK [Update AS3 template] ********************************************************************************************************
ok: [13.54.144.60]

TASK [Deploy or Update AS3] *******************************************************************************************************
ok: [13.54.144.60]

PLAY RECAP ************************************************************************************************************************
13.54.144.60               : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

This has created a tenant on the BIG-IP.
You may now log into the BIG-IP and ensure that the tenant has been created successfully.



Similarly to remove the tenant that you have just created, you can run the following:
Note that the tenant name is passed in as a variable on the command line using the -e switch.

```
[root@ip-10-100-1-222 parameter_ansible]# ansible-playbook remove.yml -i hosts -e tenant=Sample_01

PLAY [AS3] ************************************************************************************************************************

TASK [Check all vars are present] *************************************************************************************************
ok: [13.54.144.60] => {
    "changed": false,
    "msg": "attempting to remove tenant: Sample_01"
}

TASK [Remove one tenant - AS3] ****************************************************************************************************
changed: [13.54.144.60]

PLAY RECAP ************************************************************************************************************************
13.54.144.60               : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```


