%Code written by SAW on 1/16/20
%Designed to be run on binary event rasters which are obtained from
%continuous fluorescence traces in miniscope experiments during behavior.
%An event 'raster' is subdivided based on a time-aligned behavioral event
%(in this case, 3 sec before to 3 seconds after a state transition in the
%TST (Immobile-to-struggle or struggle-to-immobile). Then for each neuron
%in the raster, we obtain an average for all of these transitions, which
%represents a 'spike probability' for that neuron at each time point before
%and after the transition. These can be plotted for individual neurons or
%as an aggregate average activity for all neurons. 

%The code is unfinished and a number of capabilities need to be added:
%Add automatic looping with adjustments for number of instances
%Add aggregation of mean activity patterns during transitions
%Add sorting by time of peak activity
%Add significance testing
%Add quantification of cell types

%  Note: As written, this code requires manual changes for each analyzed
% brain. Specifically you must 1) define which dataset from analysis you
% are analyzing, 2) manually set the number of IS and SI instances
% depending on how many transitions of each type actually occur in that
% dataset by commenting out extra instances in two locations for each loop.

% Starting input for this code is 'analysis' variable which is a data
% structure that includes all brains for a given condition as rows and
% columns with cells that contain datasets corresponding to that brain.
% This is a lot of data, but only a few of the cells are actually used for
% this analysis. 

