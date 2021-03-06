% Code updated on 3/5/20 by Kyle Fang
% All bugs fixed and this code works specifically for epochs.
% The data this code outputs is plotted and put into the struct
% result_struct.

% Code updated on 2/7/20 by Kyle Fang
% This code can now take in as many epochs within a behavior as needed, as
% long as the ItoS_epoch_edge_frames and StoI_epoch_edge_frames are formatted as below:
% [start frame 1, end frame 1, start frame 2, end frame 2, etc.]

% Code written by SAW on 1/23/20
% This code is based on celltypes_workflow_v3.mat which was written by Kyle
% Fang and Scott Wilke in January 2020. The difference is that this code has
% been modified to run a similar analysis, but to look at how activity
% changes across struggling vs. immobility (rather than during transitions
% between these two types of behavior). Basically, because struggling and
% immobility vary in length, we need a way to define points of comparison at
% the beginning, middle and end of each epoch. This code takes epochs that
% are already longer than 180 frames at minimum and subdivides them into 60
% frame chunks taken from the beginning, middle and end of the epoch. Then
% it will take those three separate chunks and plot activity as per the
% original workflow.


clearvars -except analysis kd_sigs

frames_per_bin = 1;

[not_needed, number_of_mice] = size(analysis);

% storing results in result_struct
result_struct = struct;

