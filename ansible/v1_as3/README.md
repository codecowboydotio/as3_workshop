# Ansible Simple use cases.

This collection uses the AS3 modules to add a simple configuration and remove it.
This example uses the URI module to POST to the AS3 endpoint on the BIG-IP.

## How to use
1. Install a functional BIG-IP
2. Install AS3 on the BIG-IP
3. Install an ansible node with the F5 ansible collection


### Playbooks
There is one playbook that demonstrates adding and removing an AS3 declaration.

### Addition of an AS3 configuration
```
---
- hosts: f5
  gather_facts: false

  vars:
   user: "admin"
   password: "admin"
   bigip_port: "443"
   http_method: "POST"
   file_name: "as3_simple.json"
   as3_spec: "{{ lookup('file', '{{ file_name }}') | from_json }}"

  tasks:
  - name: URI POST Tenant
    uri:
       url: "https://{{ inventory_hostname }}:{{ bigip_port }}/mgmt/shared/appsvcs/declare"
       method: "{{ http_method }}"
       user: "{{ user }}"
       password: "{{ password }}"
       force_basic_auth: yes
       validate_certs: no
       body: "{{ as3_spec }}"
       body_format: json
    delegate_to: localhost

```

The playbook above adds the onfiguration that is found in my as3.json file to the BIG-IP that is configured in the variables section of the playbook.

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
In AS3 speak, to remove a tenant, you simply send the same declaration with a DELETE HTTP method.

The playbook has a variable that changes the HTTP METHOD. This means that if you want to remove the tenant, you can simply change the variable to DELETE and re-run the same playbook.

This can be done in two ways.

- statically assigning the variables
Change the variable **http_method** from POST to DELETE

```
  vars:
   user: "admin"
   password: "admin"
   bigip_port: "443"
   **http_method: "DELETE"**

```

- changing the method as an input variable when you run the playbook.
To run the playbook with a specific method at runtime, you can do the following
```
[root@fedora v1_as3]# ansible-playbook -e "http_method=POST" add.yml
```

If i want to delete the tenant, I change the http_method to delete on the command line, and the tenant is removed. 

```
[root@fedora v1_as3]# ansible-playbook -e "http_method=DELETE" add.yml
```


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
```

There are four files:
- hosts: This is an ansible hosts file that is used to place the BIG-IP host(s) inside of
- as3_simple.json: This is an AS3 declaration that creates a simple tenant, load balancing pool and members.
- add.yml: This is an ansible playbook that will use the as3_simple.json file and add the tenant information to the BIG-IP

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
   user: "admin"
   password: "admin"
   bigip_port: "443"
   http_method: "POST"
   file_name: "as3_simple.json"
   as3_spec: "{{ lookup('file', '{{ file_name }}') | from_json }}"

```

Change the variables in the playbook to reflect your environment. 
- user: This is the username to access the BIG-IP
- password: This is the password for the user (on the BIG-IP)
- bigip_port: This is the port that the BIG-IP management port runs on (usually 443)
- http_method: This is the method that you are going to send as part of the URI module - POST or DELETE
- file_name: This is the file name of the AS3 declaration that you want to post to the BIG-IP.

Once all of the changes have been made, you can run the add playbook like this:

```
[root@fedora v1_as3]# ansible-playbook -e "http_method=POST" add.yml
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details

PLAY [f5] **********************************************************************************************************************************************

TASK [URI POST Tenant] *********************************************************************************************************************************
ok: [10.1.1.245]

PLAY RECAP *********************************************************************************************************************************************
10.1.1.245                 : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

This has created a tenant on the BIG-IP.
You may now log into the BIG-IP and ensure that the tenant has been created successfully.



SImilarly to remove the tenant that you have just created, you can run the following:

```
[root@fedora v1_as3]# ansible-playbook -e "http_method=DELETE" add.yml
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details

PLAY [f5] **********************************************************************************************************************************************

TASK [URI POST Tenant] *********************************************************************************************************************************
ok: [10.1.1.245]

PLAY RECAP *********************************************************************************************************************************************
10.1.1.245                 : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```
