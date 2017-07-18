#!/bin/bash

echo "##" >> /etc/hosts
echo "195.220.108.108 fr2.rpmfind.net" >> /etc/hosts
echo "112.124.140.210 mirrors.aliyun.com" >> /etc/hosts
echo "67.219.144.68 download.fedoraproject.org" >> /etc/hosts
echo "219.216.128.25 mirrors.neusoft.edu.cn" >> /etc/hosts
echo "101.6.6.177 mirrors.tuna.tsinghua.edu.cn" >> /etc/hosts
echo "140.205.32.12 mirrors.aliyuncs.com" >> /etc/hosts
echo "123.58.173.186 mirrors.163.com" >> /etc/hosts
echo "66.241.106.180 mirror.centos.org" >> /etc/hosts
echo "202.141.176.110 mirrors.ustc.edu.cn" >> /etc/hosts

rpm -qa|grep yum|xargs rpm -e --nodeps

cd /root
wget mirrors.163.com/centos/6/os/x86_64/Packages/yum-3.2.29-81.el6.centos.noarch.rpm 
wget mirrors.163.com/centos/6/os/x86_64/Packages/yum-metadata-parser-1.1.2-16.el6.x86_64.rpm
wget mirrors.163.com/centos/6/os/x86_64/Packages/yum-plugin-fastestmirror-1.1.30-40.el6.noarch.rpm
wget mirrors.163.com/centos/6/os/x86_64/Packages/python-iniparse-0.3.1-2.1.el6.noarch.rpm 
wget mirrors.163.com/centos/6/os/x86_64/Packages/python-urlgrabber-3.9.1-11.el6.noarch.rpm 

rpm -ivh python-iniparse-0.3.1-2.1.el6.noarch.rpm
rpm -ivh yum-metadata-parser-1.1.2-16.el6.x86_64.rpm
rpm -Uvh python-urlgrabber-3.9.1-11.el6.noarch.rpm
rpm -ivh yum-3.2.29-81.el6.centos.noarch.rpm yum-plugin-fastestmirror-1.1.30-40.el6.noarch.rpm

rm -rf /etc/yum.repos.d/redhat.repo

cd /etc/yum.repo.d
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
sed -i 's/$releasever/6/g' /etc/yum.repos.d/CentOS-Base.repo

rpm -ivh http://fr2.rpmfind.net/linux/epel/6/x86_64/epel-release-6-8.noarch.rpm


yum upgrade ca-certificates --disablerepo=epel -y
sed -i 's/#baseurl/baseurl/g' /etc/yum.repos.d/epel.repo
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/epel.repo
