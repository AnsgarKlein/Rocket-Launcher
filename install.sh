#!/bin/bash

echo "Do you want to build an optimized release build or debug build ?"
echo -e "\t[0] Release Build [Default]"
echo -e "\t[1] Debug Build"
read BUILD_TYPE

if [ -z $BUILD_TYPE ]; then
	BUILD_TYPE=default
fi

if [ $BUILD_TYPE = "1" ]; then
	echo -e "\texport RCKTL_BUILD_RELEASE="
	echo -e "\texport RCKTL_BUILD_DEBUG=1"
	export RCKTL_BUILD_RELEASE=
	export RCKTL_BUILD_DEBUG=1
else
	echo -e "\texport RCKTL_BUILD_DEBUG="
	echo -e "\texport RCKTL_BUILD_RELEASE=1"
	export RCKTL_BUILD_DEBUG=
	export RCKTL_BUILD_RELEASE=1
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
	echo -e "\texport RCKTL_FEATURE_APPINDICATOR=1"
	export RCKTL_FEATURE_APPINDICATOR=1
else
	echo -e "\texport RCKTL_FEATURE_APPINDICATOR="
	export RCKTL_FEATURE_APPINDICATOR=
fi




make $@
