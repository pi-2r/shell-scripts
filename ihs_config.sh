#!/bin/bash

cp /u01/scadm/IBM/HTTPServer/conf/httpd.conf /u01/scadm/IBM/HTTPServer/conf/httpd.confbak$(date +%y%m%d)

sed -i 's:DocumentRoot "/u01/scadm/IBM/HTTPServer/htdocs":DocumentRoot "/nas/webresource/":g' /u01/scadm/IBM/HTTPServer/conf/httpd.conf
sed -i 's:<Directory "/u01/scadm/IBM/HTTPServer/htdocs">:<Directory "/nas/webresource/">:g' /u01/scadm/IBM/HTTPServer/conf/httpd.conf
sed -i 's:ServerSignature On:ServerSignature Off:g' /u01/scadm/IBM/HTTPServer/conf/httpd.conf
echo "LoadModule was_ap22_module /u01/scadm/IBM/WebSphere/Plugins/bin/64bits/mod_was_ap22_http.so" >> /u01/scadm/IBM/HTTPServer/conf/httpd.conf
echo "WebSpherePluginConfig /u01/scadm/IBM/WebSphere/Plugins/config/middleWebServer/plugin-cfg.xml" >> /u01/scadm/IBM/HTTPServer/conf/httpd.conf

sed -i 's:@@AdminPort@@:8009:g' /u01/scadm/IBM/HTTPServer/conf/admin.conf

echo "USERNAME:PASSWORD" >> /u01/scadm/IBM/HTTPServer/conf/admin.passwd

