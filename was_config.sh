#!/bin/bash

WAS_INSTALL_ROOT="/u01/scadm"

##  Exit immediately if any untested command fails 
set -o errexit 

## Initial functions

#创建dmgr前清理was_config.conf文件中保存的dmgr命名信息。
function initial_dmgr_conf(){
	if [ ! -f ${WAS_INSTALL_ROOT}/was_config.conf ];then
		touch ${WAS_INSTALL_ROOT}/was_config.conf
	fi
	sed -i '/^DMGR/d' ${WAS_INSTALL_ROOT}/was_config.conf
}

#创建node前清理was_config.conf文件中保存的node命名信息。
function initial_node_conf(){
	if [ ! -f ${WAS_INSTALL_ROOT}/was_config.conf ];then
		touch ${WAS_INSTALL_ROOT}/was_config.conf
	fi
	sed -i '/^NODE/d' ${WAS_INSTALL_ROOT}/was_config.conf
}

#根据was_config.conf文件中记录的命名信息，清理相应的已安装dmgr/node。
function initial_was_config(){
	
	if [ ! -f ${WAS_INSTALL_ROOT}/was_config.conf ];then
		touch ${WAS_INSTALL_ROOT}/was_config.conf
	fi

	INI_NODE_PROF_NAME=`awk '{if($1=="NODE_PROF_NAME"){print $2}}' ${WAS_INSTALL_ROOT}/was_config.conf`
	INI_NODE_NAME=`awk '{if($1=="NODE_NAME"){print $2}}' ${WAS_INSTALL_ROOT}/was_config.conf`
	INI_DMGR_PROF_NAME=`awk '{if($1=="DMGR_PROF_NAME"){print $2}}' ${WAS_INSTALL_ROOT}/was_config.conf`
	INI_DMGR_CELL_NAME=`awk '{if($1=="DMGR_CELL_NAME"){print $2}}' ${WAS_INSTALL_ROOT}/was_config.conf`
	INI_DMGR_NAME=`awk '{if($1=="DMGR_NAME"){print $2}}' ${WAS_INSTALL_ROOT}/was_config.conf`

	if [ -d "${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/profiles/${INI_NODE_PROF_NAME}" ];then
		cd ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/bin
		./manageprofiles.sh -delete -templatePath ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/profileTemplates/default -profilePath ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/profiles/${INI_NODE_PROF_NAME} -profileName ${INI_NODE_PROF_NAME} -nodeName ${INI_NODE_NAME} >/dev/null 2>&1
		rm -rf ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/profiles/${INI_NODE_PROF_NAME}
		echo "node cleaned."
	else
		echo "none node exist."
	fi

	if [ -d "${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/profiles/${INI_DMGR_PROF_NAME}" ];then
		cd ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/bin
		./manageprofiles.sh -delete -profileName ${INI_DMGR_NAME} -templatePath ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/profileTemplates/management -profilePath ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/profiles/${INI_DMGR_PROF_NAME} -serverType DEPLOYMENT_MANAGER -nodeName ${INI_DMGR_PROF_NAME} -cellName ${INI_DMGR_CELL_NAME} -enableAdminSecurity true -adminUserName wasadmin -adminPassword wasadmin -defaultPorts >/dev/null 2>&1
		rm -rf ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/profiles/${INI_DMGR_PROF_NAME}
		echo "dmgr cleaned."
	else
		echo "none dmgr exist."
	fi

	echo "Initializing finished."
}

##initializing

while true
do
	read -p "Do you want to launch an initialization? (yes or no)" WHETHER_INI

	if [ ${WHETHER_INI} = 'yes' ];then
		initial_was_config
		break
	elif [ ${WHETHER_INI} = 'no' ];then
		break
	else
		echo "Please enter yes or no"
	fi
done

##  Create dmgr.

