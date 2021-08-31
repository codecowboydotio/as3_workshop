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
                     "${ VIP_ADDRESS }"
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
