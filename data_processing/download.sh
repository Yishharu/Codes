#!/bin/bash
# Goo to CMT search find the CMTSOLUTION FORMAT, 
# copy that to the event directory, and run this script after that.
event="20170122"
distmin=94
distmax=130
azmin=30
azmax=90
#################################Edit Before This Line###############################
filename="OUTPUT-${event}"
echo "OUTPUT is redirected to file $filename #"
STARTTIME_GLOBAL=$(date +%s)
echo "##################This is OUTPUT file for downloading!#################" > "${filename}"

# STARTTIME=$(date +%s)
# python3 -u download_data_one_event.py $event $distmin $distmax $azmin $azmax >> "${filename}"
# tail -1 OUTPUT &
# ENDTIME=$(date +%s)
# echo "Event $event Downloaded in $[$ENDTIME - $STARTTIME] s!"

STARTTIME=$(date +%s)
python3 -u data_processing.py $event >> "${filename}"
ENDTIME=$(date +%s)
echo "Event $event Processed in $[$ENDTIME - $STARTTIME] s!"

STARTTIME=$(date +%s)
python3 -u add_event_cmt.py $event >> "${filename}"
ENDTIME=$(date +%s)
echo "Event $event CMT Added in $[$ENDTIME - $STARTTIME] s!"

STARTTIME=$(date +%s)
python3 -u add_travel_times.py $event S P Sdiff Pdiff SKS SKKS >> "${filename}"
ENDTIME=$(date +%s)
echo "Travel Time Added in $[$ENDTIME - $STARTTIME] s!"

STARTTIME=$(date +%s)
python3 -u add_pierce_points.py $event 2600. Sdiff >> "${filename}"
ENDTIME=$(date +%s)
echo "Pierce Points Added in $[$ENDTIME - $STARTTIME] s!"

STARTTIME=$(date +%s)
python3 -u add_synthetics_topickle.py $event >> "${filename}"
ENDTIME=$(date +%s)
echo "Synthetics Added in $[$ENDTIME - $STARTTIME] s!"


echo "Event $event Downloaded and Procesed Totally in $[$ENDTIME - $STARTTIME_GLOBAL] s!"