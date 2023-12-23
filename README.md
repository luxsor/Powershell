## Import module
. .\Invoke-HttpServer

## Start Http Server 
Invoke-HttpServer -uri "http://192.168.0.1:8000"

## Set ACL Http module and start Http Server
Invoke-HttpServer -uri "http://192.168.0.1:8000" -aclUsername domain\username
