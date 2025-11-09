#!/bin/bash

if ! [ 2 -eq $# ]; then
	echo "Error: Invalid number of arguments."
	exit 2
fi

if ! [[ "-E -L -O" =~ ( |^)$1( |$) ]]; then
	echo "Error: Unknown argument '$1'."
	exit 2
fi

case $1 in
	"-O")
		echo "creating library node $2..."
		mkdir -p $2
		cp ./templates/onode.mk ./$2/Makefile
	;;
	"-E")
		echo "creating library node $2..."
		mkdir -p $2
		cp ./templates/main.c ./$2/
	;;
	"-L")
		echo "creating library node $2... s/\$1/$(basename ${2^^})/g ./$2/sayhello.c"
		mkdir -p $2
		cp ./templates/sayhello.c ./$2/
		cp ./templates/sayhello.h ./$2/
		sed -i s/\$1/$(basename ${2^^})/g ./$2/sayhello.h
		sed -i s/\$1/$(basename ${2^^})/g ./$2/sayhello.c
	;;
esac
echo "Done"
