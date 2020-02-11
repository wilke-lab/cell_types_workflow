
# cell_types_workflow
--------

This code is based on celltypes_workflow_v3.mat which was written by Kyle Fang and Scott Wilke in January 2020. The difference is that this code has been modified to run a similar analysis, but to look at how activity changes across struggling vs. immobility (rather than during transitions between these two types of behavior). Basically, because struggling and immobility vary in length, we need a way to define points of comparison at the beginning, middle and end of each epoch. This code takes epochs that are already longer than 180 frames at minimum and subdivides them into 60 frame chunks taken from the beginning, middle and end of the epoch. Then it will take those three separate chunks and plot activity as per the original workflow.
