cd /raid3/zl382/Data/2010320/for_matlab/

clear all;
wname = 'amor'
if_norm = true;
No = 10;  %  Num of Octaves <= floor(log2(numel(x)))-1
Nv = 48;  %  Num of voices per octave 
load('pickle_mat_interface.mat')
comp(1,:) = 'BHT';
comp(2,:) = 'BHR';
comp(3,:) = 'BHZ';


for i = 1:size(sname,1)
    for j = 1:3     
        infilename = strcat(sname(i,:),'_',comp(j,:),'.mat')
        outfilename = strcat('toplot_',infilename)
        load(infilename)
        ts = times(2)-times(1)
        % [wt, period, coi] = cwt(data,seconds(ts),wname,'VoicesPerOctave',20,'NumOctaves');
        [wt, period, coi] = cwt(data,seconds(ts),wname,'VoicesPerOctave', Nv);
        T = seconds(period);
        i_start = find(T>1,1);
        i_end = find(T>25,1);
        T_toplot = T(i_start:i_end);

        data_filter = icwt(wt, wname, period, [seconds(10) seconds(30)],'SignalMean', 0);
        for ft = i_start:i_end
            t = period(ft)
            xrec = icwt(wt,period, wname, [t*0.8 t*1.2], 'SignalMean', 0);
            if if_norm
                norm = max(abs(xrec))/4.0;
            else norm = 1.0;
            end
            if ft == i_start
                toplot = xrec./norm;
            else
                toplot = vertcat(toplot, xrec./norm);
            end
        end
        save (outfilename, 'toplot', 'T_toplot', 'data_filter') %,'phase','phasetime') 
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load('OUT_ULVZ10km_1s_mtp500kmPICKLES.mat')
% 
% [wt, period, coi] = cwt(data,seconds(ts), wname, 'VoicesPerOctave', Nv);
% data_filter = icwt(wt, period, wname, [seconds(10) seconds(40)],'SignalMean', mean(data));
% 
% for ft = i_start:i_end
%     t = period(ft)
%     xrec = icwt(wt,period, wname, [t*0.8 t*1.2],'SignalMean', mean(data));
%     if if_norm
%         norm = max(abs(xrec))/4.0;
%     else norm = 1.0;
%     end
%     if ft == i_start
%         toplot = xrec./norm;
%     else
%         toplot = vertcat(toplot, xrec./norm);
%     end
% end
% 
% save toplot_OUT_ULVZ10km_1s_mtp500kmPICKLES.mat toplot T_toplot data_filter
% % d = sin(2*pi*t/5) + sin(2*pi*t/2);
% % d = sin(2*pi*t/5) + sin(2*pi*t/2);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % load('OUT_ULVZ20km_1s_mtp500kmPICKLES.mat')
% load('ULVZ10km_1sPICKLES.mat')
% 
% 
% [wt, period, coi] = cwt(data, seconds(ts), wname, 'VoicesPerOctave', Nv);
% data_filter = icwt(wt, period, wname, [seconds(10) seconds(40)],'SignalMean', mean(data));
% 
% for ft = i_start:i_end
%     t = period(ft)
%     xrec = icwt(wt,period, wname, [t*0.8 t*1.2],'SignalMean', mean(data));
%     if if_norm
%         norm = max(abs(xrec))/4.0;
%     else norm = 1.0;
%     end
%     if ft == i_start
%         toplot = xrec./norm;
%     else
%         toplot = vertcat(toplot, xrec./norm);
%     end
% end
% 
% save toplot_ULVZ10km_1sPICKLES.mat toplot T_toplot data_filter


% for i = 1:size(events,1)
%     event = events(i,:)
%     load(event)
    
    
    
    
% t = -10:0.1:100;
% d = sin(2*pi*t/5) + sin(2*pi*t/2);
% plot(t,d);
% [wt, f] = cwt(d,10);
% figure
% xrec = icwt(wt, f, [0.1, 0.15],'SignalMean', mean(data));
% plot(t,xrec)
% figure
% xrec = icwt(wt, f, [0.15, 0.25],'SignalMean', mean(data));
% plot(t,xrec)
% figure
% xrec = icwt(wt, f, [0.45, 0.55],'SignalMean', mean(data));
% plot(t,xrec)