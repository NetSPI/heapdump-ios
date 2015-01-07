#!/bin/bash
if [ "$1" == "" ]
	then
		echo "Usage: ./$0 <binary_name>"
		exit 1
fi
version=`gdb --version | head -n1 | grep -o -E "gdb\-[0-9]{4}" | awk -F'-' '{print $2}'`
if [ "$version" == "" ]
	then
		version=0
fi
if [ $version -ge 1708 ]
	then 
		PID=`ps -ax | grep "$1" | grep -v grep | grep "app" | awk '{print $1}'`
		echo "App Pid: $PID"
		echo "GDB Version: $version"
		rm gdbcmd.txt &>> /dev/null
		echo ""
		echo "info mach-regions" >> tmp.txt
		gdb --pid="$PID" --batch --command=tmp.txt 2>/dev/null | grep sub-regions | awk '{print $3,$5}' | while read range; do
			echo "mach-regions: $range"
			cmd="dump binary memory dump`echo $range| awk '{print $1}'`.dmp $range"
			echo "$cmd" >> gdbcmd.txt
		done
		rm tmp.txt
		echo ""
		echo -n "Dumping memory: "
		gdb --pid=$PID --batch --command=gdbcmd.txt &>>/dev/null
		echo "Done"
else
		echo "GDB version is not correct: $version"
fi
