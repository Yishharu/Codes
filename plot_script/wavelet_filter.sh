#/bin/sh
event=20100320
fmin=1     # seconds
fmax=5     # seconds
component=BHT

echo python3 ../plot_script/wavelet_to_matlab.py "${event}" "${component}"
python3 ../plot_script/wavelet_to_matlab.py "${event}" "${component}" > output.txt
echo "${event} to matlab files Finished"

echo matlab -nojvm -nodesktop -r "try,fmin=${fmin},fmax=${fmax},my_wavelet_filter,catch,end,quit"
matlab -nojvm -nodesktop -r "try,fmin=${fmin},fmax=${fmax},my_wavelet_filter,catch,end,quit" >> output.txt
echo  "${event} matlab filter Finished"

echo python3 ../plot_script/wavelet_filter_toplot.py "${event}" "${component}"
python3 ../plot_script/wavelet_filter_toplot.py "${event}" "${component}" >> output.txt
echo "${event} waveform plot Finished"
