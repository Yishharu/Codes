#!/bin/bash
# Edit the event parameter in download_data_one_event.py
event="20161225"
# python3 download_data_one_event.py $event
echo "Event $event Downloaded!"
#python3 data_processing.py $event > output_download.txt
echo "Event $event Processed!"
python3 add_event_cmt.py $event #>> output_download.txt
echo "Event $event CMT Added!!"
python3 add_travel_times.py $event S P Sdiff Pdiff SKS SKKS #>> output_download.txt
echo "Travel Time Added!!"
python3 add_pierce_points.py $event 2600. Sdiff #>> output_download.txt
echo "Pierce Points Added!!"
python3 add_synthetics_topickle_extra.py $event




