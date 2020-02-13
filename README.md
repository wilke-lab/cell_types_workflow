
# cell_types_workflow
---
This code is based on celltypes_workflow_v3.mat which was written by Kyle Fang and Scott Wilke in January 2020. The difference is that this code has been modified to run a similar analysis, but to look at how activity changes across struggling vs. immobility (rather than during transitions between these two types of behavior). Basically, because struggling and immobility vary in length, we need a way to define points of comparison at the beginning, middle and end of each epoch. This code takes epochs that are already longer than 180 frames at minimum and subdivides them into 60 frame chunks taken from the beginning, middle and end of the epoch. Then it will take those three separate chunks and plot activity as per the original workflow.

## Code structure
The first part of the code is loading beginning and end frames into the **ItoS_epoch_edge_frames** and **StoI_epoch_edge_frames** variables. The code then takes the calcium imaging levels of those 

constructs 6 data sets: kd, z score, analysis for both Immobile-to-Struggling and Struggling-to-Immobile.


## Notes
You need the **sort_max_time_fxn.m** file open and running in order for this code to work.

The code currently outputs 2 figures.
1. The first figure contains displays the results of 1 frame per bin
2. The second figure displays the results of the specified number of frames per bin.



### How to use
The code will work as long as the **ItoS_epoch_edge_frames** and **StoI_epoch_edge_frames** variables (to be renamed later) are formatted as below:
[start frame 1, end frame 1, start frame 2, end frame 2, etc.]

The only manual components to this code are
1. Loading data into **ItoS_epoch_edge_frames** and **StoI_epoch_edge_frames**
2. Inputting the number many frames per bin in line ~344. 
    * Note, the number of frames per bin **must** be a factor of total number of frames or the code will break.
