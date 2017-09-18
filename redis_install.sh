#!/bin/bash
REDIS_PATH=/u01/igadm

cat /etc/yum.conf |grep proxy
if [ $? == 1 ];then
	echo "" >> /etc/yum.conf
	echo "proxy=http://10.80.25.238:3128/" >> /etc/yum.conf
else
	echo "Proxy already configured."
fi

yum install -y gcc gcc-c++ jemalloc

cd ${REDIS_PATH}
tar -zxf redis-4.0.1.tar.gz
cd redis-4.0.1
make MALLOC=libc && make install

yum install ruby rubygems -y
#gem update --system
#gem install redis