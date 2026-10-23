function accuracy = plot_error_table(error_table, Labels)
    % output of a beautiful error table
    grad = 100;
    figure;
    tmp_table = error_table./sum(error_table);
    imagesc(tmp_table);
    xlabel('input class'); ylabel('recognized class');
    xticks(1:size(error_table,1)); yticks(1:size(error_table,2));
    xticklabels(Labels); yticklabels(Labels);
    colormap([linspace(1, 32/255, grad)', linspace(1, 145/255, grad)', linspace(1, 201/255, grad)']);

    for ii = 1:size(error_table,2)
        for jj = 1:size(error_table,1)
            color = [0 0 0];
            if tmp_table(jj, ii) > 0.5; color = [1 1 1]; end
            text(ii, jj, replace(sprintf('%.1f', tmp_table(jj, ii)*100), '.', ','), ...
                'fontsize', 14, 'color', color, 'HorizontalAlignment', 'center');
        end
    end
    accuracy = sum(diag(error_table))/sum(error_table,'all')*100;
    title(['accuracy = ' replace(num2str(accuracy), '.', ',') '%;']);
end