#!/bin/bash
VERSION=9.4.10-2068191

tar -zxf /root/perl-5.16.1.tar.gz
cd /root/perl-5.16.1
./Configure -des -Dprefix=/usr/local/perl -Dusethreads -Uversiononly
make && make install

if [ ! -d /mnt/cdrom ];then
        mkdir /mnt/cdrom
fi
mount /dev/cdrom /mnt/cdrom

cp /mnt/cdrom/VMwareTools-$VERSION.tar.gz /tmp/

cd /tmp
tar -zxf VMwareTools-$VERSION.tar.gz

cd vmware-tools-distrib
./vmware-install.pl -d