%clears everything except analysis data structure (this must be opened from
%a .mat file and should appear to the right in workspace. 
clearvars -except analysis kd_sigs


                                                   
%% didn't end up using these
% Set up data structure for minus 3 to plus 3 seconds outputs for various
% measures of activity
m3p3.ItoS_cell_sig_f_f0 = []; % [[ fluorescence data
m3p3.ItoS_z_sig_f_f0 = []; % [[ z score of cell_sig_f_f_0
m3p3.ItoS_raster = []; % [[ binary way of representing data -- cell on or off
m3p3.StoI_cell_sig_f_f0 = [];
m3p3.StoI_z_sig_f_f0 = [];
m3p3.StoI_raster = [];


 
%These are the three variables needed to run the code for a given dataset,
%they are redefined for a particular brain from analysis data structure.

% This section is important for defining the type of data that you want to
% base your plots on
%[[ collects 

% [[ 3 main code -- only 1 at a time works right now
sig_kd = kd_sigs(2).cell_sig_f_f0;
sig_zs = zscore(kd_sigs(2).cell_sig_f_f0); % [[ z-score of every neuron at every time point
sig_an = analysis(2).raster;

m3p3_range_ItoS = analysis(2).m3p3_range_ItoS;
m3p3_range_StoI = analysis(2).m3p3_range_StoI;

% number_of_frames finds the difference between beginning and ending frame
number_of_frames = m3p3_range_ItoS(1, 2) - m3p3_range_ItoS(1, 1) + 1; % + 1 because inclusive

%we pre-allocate matrices of zeros which will be populated with spike
%probability data. # rows equals number of neurons in that brain, # of
%columns equals 120 frames, reflecting 6 total seconds of data at 20 fps
IS_kd = zeros((size(sig_kd,1)),120);
SI_kd = zeros((size(sig_kd,1)),120);

IS_zs = zeros((size(sig_kd,1)),120);
SI_zs = zeros((size(sig_kd,1)),120);

IS_an = zeros((size(sig_kd,1)),120);
SI_an = zeros((size(sig_kd,1)),120);

%This loops through every neuron in the raster, defines a range for each
%immobile-to-struggle transition (IS1-ISn), creates a matrix of all of
%these for that neuron and takes the mean and collects the mean into the
%preallocated matrix, 'IS'

% number_of_events_IS = number of events
number_of_events_IS = size(m3p3_range_ItoS, 1);

for i = 1:size(sig_kd,1); % [[for each neuron = 119
    
    % [[IS1, IS2, IS3, etc. -- a matrix containing each one as a row?]]
    
    % number of IS1,IS2, etc. depends how many rows m3p3_range_ItoS is
    
    %[[m3p3_range_ItoS only has 9 rows -- 9 events of ItoS
        
        
    %% kd
    
    %just 1 for loop
    ISall_kd(number_of_events_IS, 120) = 0; % [[ pre-allocate ISall matrix
    
    
    %fill ISall with the signals of neuron i during each event
    for e = 1:number_of_events_IS 
        ISall_kd(e,:) = sig_kd(i, (m3p3_range_ItoS(e)):(m3p3_range_ItoS(e,2)));  
    end
    
    %find overall mean signal per frame across of all events
    ISmean_kd = mean(ISall_kd);
    
    %fill a row of IS
    IS_kd(i,:) = ISmean_kd;
    
    
    %% Z-score
    ISall_zs(number_of_events_IS, 120) = 0; % [[ pre-allocate ISall matrix
    
    for f = 1:number_of_events_IS    
        ISall_zs(f,:) = sig_zs(i, (m3p3_range_ItoS(f)):(m3p3_range_ItoS(f,2)));  
    end
    
    ISmean_zs = mean(ISall_zs);
    IS_zs(i,:) = ISmean_zs;
    
    
    %% Analysis
    ISall_an(number_of_events_IS, 120) = 0; % [[ pre-allocate ISall matrix
    
    for f = 1:number_of_events_IS    
        ISall_an(f,:) = sig_an(i, (m3p3_range_ItoS(f)):(m3p3_range_ItoS(f,2)));  
    end
    
    ISmean_an = mean(ISall_an);
    IS_an(i,:) = ISmean_an;
    
    
end

% number_of_events_SI = number of events
number_of_events_SI = size(m3p3_range_StoI, 1);

%This loop does the same as for above, but for struggle-to-immobile (StoI)
%transitions. 
for m=1:size(sig_kd,1);
    
    %% kd    
    %just 1 for loop
    SIall_kd(number_of_events_SI, 120) = 0; % [[ creating matrix -- better way to do this
    
    for j = 1:number_of_events_SI
        SIall_kd(j,:) = sig_kd(m, (m3p3_range_StoI(j)):(m3p3_range_StoI(j,2)));  
    end
    
    
    SImean_kd = mean(SIall_kd);
    
    SI_kd(m,:) = SImean_kd;
        
    %% z-score
    SIall_zs(number_of_events_SI, 120) = 0; % [[ creating matrix -- better way to do this
    
    for j = 1:number_of_events_SI
        SIall_zs(j,:) = sig_zs(m, (m3p3_range_StoI(j)):(m3p3_range_StoI(j,2)));  
    end
    
    
    SImean_zs = mean(SIall_zs);
    
    SI_zs(m,:) = SImean_zs;
    
    %% analysis
    SIall_an(number_of_events_SI, 120) = 0; % [[ creating matrix -- better way to do this
    
    for j = 1:number_of_events_SI
        SIall_an(j,:) = sig_an(m, (m3p3_range_StoI(j)):(m3p3_range_StoI(j,2)));  
    end
    
    
    SImean_an = mean(SIall_an);
    
    SI_an(m,:) = SImean_an;
    
end

% Add sorting functions
[sort_IS_kd, sort_SI_kd] = sort_max_time_fxn(IS_kd, SI_kd);
[sort_IS_zs, sort_SI_zs] = sort_max_time_fxn(IS_zs, SI_zs);
[sort_IS_an, sort_SI_an] = sort_max_time_fxn(IS_an, SI_an);

%The code below simply plots a set of resulting figures based on the
%results for a single brain using 'IS' and 'SI'

%% kd
%figure
%imagesc(IS_kd);
%colormap jet
%title('IS kd') % [[ added
%caxis([0 0.5]);

%figure
%imagesc(SI_kd);
%colormap jet
%title('SI kd') % [[ added
%caxis([0 0.5]);


%% z-score
%figure
%imagesc(IS_zs);
%colormap jet
%title('IS zs')
%caxis([0 0.5]);

%figure
%imagesc(SI_zs);
%colormap jet
%title('SI zs')
%caxis([0 0.5]);


%% analysis
%figure
%imagesc(IS_an);
%colormap jet
%title('IS an')
%caxis([0 0.5]);

%figure
%imagesc(SI_an);
%colormap jet
%title('SI an')
%caxis([0 0.5]);


%% plotted together, sorted by IS
if true
 figure;
subplot(3,2,1),imagesc(sort_IS_kd);
%colormap jet
title('IS kd sorted') % [[ added
caxis([-.1 .1]);

subplot(3,2,2),imagesc(sort_SI_kd);
%colormap jet
title('SI kd sorted') % [[ added
caxis([-.1 .1]);

subplot(3,2,3),imagesc(sort_IS_zs);
%colormap jet
title('IS zs sorted') % [[ added
caxis([-1 1]);

subplot(3,2,4),imagesc(sort_SI_zs);
%colormap jet
title('SI zs sorted') % [[ added
caxis([-1 1]);

subplot(3,2,5),imagesc(sort_IS_an);
%colormap jet
title('IS an sorted') % [[ added
%caxis([0 0.5]);

subplot(3,2,6),imagesc(sort_SI_an);
%colormap jet
title('SI an sorted') % [[ added
%caxis([0 0.5]);

end



%% If want to put results into objects later on
%% put results into m3p3 object
m3p3(2).ItoS_cell_sig_f_f0 = IS_kd;
m3p3(2).StoI_cell_sig_f_f0 = SI_kd;
