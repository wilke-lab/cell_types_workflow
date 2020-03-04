% Code updated on 2/7/20 by Kyle Fang
% This code can now take in as many epochs within a behavior as needed, as
% long as the ItoS_epoch_edge_frames and StoI_epoch_edge_frames are formatted as below:
% [start frame 1, end frame 1, start frame 2, end frame 2, etc.]

% This code has 2 different data sets ready to load into ItoS_epoch_edge_frames
% and StoI_epoch_edge_frames. The data set currently active is 3 seconds before
% and after each change in behavior.


% In order to access the other data set -- beginning (60 frames), middle (60
% frames), and end (60 frames) epochs of each change in behavior --
% comment out the "Loading into ItoS_epoch_edge_frames and StoI_epoch_edge_frames" and
% uncomment the "loading different data" section


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


clearvars -except analysis kd_sigs a_no_del a_del

%% Prompt user for frames per bin

prompt = "Please input the number of frames per bin: \n";

frames_per_bin = input(prompt);

count = 0; % delete -- not needed

[not_needed, number_of_mice] = size(analysis);

result_struct = struct;

total_frames = 120;

for mouse = 1:number_of_mice
%for mouse = 4:6
%for mouse = 5
    %% Loading m3p3 data
    %mouse = 11
    ItoS_epoch_edge_frames = analysis(mouse).m3p3_range_ItoS;
    StoI_epoch_edge_frames = analysis(mouse).m3p3_range_StoI;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 2 or mouse?????
    % 3 main types of code
%     sig_kd = kd_sigs(2).cell_sig_f_f0;
%     sig_zs = zscore(kd_sigs(2).cell_sig_f_f0);
%     sig_ra = analysis(2).raster;
    
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

    %% sort original results
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
    %subplot(3,2,1),imagesc(IS_kd);
    %colormap jet
    title('IS kd sorted')
    caxis([-.1 .1]);
    subplot(3,2,2),imagesc(sort_SI_kd);
    %subplot(3,2,2),imagesc(SI_kd);
    %colormap jet
    title('SI kd sorted')
    caxis([-.1 .1]);
    subplot(3,2,3),imagesc(sort_IS_zs);
    %subplot(3,2,3),imagesc(IS_zs);
    %colormap jet
    title('IS zs sorted')
    caxis([-1 1]);
    subplot(3,2,4),imagesc(sort_SI_zs);
    %subplot(3,2,4),imagesc(SI_zs);
    %colormap jet
    title('SI zs sorted')
    caxis([-1 1]);
    subplot(3,2,5),imagesc(sort_IS_ra);
    %subplot(3,2,5),imagesc(IS_ra);
    %colormap jet
    title('IS ra sorted')
    %caxis([0 0.5]);
    subplot(3,2,6),imagesc(sort_SI_ra);
    %subplot(3,2,6),imagesc(SI_ra);
    %colormap jet
    title('SI ra sorted')
    %caxis([0 0.5]);
    end
    

  
    %% bins    
    %{
    
    %% NOTE: The number of frames per bin MUST be a factor of total number of
    %% frames or the code will break.
      
    %% Ensure user's number of of frames is a factor of the total number of frames
        
    while mod(total_frames, frames_per_bin) ~= 0
        prompt = "Please input a new number of frames per bin: \n" + ...
        "(note, your input should be a factor of " ...
        + total_frames + " - the total number of frames)\n\n";

        frames_per_bin = input(prompt);
    end
    

    bins_IS_kd = zeros((size(sig_kd,1)) , (total_frames/frames_per_bin));
    bins_IS_zs = zeros((size(sig_zs,1)) , (total_frames/frames_per_bin));
    bins_IS_ra = zeros((size(sig_ra,1)) , (total_frames/frames_per_bin));

    bins_SI_kd = zeros((size(sig_kd,1)) , (total_frames/frames_per_bin));
    bins_SI_zs = zeros((size(sig_kd,1)) , (total_frames/frames_per_bin));
    bins_SI_ra = zeros((size(sig_kd,1)) , (total_frames/frames_per_bin));

    
        
    for i = 1:size(sig_kd,1) % loop through each neuron
        %for j = 1:(length(IS_kd)/frames_per_bin)
        for j = 1:(total_frames/frames_per_bin)
            % IS
            bins_IS_kd(i, j) = mean(IS_kd(i, (j * frames_per_bin - frames_per_bin + 1):(j * frames_per_bin)));
            bins_IS_zs(i, j) = mean(IS_zs(i, (j * frames_per_bin - frames_per_bin + 1):(j * frames_per_bin)));
            bins_IS_ra(i, j) = mean(IS_ra(i, (j * frames_per_bin - frames_per_bin + 1):(j * frames_per_bin)));

            % SI
            bins_SI_kd(i, j) = mean(SI_kd(i, (j * frames_per_bin - frames_per_bin + 1):(j * frames_per_bin)));
            bins_SI_zs(i, j) = mean(SI_zs(i, (j * frames_per_bin - frames_per_bin + 1):(j * frames_per_bin)));
            bins_SI_ra(i, j) = mean(SI_ra(i, (j * frames_per_bin - frames_per_bin + 1):(j * frames_per_bin)));
        end
    end
    

    %% sort bins
    [sort_bins_IS_kd, sort_bins_SI_kd] = sort_max_time_fxn(bins_IS_kd, bins_SI_kd);
    [sort_bins_IS_zs, sort_bins_SI_zs] = sort_max_time_fxn(bins_IS_zs, bins_SI_zs);
    [sort_bins_IS_ra, sort_bins_SI_ra] = sort_max_time_fxn(bins_IS_ra, bins_SI_ra);

    %% Plot customized number of frames per bin
    
    if true
     figure;

    % title of whole figure
    sgtitle({"Mouse " + mouse, "mouseNum: " + analysis(mouse).mouseNum, "frames_per_bin " + frames_per_bin})

    subplot(3,2,1),imagesc(sort_bins_IS_kd);
    %subplot(3,2,1),imagesc(IS_kd);
    %colormap jet
    title('IS kd sorted');
    caxis([-.1 .1]);


    subplot(3,2,2),imagesc(sort_bins_SI_kd);
    %subplot(3,2,2),imagesc(SI_kd);
    %colormap jet
    title('SI kd sorted');
    caxis([-.1 .1]);


    subplot(3,2,3),imagesc(sort_bins_IS_zs);
    %subplot(3,2,3),imagesc(IS_zs);
    %colormap jet
    title('IS zs sorted');
    caxis([-1 1]);


    subplot(3,2,4),imagesc(sort_bins_SI_zs);
    %subplot(3,2,4),imagesc(SI_zs);
    %colormap jet
    title('SI zs sorted');
    caxis([-1 1]);


    subplot(3,2,5),imagesc(sort_bins_IS_ra);
    %subplot(3,2,5),imagesc(IS_ra);
    %colormap jet
    title('IS ra sorted');
    %caxis([0 0.5]);


    subplot(3,2,6),imagesc(sort_bins_SI_ra);
    %subplot(3,2,6),imagesc(SI_ra);
    %colormap jet
    title('SI ra sorted');
    %caxis([0 0.5]);

    end

    %}
    


    %% put results into result_struct
    m3p3(2).ItoS_cell_sig_f_f0 = IS_kd;
    m3p3(2).StoI_cell_sig_f_f0 = SI_kd;

    
    result_struct(mouse).mouseNum = analysis(mouse).mouseNum;
    
    result_struct(mouse).sort_IS_kd = sort_IS_kd;
    result_struct(mouse).sort_IS_zs = sort_IS_zs;
    result_struct(mouse).sort_IS_ra = sort_IS_ra;
    
    result_struct(mouse).sort_SI_kd = sort_SI_kd;
    result_struct(mouse).sort_SI_zs = sort_SI_zs;
    result_struct(mouse).sort_SI_ra = sort_SI_ra;
    
   
    count = count + 1;
    count;
    analysis(mouse).mouseNum               
        
