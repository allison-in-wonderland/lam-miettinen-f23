%% Image Processing
[listOfFolderNames, listOfFileNames, ~] = find_files(".tif");
prompt = "Please enter a filename to save to (in .mat): ";
fileName = input(prompt,"s");
%%
for i = 1:length(listOfFolderNames)
addpath(listOfFolderNames{i})
end
x = [];
y = [];
coords = {};
divplane = [];
f_width = [];
angles = [];

for i = 1:length(listOfFileNames)
data1 = imread(listOfFileNames{i}, 1); 
%data2 = imread(listOfFileNames{i}, 2);
% datacat = imfuse(data1, data2);

info = imfinfo(listOfFileNames{i});
numberOfPages = length(info);
datacat = data1;
% for k = 2 : numberOfPages
%     thisPage = imread(listOfFileNames{i}, k);
%     datacat = imfuse(datacat, thisPage);
% end	
howMuchBlur = 15; 

imshow(datacat);
lim = xlim();
divline = drawline("Color", "blue");
ep = divline.Position;
x1 = ep(1,1); y1 = ep(1,2); x2 = ep(2,1); y2 = ep(2,2);
b2r = atan2d((y2-y1),(x2-x1));
angle = b2r-90;

r_datacat = imrotate(datacat, angle, "crop");
r_data1 = imrotate(data1, angle, "crop");
[rows, columns] = size(r_datacat);


figure;
imshow(r_datacat);
xr = zeros(rows,1) + (divline.Position(1) + divline.Position(2)) / 2;
yr = linspace(0,rows,rows);
p = [xr(1) yr(1); xr(end) yr(end)];
dplane = drawline("Position", p);
h = drawfreehand('Color','cyan', 'LineWidth', 10);
pos = h.Position;
set(gcf,'WindowKeyPressFcn', @(~,~) set(gcf,'UserData', true));
waitfor(gcf,'UserData')

xr1 = zeros(rows,1) + (dplane.Position(1) + dplane.Position(2)) / 2;
yr1 = linspace(0,rows,rows);

[xi, yi] = polyxpoly(xr1, yr1, pos(:, 1), pos(:,2));
width = max(yi) - min(yi);


blurrier = ones(howMuchBlur) / howMuchBlur ^ 2;
blurredImage = imfilter(r_data1, blurrier); 
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

coords = [coords pos];
x = [x Xnew];
y = [y Ynew];
divplane = [divplane divx];
f_width = [f_width width];
angles = [angles angle];
end
save(fileName, "listOfFileNames", "coords", "divplane", "x", "y", "f_width", "angles");
close all;


%% Plotting Membrane Intensity by Cell
listOfAnalyses = ["03-02-2024_L1210_H2B-GFP_RedAmine_Filipin-III_Protein.mat" "03-02-2024_L1210_H2B-GFP_RedAmine_Filipin-III_Cholesterol.mat"];
colors = {[0.9290 0.6940 0.1250], [0.6350 0.0780 0.1840]};
names = {"Protein", "Cholesterol"};
figure();
avgline = [];

for i = 1:length(listOfAnalyses)
load(listOfAnalyses{i})

% Conversion to Z-Score -----------------------------
    avg = mean(y);
    s = std(y);
    y = (y - avg) ./ s; % Converts to Z-score
% ---------------------------------------------------

xavg = mean(x, 2);
yavg = mean(y, 2);
stdev = std(y, 0, 2);
maxstd = yavg + stdev;
minstd = yavg - stdev;

% color1 = [colors{i} 1]; % Changes the transparency for plotted raw data
% plot(x, y, '-', 'Color', color1);
% hold on;
% 
color2 = [colors{i} 0.8];
plot(xavg, yavg, "-", "Color", color2, 'LineWidth', 2);
hold on;
coord_up = [xavg,maxstd];
coord_low = [xavg,minstd];
coord_combine = [coord_up;flipud(coord_low)];
fill(coord_combine(:,1),coord_combine(:,2), colors{i}, "FaceAlpha", 0.2, "EdgeColor", "none")
end

% Plot-related things that don't vary by experiment
xlim([-1 1]);
ylim([-2 4]);
title("Membrane Intensity by Location");
xlabel("Distance from Division Plane");
ylabel("Normalized Membrane Intensity (Z-Score)");

L = [];
for i = 1:length(colors)
dummy = plot(nan, nan, 'color', colors{i});
L = [L dummy];
end
legend(L, names);

%% Plotting intensity at division plane vs. ingression
listOfAnalyses = ["06-20-2022_L1210_H2B-GFP_Amine_timelapse-1min30sec_08_3.mat"];

for i = 1:length(listOfAnalyses)
load(listOfAnalyses{i})
ingression = 1 - f_width ./ f_width(1);
y0 = [];
for i = 1:size(x, 2)
    y_p=interp1(x(:, i),y(:,i),0,'linear','extrap');
    y0 = [y0 y_p];
end
subplot(1, 2, 1)
scatter(ingression, y0)
xlim([0 1])
xlabel("% Ingression")
ylabel("Membrane Intensity at Division Plane")
subplot(1, 2, 2)
scatter(linspace(1, length(y0), length(y0)), y0);
xlabel("Frame #")
ylabel("Membrane Intensity at Division Plane")
end
sgtitle('06-20-2022_L1210_H2B-GFP_Amine_timelapse-1min30sec_08_2.mat', 'Interpreter', 'none');
