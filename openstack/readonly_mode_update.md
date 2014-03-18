cinder readonly_mode_update
---
### cinder-client消息流
```shell
REQ: curl -i http://186.100.8.214:35357/v2.0/tokens -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "User-Agent: python-cinderclient" -d '{"auth": {"tenantName": "admin", "passwordCredentials": {"username": "admin", "password": "admin"}}}'

REQ: curl -i http://186.100.8.214:8776/v1/86196260e1694d0cbb5049cfba3883f8/volumes/9b7b450f-a815-4e05-8c22-3419b5e8a553 -X GET -H "X-Auth-Project-Id: admin" -H "User-Agent: python-cinderclient" -H "Accept: application/json" -H "X-Auth-Token: 284c379a621b4524b9f156e60f014f10"

REQ: curl -i http://186.100.8.214:8776/v1/86196260e1694d0cbb5049cfba3883f8/volumes/9b7b450f-a815-4e05-8c22-3419b5e8a553/action -X POST -H "X-Auth-Project-Id: admin" -H "User-Agent: python-cinderclient" -H "Content-Type: application/json" -H "Accept: application/json" -H "X-Auth-Token: 284c379a621b4524b9f156e60f014f10" -d '{"os-update_readonly_flag": {"readonly": false}}'
```
### os-update_readonly_flag处理过程  