end
analysis(mouse).mouseNum;
%ItoS_epoch_edge_frames == analysis(11).m3p3_range_ItoS
%StoI_epoch_edge_frames == analysis(11).m3p3_range_StoI



%{
if true
     figure;

    % title of whole figure
    sgtitle({"Mouse " + mouse, "mouseNum: " + analysis(mouse).mouseNum, "frames_per_bin " + frames_per_bin})

    subplot(3,2,1),imagesc(sort_bins_IS_kd);
    %subplot(3,2,1),imagesc(IS_kd);
    %colormap jet
    title('IS kd sorted');
    caxis([-.1 .1]);


    subplot(3,2,2),imagesc(sort_bins_SI_kd);
    %subplot(3,2,2),imagesc(SI_kd);
    %colormap jet
    title('SI kd sorted');
    caxis([-.1 .1]);


    subplot(3,2,3),imagesc(sort_bins_IS_zs);
    %subplot(3,2,3),imagesc(IS_zs);
    %colormap jet
    title('IS zs sorted');
    caxis([-1 1]);


    subplot(3,2,4),imagesc(sort_bins_SI_zs);
    %subplot(3,2,4),imagesc(SI_zs);
    %colormap jet
    title('SI zs sorted');
    caxis([-1 1]);


    subplot(3,2,5),imagesc(sort_bins_IS_ra);
    %subplot(3,2,5),imagesc(IS_ra);
    %colormap jet
    title('IS ra sorted');
    %caxis([0 0.5]);


    subplot(3,2,6),imagesc(sort_bins_SI_ra);
    %subplot(3,2,6),imagesc(SI_ra);
    %colormap jet
    title('SI ra sorted');
    %caxis([0 0.5]);

    end
%}

