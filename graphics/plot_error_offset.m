function plot_error_offset(error_offset)
    max_offsets = (size(error_offset, 1)-1)/2;
    figure;
    grad = 100;
    imagesc(-max_offsets:max_offsets, -max_offsets:max_offsets, error_offset);
    colormap([linspace(1, 32/255, grad)', linspace(1, 145/255, grad)', linspace(1, 201/255, grad)']);
    for ii = 1:max_offsets*2+1
        for jj = 1:max_offsets*2+1
            color = [0 0 0];
            text(ii-max_offsets-1, jj-max_offsets-1, sprintf('%.1f', error_offset(jj, ii)), ...
                'fontsize', 14, 'color', color, 'HorizontalAlignment', 'center');
        end
    end
end