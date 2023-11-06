[~,sheet_name]=xlsfinfo('intensity_data_smoothed_aligned.xls')
for k=1:numel(sheet_name)
  data{k}=xlsread('intensity_data_smoothed_aligned.xls',sheet_name{k})
end

%%
furrows = [];
poles = [];
ingressions = [];
for h = 1:size(data, 2)
    df = data{h};
    ingressions = [ingressions df(:, 5)];
end

offsets = [2 3 3 4 3 2 0 2 3 1 2 1 2 1];
[~, filenames, ~] = find_files(".mat");

aligned_x = zeros(654, length(filenames), 24);
aligned_y = zeros(654, length(filenames), 24);

    for i = 1:length(filenames)
        load(filenames{i})
        % y_avg = mean(y, "omitmissing");
        % y_stdev = std(y, "omitmissing");
        % y = (y - y_avg) ./ y_stdev; 
        %Inserting NaNs to align datasets
        num_inserts_front = 4 - offsets(i);
        inserts_f = NaN(size(x, 1), num_inserts_front);
        x = [inserts_f x];
        y = [inserts_f y];
        f_width = [NaN(1, num_inserts_front) f_width];
        
        y = y ./ mean(y(:, 2:5), 2, "omitmissing");

        num_inserts_back = 24 - size(x, 2);
        inserts_b = NaN(size(x, 1), num_inserts_back);
        x = [x inserts_b];
        y = [y inserts_b];
        f_width = [NaN(1, num_inserts_back) f_width];

        for j = 1:24
            aligned_x(:, i, j) = x(:, j);
            aligned_y(:, i, j) = y(:, j);
            aligned_f_width(:, i, j) = f_width(:, j);
        end
    end

mean_aligned_x = [];
mean_aligned_y = [];
mean_aligned_f = [];
stdev = [];

for k = 1:24
xp = mean(aligned_x(:, :, k), 2, "omitmissing");
yp = mean(aligned_y(:, :, k), 2, "omitmissing");
fp = mean(aligned_f_width(:, :, k), 2, "omitmissing");
stdevp = std(aligned_y(:, :, k), 0, 2, "omitnan");

mean_aligned_x = [mean_aligned_x xp];
mean_aligned_y = [mean_aligned_y yp];
mean_aligned_f = [mean_aligned_f fp];
stdev = [stdev stdevp];
end

stdev0 = [];
ingression = 1 - mean_aligned_f ./ mean_aligned_f(1);
idx = mean_aligned_x>-0.1 & mean_aligned_x<0.1 ;
[y0, idxy0] = max(mean_aligned_y .* idx); 
for l = 1:length(idxy0)
stdev0 = [stdev0 stdev(idxy0(l), l)];
end

idy1 = mean_aligned_x<-0.9;
idy2 = mean_aligned_x>0.9;
a = mean_aligned_y .* idy1;
b = a(any(a,2),:);
c = mean_aligned_y .* idy2;
d = c(any(c,2),:);
yp1 = sum(mean_aligned_y .* idy1, 1) ./ sum(mean_aligned_y .* idy1 ~=0,1);
stdev1 = std(b, 0, 1);
yp2 = sum(mean_aligned_y .* idy2, 1) ./ sum(mean_aligned_y .* idy2 ~=0,1); 
stdev2 = std(d, 0, 1);
yp = (yp1 + yp2) / 2;
stdp = (stdev1 + stdev2) / 2;

avg_ingressions = transpose(mean(ingressions, 2, "omitmissing"));


maxstd = y0 + stdev0;
minstd = y0 - stdev0;
color = [0.9290 0.6940 0.1250 0.8];

figure();
plot(linspace(-4, 20, 24), y0, "-", "Color", color, 'LineWidth', 2);
hold on;
coord_up = [transpose(linspace(-4, 20, 24)), transpose(maxstd)];
coord_low = [transpose(linspace(-4, 20, 24)), transpose(minstd)];
coord_combine = [coord_up;flipud(coord_low)];
plot(coord_combine(:,1),coord_combine(:,2))
xlabel("Frame #")
ylabel("Normalized Pixel Intensity")
xlim([-3 16]);
xticks(-3:3:16);
title("Furrow Intensity by Time (aligned, averaged)")

maxstdp = yp + stdp;
minstdp = yp - stdp;

figure();
plot(linspace(-4, 20, 24), yp);
hold on;
coord_up_p = [transpose(linspace(-4, 20, 24)), transpose(maxstdp)];
coord_low_p = [transpose(linspace(-4, 20, 24)), transpose(minstdp)];
coord_combine_p = [coord_up_p;flipud(coord_low_p)];
plot(coord_combine_p(:,1),coord_combine_p(:,2))
xlabel("Frame #")
ylabel("Normalized Pixel Intensity")
xlim([-3 16]);
xticks(-3:3:16);
title("Pole Intensity by Time (aligned, averaged)")


