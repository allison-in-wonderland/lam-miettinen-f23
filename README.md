# Data Analysis Pipeline for Cell Membrane Intensity Analysis
The functions provided here can be used to manually select a cell membrane, identify pixel intensities along the selected membrane, define the division plane of the cell, and plot membrane intensity as a function of distance to the division plane.

The first file to use is find_files.m, in the format of a function call to find_files(file_format). This function generally allows you to define a directory for use by later scripts and functions.

Next, use membrane_intensity.m. Running membrane_intensity.m will prompt you for a directory of images as well as a filename to save to. Once a directory is selected, membrane_intensity.m will loop through all images in two stages. The first allows you to define a division plane and will rotate the image such that the division plane is vertical. The second allows you to manually change the location of the division plane if it is not where you intended it to be, and will also allow you to manually outline the cell membrane. Once both stages have been completed for all images in the folder, a .mat file containing a list of filenames corresponding to the processed images; the positional data (x, y coordinates) of the membrane; the location of the division plane; the distance of each position to the division plane; the intensity data of the membrane; the width of the cell at the division plane; and the angle of image rotation. Data can be reanalyzed from the positional data and angle of image rotation without having to manually redefine regions of interest for each image. Plotting subsections included in this file correspond to the figures included in our paper.

removeBackgroundNoise.m takes in a directory of .mat files output from membrane_intensity.m and subtracts dark noise from the intensity data for each image saved in the .mat file. To calculate the dark noise, users can define a representatively dark region in the the first image of the directory. Pixel intensities in the defined region are then averaged and subtracted as the dark noise. This function assumes that the dark noise present in the images does not exhibit a spatial bias nor vary significantly between images.

membrane_intensities_aligned.m takes a directory of .mat files output from membrane_intensity.m and aligns them relative to a given frame with user-defined offsets. We aligned our images to the start of anaphase and defined our offsets as the number of images prior to or after the start of anaphase: for instance, a time-lapse movie with 4 metaphase images would have an offset of -4, and a time-lapse movie that started 3 minutes after the start of anaphase (images were taken 1.5 minutes apart) would have had an offset of 2. After the dataset has been aligned, membrane_intensities_aligned.m calculates and plots the average intensity as a function of distance within each timepoint in a manner similar to membrane_intensities.m.

export.m takes a directory of .mat files output from membrane_intensity.m and exports the frame number, the intensity at the division plane, the intensity at the poles of the cells, the width of the cell at the division plane (furrow width), and the calculated % ingression based off the starting cell width to an excel spreadsheet. This spreadsheet can then be used as the input to furrow_poles_aligned.m, which aligns the data similarly to membrane_intensities.m and then plots the average pixel intensity at the furrow and pole, respectively, as a function of either the frame number or the percent ingression. 
