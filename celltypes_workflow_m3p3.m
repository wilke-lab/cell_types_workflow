% Code updated on 3/5/20 by Kyle Fang
% All bugs fixed and this code works specifically for transition periods of 3
% seconds before and after.
% The data this code outputs is plotted and put into the struct
% result_struct.

% This code has 2 different data sets ready to load into ItoS_epoch_edge_frames
% and StoI_epoch_edge_frames. The data set currently active is 3 seconds before
% and after each change in behavior.

% In order to access the other data set -- beginning (60 frames), middle (60
% frames), and end (60 frames) epochs of each change in behavior --
% comment out the "Loading into ItoS_epoch_edge_frames and StoI_epoch_edge_frames" and
% uncomment the "loading different data" section

% Code written by SAW on 1/23/20
% This code is based on celltypes_workflow_v3.mat which was written by Kyle
% Fang and Scott Wilke in January 2020. 


clearvars -except analysis kd_sigs

frames_per_bin = 1;

[not_needed, number_of_mice] = size(analysis);

% storing results in result_struct
result_struct = struct;

total_frames = 120;

for mouse = 1:number_of_mice
%for mouse = 4:6
%for mouse = 5
    %% Loading m3p3 data
    %mouse = 11
    ItoS_epoch_edge_frames = analysis(mouse).m3p3_range_ItoS;
    StoI_epoch_edge_frames = analysis(mouse).m3p3_range_StoI;
    
    
    %% code above is manual input, code below works automatically
    % 3 main types of analyses
    sig_kd = kd_sigs(mouse).cell_sig_f_f0;
    sig_zs = zscore(kd_sigs(mouse).cell_sig_f_f0);
    sig_ra = analysis(mouse).raster;
             
    % we pre-allocate matrices of zeros which will be populated with spike
    % probability data
    IS_kd = zeros((size(sig_kd,1)), total_frames);
    SI_kd = zeros((size(sig_kd,1)), total_frames);

    IS_zs = zeros((size(sig_zs,1)), total_frames);
    SI_zs = zeros((size(sig_zs,1)), total_frames);

    IS_ra = zeros((size(sig_ra,1)), total_frames);
    SI_ra = zeros((size(sig_ra,1)), total_frames);

    % number_of_events_IS represents number of immobile to struggling events
    number_of_events_IS = size(ItoS_epoch_edge_frames, 1);


    %% IS -- Immobile to Struggling
    ISall_kd = zeros(number_of_events_IS, total_frames);
    ISall_zs = zeros(number_of_events_IS, total_frames);
    ISall_ra = zeros(number_of_events_IS, total_frames);
    
    %% Fill IS_kd, IS_zs, IS_ra
    for i = 1:size(sig_kd,1) % loop through each neuron
        % fill ISall with the signals of neuron i during each event

        for row = 1:number_of_events_IS   % loop through each event

            ISall_kd(row, (1:total_frames)) = ...
            sig_kd(i, ItoS_epoch_edge_frames(row, 1) : ItoS_epoch_edge_frames(row, 2));

            ISall_zs(row, (1:total_frames)) = ...
            sig_zs(i, ItoS_epoch_edge_frames(row, 1) : ItoS_epoch_edge_frames(row, 2));

            ISall_ra(row, (1:total_frames)) = ...
            sig_ra(i, ItoS_epoch_edge_frames(row, 1) : ItoS_epoch_edge_frames(row, 2));

        end

        % find overall mean signal per frame across of all events
        ISmean_kd = mean(ISall_kd);
        ISmean_zs = mean(ISall_zs);
        ISmean_ra = mean(ISall_ra);

        % fill a row of IS
        IS_kd(i,:) = ISmean_kd;
        IS_zs(i,:) = ISmean_zs;
        IS_ra(i,:) = ISmean_ra;

    end

    %% Struggling to Immobile -- SI
    % number_of_events_SI represents number of struggling to immobile events
    number_of_events_SI = size(StoI_epoch_edge_frames, 1);

    % pre-allocate SIall matrices    
    SIall_kd = zeros(number_of_events_SI, total_frames);
    SIall_zs = zeros(number_of_events_SI, total_frames);
    SIall_ra = zeros(number_of_events_SI, total_frames);

    %% Fill SI_kd, SI_zs, SI_ra
    for i = 1:size(sig_kd,1) % loop through each neuron

        % fill SIall with the signals of neuron i during each event
        for row = 1:number_of_events_SI   % loop through each event
            
            SIall_kd(row, (1:total_frames)) = ...
            sig_kd(i, StoI_epoch_edge_frames(row, 1) : StoI_epoch_edge_frames(row, 2));

            SIall_zs(row, (1:total_frames)) = ...
            sig_zs(i, StoI_epoch_edge_frames(row, 1) : StoI_epoch_edge_frames(row, 2));

            SIall_ra(row, (1:total_frames)) = ...
            sig_ra(i, StoI_epoch_edge_frames(row, 1) : StoI_epoch_edge_frames(row, 2));    

        end

        %find overall mean signal per frame across of all events
        SImean_kd = mean(SIall_kd);
        SImean_zs = mean(SIall_zs);
        SImean_ra = mean(SIall_ra);

        %fill a row of SI
        SI_kd(i,:) = SImean_kd;
        SI_zs(i,:) = SImean_zs;
        SI_ra(i,:) = SImean_ra;
    end

    %% sort results
    [sort_IS_kd, sort_SI_kd] = sort_max_time_fxn(IS_kd, SI_kd);
    [sort_IS_zs, sort_SI_zs] = sort_max_time_fxn(IS_zs, SI_zs);
    [sort_IS_ra, sort_SI_ra] = sort_max_time_fxn(IS_ra, SI_ra);

    %% The code below plots a set of resulting figures based on the
    %% results for a single brain using 'IS' and 'SI'

    %% Plot 1 frame per Bin    
    if true
     figure;
    sgtitle({"Mouse " + mouse, "mouseNum: " + analysis(mouse).mouseNum, "Frames per bin " + frames_per_bin})
    subplot(3,2,1),imagesc(sort_IS_kd);

    %colormap jet
    title('IS kd sorted')
    caxis([-.1 .1]);
    subplot(3,2,2),imagesc(sort_SI_kd);

    %colormap jet
    title('SI kd sorted')
    caxis([-.1 .1]);
    subplot(3,2,3),imagesc(sort_IS_zs);

    %colormap jet
    title('IS zs sorted')
    caxis([-1 1]);
    subplot(3,2,4),imagesc(sort_SI_zs);

    %colormap jet
    title('SI zs sorted')
    caxis([-1 1]);
    subplot(3,2,5),imagesc(sort_IS_ra);

    %colormap jet
    title('IS ra sorted')
    %caxis([0 0.5]);
    subplot(3,2,6),imagesc(sort_SI_ra);

    %colormap jet
    title('SI ra sorted')
    %caxis([0 0.5]);
    end
        


    %% put results into result_struct
    m3p3(2).ItoS_cell_sig_f_f0 = IS_kd;
    m3p3(2).StoI_cell_sig_f_f0 = SI_kd;

    % record name
    result_struct(mouse).mouseNum = analysis(mouse).mouseNum;
    
    % record IS data
    result_struct(mouse).sort_IS_kd = sort_IS_kd;
    result_struct(mouse).sort_IS_zs = sort_IS_zs;
    result_struct(mouse).sort_IS_ra = sort_IS_ra;
    
    % record SI data
    result_struct(mouse).sort_SI_kd = sort_SI_kd;
    result_struct(mouse).sort_SI_zs = sort_SI_zs;
    result_struct(mouse).sort_SI_ra = sort_SI_ra;                        
end
