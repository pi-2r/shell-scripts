#!/bin/bash

IHS_ROOT="/nas/software"
IHS_INSTALL_ROOT="/u01/scadm"

## Check existance of Installation Manager.
if [ -d "${IHS_INSTALL_ROOT}/IBM/InstallationManager/eclipse/tools" ];then
	echo "InstallationManager detected."
else
	echo "InstallationManager undetected. Installing..."
	cd ${IHS_ROOT}/was/install_manager/IM_152_linux.gtk.x86
	./userinst -acceptLicense --launcher.ini user-silent-install.ini -log ${IHS_INSTALL_ROOT}/IBM/InstallationManager/installLog.xml
fi


## Initializing, delete IHS that's already been installed.
if [ -d "${IHS_INSTALL_ROOT}/IBM" ];then
	if [ -d "${IHS_INSTALL_ROOT}/IBM/HTTPServer" ];then
		./imcl uninstall com.ibm.websphere.WCT.v85 -installationDirectory ${IHS_INSTALL_ROOT}/IBM/WebSphere/Toolbox
		./imcl uninstall com.ibm.websphere.PLG.v85 -installationDirectory ${IHS_INSTALL_ROOT}/IBM/WebSphere/Plugins
		./imcl uninstall com.ibm.websphere.IHS.v85 -installationDirectory ${IHS_INSTALL_ROOT}/IBM/HTTPServer
	fi

	##clean files
	INISTR=$(ls ${IHS_INSTALL_ROOT}/IBM |xargs)
	INISTR2="HTTPServer"
	if [[ ${INISTR} =~ ${INISTR2} ]];then
		ls ${IHS_INSTALL_ROOT}/IBM|grep -E 'HTTPServer'|xargs rm -rf 
	fi

	echo "cleaning finished. Start installing IHS."
fi


cd ${IHS_INSTALL_ROOT}/IBM/InstallationManager/eclipse/tools

## Install IHS
./imcl -acceptLicense input ${IHS_ROOT}/WASv85.ihs.install.xml -log ${IHS_INSTALL_ROOT}/IBM/installLogIHS.xml
./imcl install com.ibm.websphere.IHS.v85 -acceptLicense -repositories ${IHS_ROOT}/ihs_update/repository.config -installationDirectory ${IHS_INSTALL_ROOT}/IBM/HTTPServer -log  ${IHS_INSTALL_ROOT}/IBM/updateIHS8551.xml

## Install Plugin
./imcl -acceptLicense input ${IHS_ROOT}/WASv85.plg.install.xml -log ${IHS_INSTALL_ROOT}/IBM/installLogPlugins.xml

## Install WCT
./imcl -acceptLicense input ${IHS_ROOT}/WASv85.wct.install.xml -log ${IHS_INSTALL_ROOT}/IBM/installLogToolbox.xml

## Finish
echo "IHS installation complete!"
exit 0