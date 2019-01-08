% clear all;
%%%%%%%%%%%%%% Edit After This Line %%%%%%%%%%%%
cd /raid3/zl382/Data/20100320/for_matlab/
addpath('/home/zl382/Codes/plot_script/')
delete filtered_*.mat
wname = 'amor'
comp = 'BHT'
disp('fmin:')
disp(fmin)
if_norm = true;
No = 10;  %  Num of Octaves <= floor(log2(numel(x)))-1
Nv = 48;  %  Num of voices per octave 
%%%%%%%%%%%%%% Edit Before This Line %%%%%%%%%%%%
load('pickle_mat_interface.mat')

for i = 1:size(sname,1)
    for j = 1:3     
        infilename = strcat(sname(i,:),'_',comp,'.mat')
        outfilename = strcat('filtered_',infilename)
        load(infilename)
        ts = times(2)-times(1);
        % [wt, period, coi] = cwt(data,seconds(ts),wname,'VoicesPerOctave',20,'NumOctaves');
        [wt, period, coi] = cwt(data,seconds(ts),wname,'VoicesPerOctave', Nv);

        data_filter = icwt(wt, wname, period, [seconds(fmin) seconds(fmax)],'SignalMean', 0);

        save (outfilename, 'data_filter') %,'phase','phasetime') 
    end
end
