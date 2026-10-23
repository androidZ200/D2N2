function min_contrast = plot_intensity_table(intensity_table, Labels)
    % output of a beautiful intensity table
    grad = 100;
    figure;
    imagesc(intensity_table);
    xlabel('input class'); ylabel('recognized class');
    xticks(1:size(intensity_table,2)); yticks(1:size(intensity_table,1));
    xticklabels(Labels); yticklabels(Labels);
    colormap([linspace(1, 201/255, grad)', linspace(1, 88/255, grad)', linspace(1, 32/255, grad)']);
    for ii = 1:size(intensity_table,2)
        for jj = 1:size(intensity_table,1)
            color = [0 0 0];
            text(ii, jj, replace(sprintf('%.1f', intensity_table(jj, ii)), '.', ','), 'fontsize', 14, ...
                'color', color, 'HorizontalAlignment', 'center');
        end
    end
    T = sort(intensity_table);
    min_contrast = min((T(end,:) - T(end-1,:))./(T(end,:) + T(end-1,:))*100);
    title(['min contrast = ' replace(num2str(min_contrast), '.', ',') '%;']);
end