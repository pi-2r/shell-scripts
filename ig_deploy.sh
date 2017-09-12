#!/bin/bash

source /etc/profile

function stop_services(){
	# stop ig-admin service
	ID=`ps -ef | grep $1 | grep -v "grep" | awk '{print $2}'`
	echo "########## These processes will be killed : "$ID
	for id in $ID
	do
	kill -9 $id
	echo "----------killed PID : $id"
	done
}

function deploy_services(){
	echo '-----------stop $1-------------'
	stop_services $1.jar

	echo '-----------deploy $1-------------'
	#delete old jar file
	rm -rf  /u01/scadm/app/ig-admin.jar

	#copy new files
	cp /u01/scadm/app/tmp_app/ig-parent/$1/target/$1.jar /u01/scadm/app/$1.jar
	echo "Finish deploying."

	echo '-----------start $1-------------'
	#start new application
	#java -jar /u01/scadm/app/$1.jar >> $1.log &
	nohup java -jar -Xms128m -Xmx1024m -XX:MaxPermSize=1024m $1.jar &
	echo "Application started."
}

if [ $1 = 'ig-admin' ] || [ $1 = 'ig-rs' ] || [ $1 = 'all' ]; then
	if [ $1 = 'all' ];then
		deploy_services ig-admin
		deploy_services ig-rs
	else
		deploy_services $1
	fi
else
	echo "There's not any jar file matched the name: "$1
fi

#delete copied files
rm -rf /u01/scadm/app/tmp_app/ig-parent/ig-admin/target

ps -ef | grep $1 | grep -v "grep" |grep -v "d.sh"
echo "All done."