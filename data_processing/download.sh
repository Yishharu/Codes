#!/bin/bash
# Goo to CMT search find the CMTSOLUTION FORMAT, 
# copy that to the event directory, and run this script after that.
event="20141116"
area="Hawaii"
distmin=90
distmax=130
azmin=0
azmax=100
#################################Edit Before This Line###############################
filename="OUTPUT-${event}"
echo "OUTPUT is redirected to file $filename #"
STARTTIME_GLOBAL=$(date +%s)
echo "##################This is OUTPUT file for downloading!#################" > "${filename}"

STARTTIME=$(date +%s)
python3 -u download_data_one_event.py $area $event $distmin $distmax $azmin $azmax >> "${filename}"
tail -1 OUTPUT &
ENDTIME=$(date +%s)
echo "Event $event Downloaded in $[$ENDTIME - $STARTTIME] s!"

STARTTIME=$(date +%s)
python3 -u data_processing.py $area $event >> "${filename}"
ENDTIME=$(date +%s)
echo "Event $event Processed in $[$ENDTIME - $STARTTIME] s!"

STARTTIME=$(date +%s)
python3 -u add_event_cmt.py $area $event >> "${filename}"
ENDTIME=$(date +%s)
echo "Event $event CMT Added in $[$ENDTIME - $STARTTIME] s!"

STARTTIME=$(date +%s)
python3 -u add_travel_times.py $area $event S P Sdiff Pdiff SKS SKKS pSdiff sSdiff>> "${filename}"
# for 135 km: S Sdiff SKiKS sSKS pSKKS sSKKS pSdiff sSdiff SP PS SKKS
# for 115 km: S Sdiff pSKKS sSKKS pSdiff sSdiff SP PS
# for 169 km: S Sdiff sSKS pSKKS sSKKS pSdiff sSdiff SP PS
# for 414km: S Sdiff pSKS pSKKS sSKS
ENDTIME=$(date +%s)
echo "Travel Time Added in $[$ENDTIME - $STARTTIME] s!"

STARTTIME=$(date +%s)
python3 -u add_pierce_points.py $area $event 2800. Sdiff >> "${filename}"
ENDTIME=$(date +%s)
echo "Pierce Points Added in $[$ENDTIME - $STARTTIME] s!"

STARTTIME=$(date +%s)
python3 -u add_synthetics_topickle.py $area $event >> "${filename}"
ENDTIME=$(date +%s)
echo "Synthetics Added in $[$ENDTIME - $STARTTIME] s!"

python3 -u STALOCATION.py $area $event >> "${filename}"

echo "Event $event Downloaded and Procesed Totally in $[$ENDTIME - $STARTTIME_GLOBAL] s!"
