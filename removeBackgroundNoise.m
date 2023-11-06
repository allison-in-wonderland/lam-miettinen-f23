[~, filenames, folder] = find_files(".tif");
cd(folder);
mat_file = dir("*.mat");
load(mat_file.name);
fileName = erase(mat_file.name, ".mat");
fileName = strcat(mat_file.name, "_no_bg.mat");
input = filenames{1};
img = imread(input);
imshow(img);
rect = drawrectangle();
bw = createMask(rect);
m = mean2(img(logical(bw)));
y = y - m;

cd '/Users/allisonlam/Desktop/Work/UROP/Manalis Lab/Membrane Density/data_no_bg';
save(fileName, "listOfFileNames", "coords", "divplane", "x", "y");
close all;
clear all;
cd '/Users/allisonlam/Desktop/Work/UROP/Manalis Lab/Membrane Density';

