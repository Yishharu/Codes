#!/bin/bash
# Edit the event parameter in download_data_one_event.py, 
# then go to CMT search find the CMTSOLUTION FORMAT, 
# copy that to the event directory, and run this script after that.
event="20161225_test"
STARTTIME_GLOBAL=$(date +%s)
echo "This is OUTPUT file for downloading!" > OUTPUT


STARTTIME=$(date +%s)
python3 -u download_data_one_event.py $event >> OUTPUT
tail -1 output_download.txt &
echo "Event $event Downloaded in $[$ENDTIME - $STARTTIME] s!"

STARTTIME=$(date +%s)
python3 -u data_processing.py $event >> OUTPUT
ENDTIME=$(date +%s)
echo "Event $event Processed in $[$ENDTIME - $STARTTIME] s!"

STARTTIME=$(date +%s)
python3 -u add_event_cmt.py $event >> OUTPUT
ENDTIME=$(date +%s)
echo "Event $event CMT Added in $[$ENDTIME - $STARTTIME] s!"

STARTTIME=$(date +%s)
python3 -u add_travel_times.py $event S P Sdiff Pdiff SKS SKKS >> OUTPUT
ENDTIME=$(date +%s)
echo "Travel Time Added in $[$ENDTIME - $STARTTIME] s!"

STARTTIME=$(date +%s)
python3 -u add_pierce_points.py $event 2600. Sdiff >> OUTPUT
ENDTIME=$(date +%s)
echo "Pierce Points Added in $[$ENDTIME - $STARTTIME] s!"

STARTTIME=$(date +%s)
python3 -u add_synthetics_topickle_extra.py $event >> OUTPUT
ENDTIME=$(date +%s)
echo "Synthetics Added in $[$ENDTIME - $STARTTIME] s!"


echo "Event $event Downloaded and Procesed Totally in $[$ENDTIME - $STARTTIME_GLOBAL] s!"