while true
do
	read -p "Do you want to set up a DMGR? (yes or no)" WHETHER_DMGR

	if [ ${WHETHER_DMGR} = 'yes' ];then
		read -p "(1/3)Enter dmgr name:" DMGR_NAME
		read -p "(2/3)Enter profile name:(like mqsitAppDmgr)" DMGR_PROF_NAME
		read -p "(3/3)Enter cell name:(like mqsitAppCell)" DMGR_CELL_NAME
		
		initial_dmgr_conf
		echo DMGR_NAME ${DMGR_NAME} >> ${WAS_INSTALL_ROOT}/was_config.conf
		echo DMGR_PROF_NAME ${DMGR_PROF_NAME} >> ${WAS_INSTALL_ROOT}/was_config.conf
		echo DMGR_CELL_NAME ${DMGR_CELL_NAME} >> ${WAS_INSTALL_ROOT}/was_config.conf

		cd ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/bin
		./manageprofiles.sh -create -profileName ${DMGR_NAME} -templatePath ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/profileTemplates/management -profilePath ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/profiles/${DMGR_PROF_NAME} -serverType DEPLOYMENT_MANAGER -nodeName ${DMGR_PROF_NAME} -cellName ${DMGR_CELL_NAME} -enableAdminSecurity true -adminUserName wasadmin -adminPassword wasadmin -defaultPorts

		break
	elif [ ${WHETHER_DMGR} = 'no' ];then
		break
	else
		echo "Please enter yes or no"
	fi
done

## Start dmgr

if [ -d ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/profiles/${DMGR_PROF_NAME} ];then
	while true
	do
		read -p "Do you want to start up the DMGR? (yes or no)" WHETHER_START_DMGR
		if [ ${WHETHER_START_DMGR} = 'yes' ];then
			read -p "Please make sure the hosts have been modified correctly! Then press Enter to continue." var			
			ps -ef|grep dmgr|grep -v grep			
			if [ $? -ne 0 ];then
				cd ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/profiles/${DMGR_PROF_NAME}/bin
				./startManager.sh
			else
				echo "the dmgr is already runing....."
			fi

			break

		elif [ ${WHETHER_START_DMGR} = 'no' ];then
			break
		else
			echo "Please enter yes or no"
		fi
	done
fi

##  Create node and federate it to dmgr.

while true
do
	read -p "Do you want to create a node and federate it to a dmgr? (yes or no)" WHETHER_NODE

	if [ ${WHETHER_NODE} = 'yes' ];then
		echo "creating a node..."
		read -p "(1/3)Enter node name:(like mqsitAppNode)" NODE_NAME
		read -p "(2/3)Enter profile name:(like mqsitAppServers)" NODE_PROF_NAME
		read -p "(3/3)Enter hostname of the dmgr you want to fedarate the node to:" F_DMGR_NAME
		cd ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/bin
		./manageprofiles.sh -create -templatePath ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/profileTemplates/default -profilePath ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/profiles/${NODE_PROF_NAME} -profileName ${NODE_PROF_NAME} -nodeName ${NODE_NAME}

		initial_node_conf
		echo NODE_NAME ${NODE_NAME} >> ${WAS_INSTALL_ROOT}/was_config.conf
		echo NODE_PROF_NAME ${NODE_PROF_NAME} >> ${WAS_INSTALL_ROOT}/was_config.conf

		echo "fedarating node to a dmgr..."		
		cd ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/profiles/${NODE_PROF_NAME}/bin
		./addNode.sh ${F_DMGR_NAME} 8879 -username wasadmin -password wasadmin
		
		break
	elif [ ${WHETHER_NODE} = 'no' ];then
		break
	else
		echo "Please enter yes or no"
	fi
done

## Set up JDK

if [ -d ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/profiles/${NODE_PROF_NAME} ];then
	echo "Setting up JDK..."
	
	while true
	do
		read -p "Enter the version of JDK you want to use(1.7 or 1.8 or exit to quit):" JDK_NAME

		if [ ${JDK_NAME} = '1.7' ]||[ ${JDK_NAME} = '1.8' ];then
			cd ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer/bin
			./managesdk.sh -setCommandDefault -sdkname ${JDK_NAME}_64
			./managesdk.sh -enableProfile -profileName ${NODE_PROF_NAME} -sdkname ${JDK_NAME}_64 -enableServers
			break
		elif [ ${JDK_NAME} = 'exit' ];then
			break
		else
			echo "Please enter 1.7 or 1.8"
		fi
	done
fi

## Finish and exit
echo "WAS configuration complete!"
exit 0
