#!/bin/bash

/u01/scadm/IBM/WebSphere/AppServer/profiles/frontAppServers/bin/stopServer.sh $1 -username USERNAME -password PASSWORD

/u01/scadm/IBM/WebSphere/AppServer/profiles/frontAppServers/bin/syncNode.sh DMGR_IP -username USERNAME -password PASSWORD

/u01/scadm/IBM/WebSphere/AppServer/profiles/frontAppServers/bin/startNode.sh

/u01/scadm/IBM/WebSphere/AppServer/profiles/frontAppServers/bin/startServer.sh $1

#tail -f /u01/scadm/IBM/WebSphere/AppServer/profiles/frontAppServers/logs/$1/SystemOut.log

if [[ $1 == mobileServer1 || $1 == mobileServer2 || $1 == mobileServer3 || $1 == mobileServer4 ]];then
	if [ ! -L /u01/scadm/IBM/WebSphere/AppServer/profiles/frontAppServers/installedApps/194FrontAppCell/mobileStore_war.ear/mobileStore.war/gouwuzhinanxiangqingye ];then
		LINKS	
	fi
elif [[ $1 =~ portalServer\d* ]];then
	if [ ! -L /u01/scadm/IBM/WebSphere/AppServer/profiles/frontAppServers/installedApps/194FrontAppCell/portal_war.ear/portal.war/guanyuwomen ];then
		LINKS
	fi
	if [ ! -L /u01/scadm/IBM/WebSphere/AppServer/profiles/frontAppServers/installedApps/194FrontAppCell/store-member_war.ear/store-member.war/huiyuantequan ];then
		LINKS
	fi
	COPY FILES
elif [[ $1 =~ storeServer\d* ]];then
	LINKS
elif [[ $1 == socialmobileServer1 || $1 == socialmobileServer2 || $1 == socialmobileServer3 || $1 == socialmobileServer4 ]];then
	if [ ! -L /u01/scadm/IBM/WebSphere/AppServer/profiles/frontAppServers/installedApps/194FrontAppCell/social_war.ear/social.war/upload ];then
		LINKS
	fi
fi
