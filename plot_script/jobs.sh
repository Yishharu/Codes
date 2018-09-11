#/bin/sh
python3 ../plot_script/plot_data_azimuth.py 20170110NEW > output.txt
echo '20170110NEW Finished!' 
python3 ../plot_script/plot_data_azimuth.py 20100320 >> output.txt
echo '20100320 Finished!' 
python3 ../plot_script/plot_data_azimuth.py 20141202 >> output.txt
echo '20141202 Finished!'
