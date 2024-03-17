%% Plotting from .mat
fileName = input("Enter a file name to save to (in .mat)");
folder = uigetdir();
x2 = [];
y2 = [];
f_width2 = [];

for i = 1:length(listOfFileNames)
impath = fullfile(folder, listOfFileNames{i});
info = imfinfo(impath);
numberOfPages = length(info);
datacat = imread(impath, 2);
howMuchBlur = 15; 
r_datacat = imrotate(datacat, angles(i), "crop");
[rows, columns] = size(r_datacat);

figure;
imshow(r_datacat)
xr = zeros(rows,1) + divplane(i);
yr = linspace(0,rows,rows);
p = [xr(1) yr(1); xr(end) yr(end)];
dplane = drawline("Position", p);
h = drawfreehand('Color','cyan', 'LineWidth', 10, 'Position', coords{i});
pos = h.Position;

xr1 = zeros(rows,1) + (dplane.Position(1) + dplane.Position(2)) / 2;
yr1 = linspace(0,rows,rows);
[xi, yi] = polyxpoly(xr1, yr1, pos(:, 1), pos(:,2));
width = max(yi) - min(yi);

blurrier = ones(howMuchBlur) / howMuchBlur ^ 2;
blurredImage = imfilter(datacat, blurrier); 
[cx,cy,c] = improfile(blurredImage,pos(:,1),pos(:,2));
c(isnan(c))=0;
divx = (dplane.Position(1) + dplane.Position(2)) / 2; % Manually sets division plane
cx = cx - divx; % Centers the division plane at x = 0
cx = cx - min(cx);
range = max(cx) - min(cx); 
cx = 2 .* (cx ./ range) - 1; % Normalizes to a range of [-1, 1]

% avg = mean(c);
% stdev = std(c);
% c = (c - avg) ./ stdev; % Converts to fold change

[Xmin,Imin] = min(cx);
[Xmax,Imax] = max(cx);
I1 = Imin:Imax;
I2 = [Imax:numel(cx),1:Imin];
[X1,J1] = unique(cx(I1));
[X2,J2] = unique(cx(I2));
N = 654;
Xnew = linspace(Xmin,Xmax,N);
Ynew = mean([...
    interp1(X1,c(I1(J1)),Xnew);...
    interp1(X2,c(I2(J2)),Xnew)],1);

Xnew = transpose(Xnew);
Ynew = transpose(Ynew);

x2 = [x2 Xnew];
y2 = [y2 Ynew];
f_width2 = [f_width2 width];
end

x = x2;
y = y2;
f_width = f_width2;
save(fileName, "listOfFileNames", "coords", "divplane", "x", "y", "f_width", "angles");
close all;
