#!/bin/bash

echo "Do you want to build an optimized release build or debug build ?"
echo -e "\t[0] Release Build [Default]"
echo -e "\t[1] Debug Build"
read BUILD_TYPE

if [ -z $BUILD_TYPE ]; then
	BUILD_TYPE=default
fi

if [ $BUILD_TYPE = "1" ]; then
	echo -e "\texport RELEASE_BUILD="
	echo -e "\texport DEBUG_BUILD=1"
	export RELEASE_BUILD=
	export DEBUG_BUILD=1
else
	echo -e "\texport DEBUG_BUILD="
	echo -e "\texport RELEASE_BUILD=1"
	export DEBUG_BUILD=
	export RELEASE_BUILD=1
fi




echo -e "\n\nDo you want to build with appindicator-3 support ?"
echo "(You probably only want this if you're running Ubuntu Unity)"
echo -e "\t[0] Use Gtk.StatusIcon for icon in notification-area [Default]"
echo -e "\t[1] Use appindicator-3 for icon in notification-area"
read NOTIFICATION_AREA

if [ -z $NOTIFICATION_AREA ]; then
	NOTIFICATION_AREA=default
fi

if [ $NOTIFICATION_AREA = "1" ]; then
	echo -e "\texport WITH_APPINDICATOR=1"
	export WITH_APPINDICATOR=1
else
	echo -e "\texport WITH_APPINDICATOR="
	export WITH_APPINDICATOR=
fi




make
