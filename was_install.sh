#!/bin/bash

WAS_ROOT="/nas/software"
WAS_INSTALL_ROOT="/u01/scadm"

while :
do
	read -p "Enter the WAS version you want to install(8551 or 8559), enter exit to quit:" WASVER
	if [ ${WASVER} = '8551' ]||[ ${WASVER} = '8559' ];then
		break
	elif [ ${WASVER} = 'exit' ];then
		exit 0
	fi
done

##  Exit immediately if any untested command fails 
set -o errexit 

## initializing
if [ -d "${WAS_INSTALL_ROOT}/IBM" ];then 
	## delete WAS that's already been installed.
	cd ${WAS_INSTALL_ROOT}/IBM/InstallationManager/eclipse/tools
	if [ -d "${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer" ];then
		./imcl uninstall com.ibm.websphere.IBMJAVA.v80_8.0.2010.20160224_1829 -installationDirectory  ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer
		./imcl uninstall 7.0.1.0-WS-WASJavaSDK7-LinuxX64-IFPI55776_7.0.1000.20160126_1544-installationDirectory  ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer
		./imcl uninstall com.ibm.websphere.IBMJAVA.v70_7.0.1000.20120424_1539 -installationDirectory  ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer
		./imcl rollback com.ibm.websphere.ND.v85 -acceptLicense -repositories ${WAS_ROOT}/8.5.5.9/repository.config -installationDirectory ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer -log  ${WAS_INSTALL_ROOT}/IBM/updateWAS85519.xml
		./imcl uninstall com.ibm.websphere.ND.v85 -installationDirectory ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer
	fi

	## delete installation manager.
	if [ -d "${WAS_INSTALL_ROOT}/IBM/InstallationManager/eclipse/tools" ];then
		${WAS_INSTALL_ROOT}/var/ibm/InstallationManager/uninstall/uninstallc
	fi
	
	##clean files
	INISTR=$(ls ${WAS_INSTALL_ROOT}|xargs)
	INISTR2="IBM"
	if [[ ${INISTR} =~ ${INISTR2} ]];then
		ls ${WAS_INSTALL_ROOT}|grep -E 'IBM|etc|var'|xargs rm -rf 
	fi

	echo "cleaning finished."
fi

cd ${WAS_ROOT}/was/install_manager/IM_152_linux.gtk.x86
./userinst -acceptLicense --launcher.ini user-silent-install.ini -log ${WAS_INSTALL_ROOT}/IBM/InstallationManager/installLog.xml

cd ${WAS_INSTALL_ROOT}/IBM/InstallationManager/eclipse/tools

#install WAS. Version 8.5.5.1 or 8.5.5.9.

if [ ${WASVER} = 'exit' ];then
	exit 0
elif [ ${WASVER} = '8551' ];then
	./imcl -acceptLicense input  ${WAS_ROOT}/nd/responsefiles/samples/WASv85.nd.install.xml -log ${WAS_INSTALL_ROOT}/IBM/installLogWAS.xml
	./imcl install com.ibm.websphere.ND.v85 -acceptLicense -repositories ${WAS_ROOT}/8.5.5-WS-WAS-FP0000001/repository.config -installationDirectory ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer -log  ${WAS_INSTALL_ROOT}/IBM/updateWAS8551.xml
elif [ ${WASVER} = '8559' ];then
	./imcl -acceptLicense input  ${WAS_ROOT}/nd/responsefiles/samples/WASv85.nd.install.xml -log ${WAS_INSTALL_ROOT}/IBM/installLogWAS.xml
	./imcl install com.ibm.websphere.ND.v85 -acceptLicense -repositories ${WAS_ROOT}/8.5.5.9/repository.config -installationDirectory ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer -log  ${WAS_INSTALL_ROOT}/IBM/updateWAS85519.xml
else
	echo "wrong was-version arguement."
	exit 1
fi

#install JDK 7 and JDK 8.

./imcl install com.ibm.websphere.IBMJAVA.v70_7.0.1000.20120424_1539 -acceptLicense -repositories ${WAS_ROOT}/was/sdk_java/sdk_java/JAVA7/repository.config -installationDirectory  ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer -sharedResourcesDirectory ${WAS_INSTALL_ROOT}/IBM/IMShared -log ${WAS_INSTALL_ROOT}/IBM/installLogJDK7.xml 
./imcl install 7.0.1.0-WS-WASJavaSDK7-LinuxX64-IFPI55776_7.0.1000.20160126_1544 -repositories ${WAS_ROOT}/jdk1.71/repository.config -installationDirectory  ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer
./imcl install com.ibm.websphere.IBMJAVA.v80_8.0.2010.20160224_1829 -acceptLicense -repositories ${WAS_ROOT}/8.0.2.10-WS-IBMWASJAVA-Linux/repository.config -installationDirectory  ${WAS_INSTALL_ROOT}/IBM/WebSphere/AppServer -sharedResourcesDirectory ${WAS_INSTALL_ROOT}/IBM/IMShared -log ${WAS_INSTALL_ROOT}/IBM/installLogJDK8.xml

#finish

echo "WAS installation complete!"
exit 0