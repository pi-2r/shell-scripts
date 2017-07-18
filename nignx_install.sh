#!/bin/bash

#提前准备好pcre、perl、openssl、tengine安装包，路径配置一下。
NGINX_BASE_DIR=/u01/scadm

yum install -y gcc gcc-c++ zlib-devel

cd ${NGINX_BASE_DIR}

cd ${NGINX_BASE_DIR}/pcre-8.36
./configure --prefix=/usr/local/pcre --libdir=/usr/local/lib/pcre --includedir=/usr/local/include/pcre
make && make install

cd ${NGINX_BASE_DIR}/perl-5.16.1
./Configure -des -Dprefix=/usr/local/perl -Dusethreads -Uversiononly
make && make install

cd ${NGINX_BASE_DIR}/openssl-1.0.0e
./config --prefix=/usr/local/openssl
make && make install

cd ${NGINX_BASE_DIR}/tengine-2.1.1
./configure --prefix=/u01/scadm/nginx  --with-http_stub_status_module --with-openssl=/u01/scadm/openssl-1.0.0e --with-pcre=/u01/scadm/pcre-8.36
make && make install

exit 0