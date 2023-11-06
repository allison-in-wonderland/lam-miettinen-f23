offsets = [-2 2 3 -2 3 4 3 2 0 2 3 1 2 1 2 1];
[~, filenames, ~] = find_files(".mat");

aligned_x = zeros(654, length(filenames), 28);
aligned_y = zeros(654, length(filenames), 28);

    for i = 1:length(filenames)
        load(filenames{i})
        y_avg = mean(y, "omitmissing");
        y_stdev = std(y, "omitmissing");
        y = (y - y_avg) ./ y_stdev; 

        %Inserting NaNs to align datasets
        num_inserts_front = 4 - offsets(i);
        inserts_f = NaN(size(x, 1), num_inserts_front);
        x = [inserts_f x];
        y = [inserts_f y];
 
        num_inserts_back = 28 - size(x, 2);
        inserts_b = NaN(size(x, 1), num_inserts_back);
        x = [x inserts_b];
        y = [y inserts_b];
        for j = 1:28
            aligned_x(:, i, j) = x(:, j);
            aligned_y(:, i, j) = y(:, j);
        end
    end

mean_aligned_x = [];
mean_aligned_y = [];

for k = 1:28
xp = mean(aligned_x(:, :, k), 2, "omitmissing");
yp = mean(aligned_y(:, :, k), 2, "omitmissing");
mean_aligned_x = [mean_aligned_x xp];
mean_aligned_y = [mean_aligned_y yp];
end

%%
plot(mean_aligned_x, mean_aligned_y)
title("All Timelapse Membrane Intensities (aligned, averaged)")
xlabel("Distance from division plane")
ylabel("Z-Score")

%%
% x_subset = [mean_aligned_x(:, 3), mean_aligned_x(:, 9), mean_aligned_x(:, 15), mean_aligned_x(:, 21)];
%y_subset = [mean_aligned_y(:, 3), mean_aligned_y(:, 9), mean_aligned_y(:, 15), mean_aligned_y(:, 21)];
x_subset = mean_aligned_x(:, 4:11);
y_subset = mean_aligned_y(:, 4:11);

xavg = mean(x_subset, 2);
yavg = mean(y_subset, 2);
stdev = std(y_subset, 0, 2);
maxstd = yavg + stdev;
minstd = yavg - stdev;

plot(x_subset, y_subset, '-');

% hold on;
% coord_up = [xavg,maxstd];
% coord_low = [xavg,minstd];
% coord_combine = [coord_up;flipud(coord_low)];
% fill(coord_combine(:,1),coord_combine(:,2), 'r', "FaceAlpha", 0.2, "EdgeColor", "none")

legend("t = -1.5 minutes", "t = 0 minutes", "t = 1.5 minutes", ...
    "t = 3 minutes", "t = 4.5 minutes", "t = 6 minutes", "t = 7.5 minutes", "t = 9 minutes");
title("Timelapse Membrane Intensity")
xlabel("Distance from division plane")
ylabel("Z-Score")