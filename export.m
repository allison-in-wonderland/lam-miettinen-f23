function export(xls_name)
    [~, filenames, ~] = find_files(".mat");

    for i = 1:length(filenames)
        load(filenames{i})
        avg = mean(y);
        s = std(y);
        y = (y - avg) ./ s; % Converts to Z-score

        % Moving average filter:
        windowWidth = 11; % Whatever you want.
        kernel = ones(windowWidth,1) / windowWidth;
        y = filter(kernel, 1, y);
        
        %ingression = 1 - f_width ./ f_width(1); % Calculating %ingression based on original cell diameter
        idx = x>-0.1 & x<0.1;
        v = nonzeros(y .* idx);
        v = reshape(v, [], size(x,2));
        y0 = max(v); 
        yp = [];
        
        % Getting intensities at pole, furrow
        for j = 1:size(x, 2)
            yp_p=(interp1(x(:, j),y(:,j),1,'linear','extrap') + interp1(x(:, i),y(:,i),-1,'linear','extrap')) / 2; % avg of poles
            yp = [yp yp_p];
        end
    
        %yp(yp < 0) = 0; % Setting negative intensities equal to 0
        %time = transpose(linspace(1, length(ingression), length(ingression)));
        dataout = [y0.', yp.'];
        varnames = {'Furrow Intensity','Pole Intensity'};
        T = array2table(dataout);
        T.Properties.VariableNames(1:2) = varnames;
        sheetname = erase(filenames{i}, [".mat"]);
        writetable(T,xls_name,'Sheet',sheetname);
    end
end