for mouse = 1:number_of_mice
    %% Loading epoch data into ItoS_epoch_edge_frames and StoI_epoch_edge_frames
        
    % loading struggle and immobile epochs
    struggle_range_long = analysis(mouse).struggle_range_long; % contains start and end times
    immobile_range_long = analysis(mouse).immobile_range_long;
    
    %% Breaking down long struggle epochs into 3 equal sized chunks, beg, middle, and end
    %% Struggle
    s_rangeL_beg = [struggle_range_long(:,1), struggle_range_long(:,1) + 59];
    s_rangeL_end = [struggle_range_long(:,2) - 59, struggle_range_long(:,2)];
    % s_rangeL_mid contains the very middle of each epoch
    s_rangeL_mid = (size(struggle_range_long,1));
    s_rangeL_mid = zeros(s_rangeL_mid,2); % s_rangeL_mid = zeros(size(struggle_range_long, 1), 2)
    for t = 1:size(struggle_range_long,1) % for each epoch
        m = struggle_range_long(t,:);
        temp = m(1):m(2);
        temp2 = floor(median(temp));
        start = temp2-30;
        stop = temp2+29; % now med start and finish have 59 difference (60 frames inclusive)
        insert = [start stop];
        s_rangeL_mid(t,1)=insert(1,1);
        s_rangeL_mid(t,2)=insert(1,2);
    end
    
    %% Immobile
    % Breaking down long immobile epochs into 3 equal sized chunks, beg,
    % middle, end
    i_rangeL_beg = [immobile_range_long(:,1), immobile_range_long(:,1) + 59];
    i_rangeL_end = [immobile_range_long(:,2) - 59, immobile_range_long(:,2)];
    %% i_rangeL_mid
    i_rangeL_mid = (size(immobile_range_long,1));
    i_rangeL_mid = zeros(i_rangeL_mid,2);
    for t = 1:size(immobile_range_long,1)
        m = immobile_range_long(t,:);
        temp = m(1):m(2);
        temp2 = floor(median(temp));
        start = temp2-30;
        stop = temp2+29; % now med start and finish have 59 difference (60 frames inclusive)
        insert = [start stop];
        i_rangeL_mid(t,1)=insert(1,1);
        i_rangeL_mid(t,2)=insert(1,2);
    end
    
    % ItoS_epoch_edge_frames is a matrix where it has
    % beg start frame, beg last frame, mid start frame, mid last frame, end start frame, end last frame
    ItoS_epoch_edge_frames = i_rangeL_beg;
    [ItoS_epoch_edge_frames_rows, ItoS_epoch_edge_frames_cols] = size(ItoS_epoch_edge_frames);
    ItoS_epoch_edge_frames(:, ItoS_epoch_edge_frames_cols + 1:ItoS_epoch_edge_frames_cols + 2) = i_rangeL_mid;
    [ItoS_epoch_edge_frames_rows, ItoS_epoch_edge_frames_cols] = size(ItoS_epoch_edge_frames);
    ItoS_epoch_edge_frames(:, ItoS_epoch_edge_frames_cols + 1:ItoS_epoch_edge_frames_cols + 2) = i_rangeL_end;
        
    % StoI_epoch_edge_frames is a matrix that contains
    % beg start frame, beg last frame, mid start frame, mid last frame, end start frame, end last frame
    StoI_epoch_edge_frames = s_rangeL_beg;
    [StoI_epoch_edge_frames_rows, StoI_epoch_edge_frames_cols] = size(StoI_epoch_edge_frames);
    StoI_epoch_edge_frames(:, StoI_epoch_edge_frames_cols + 1:StoI_epoch_edge_frames_cols + 2) = s_rangeL_mid;
    [StoI_epoch_edge_frames_rows, StoI_epoch_edge_frames_cols] = size(StoI_epoch_edge_frames);
    StoI_epoch_edge_frames(:, StoI_epoch_edge_frames_cols + 1:StoI_epoch_edge_frames_cols + 2) = s_rangeL_end;
        
    
    %% code above is manual input, code below works automatically

    % 3 main types of analyses
    sig_kd = kd_sigs(mouse).cell_sig_f_f0;
    sig_zs = zscore(kd_sigs(mouse).cell_sig_f_f0);
    sig_ra = analysis(mouse).raster;

    % number_of_epoch within a behavior
    [not_needed, number_of_epoch] = size(ItoS_epoch_edge_frames);

    % now number_of_epoch has the accurate number of epoch
    number_of_epoch = number_of_epoch / 2;
    number_of_frames_per_epoch = zeros(1, number_of_epoch);

    for i = 1:number_of_epoch
        number_of_frames_per_epoch(1, (i)) = ItoS_epoch_edge_frames(1, i * 2) - ItoS_epoch_edge_frames(1, i * 2 - 1) + 1;
    end

    total_frames = sum(number_of_frames_per_epoch);

    % we pre-allocate matrices of zeros which will be populated with spike
    % probability data
    IS_kd = zeros((size(sig_kd,1)), total_frames);
    SI_kd = zeros((size(sig_kd,1)), total_frames);

    IS_zs = zeros((size(sig_kd,1)), total_frames);
    SI_zs = zeros((size(sig_kd,1)), total_frames);

    IS_ra = zeros((size(sig_kd,1)), total_frames);
    SI_ra = zeros((size(sig_kd,1)), total_frames);

    % number_of_events_IS represents number of immobile to struggling events
    number_of_events_IS = size(ItoS_epoch_edge_frames, 1);

    
    %% IS -- Immobile to Struggling
    % pre-allocate Isall matrices        
    ISall_kd = zeros(number_of_events_IS, total_frames);
    ISall_zs = zeros(number_of_events_IS, total_frames);
    ISall_ra = zeros(number_of_events_IS, total_frames);


    %% Fill IS_kd, IS_zs, IS_ra
    for i = 1:size(sig_kd,1) % loop through each neuron
        % fill ISall with the signals of neuron i during each event

        for row = 1:number_of_events_IS   % loop through each event

            start_index = 1;

            for m = 1:number_of_epoch
                ISall_kd(row, (start_index: (start_index + number_of_frames_per_epoch(m) - 1)))...
                = sig_kd(i, ItoS_epoch_edge_frames(row, m * 2 - 1) : ItoS_epoch_edge_frames(row, m * 2));

                ISall_zs(row, (start_index: (start_index + number_of_frames_per_epoch(m) - 1)))...
                = sig_zs(i, ItoS_epoch_edge_frames(row, m * 2 - 1) : ItoS_epoch_edge_frames(row, m * 2));

                ISall_ra(row, (start_index: (start_index + number_of_frames_per_epoch(m) - 1)))...
                = sig_ra(i, ItoS_epoch_edge_frames(row, m * 2 - 1) : ItoS_epoch_edge_frames(row, m * 2));

                start_index = start_index + number_of_frames_per_epoch(m);
            end

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

            start_index = 1;
            for m = 1:number_of_epoch
                SIall_kd(row, (start_index: (start_index + number_of_frames_per_epoch(m) - 1)))...
                = sig_kd(i, StoI_epoch_edge_frames(row, m * 2 - 1) : StoI_epoch_edge_frames(row, m * 2));

                SIall_zs(row, (start_index: (start_index + number_of_frames_per_epoch(m) - 1)))...
                = sig_zs(i, StoI_epoch_edge_frames(row, m * 2 - 1) : StoI_epoch_edge_frames(row, m * 2));

                SIall_ra(row, (start_index: (start_index + number_of_frames_per_epoch(m) - 1)))...
                = sig_ra(i, StoI_epoch_edge_frames(row, m * 2 - 1) : StoI_epoch_edge_frames(row, m * 2));

                start_index = start_index + number_of_frames_per_epoch(m);

            end

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
     
    % title of whole figure
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
