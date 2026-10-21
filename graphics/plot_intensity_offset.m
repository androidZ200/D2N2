function plot_intensity_offset(intensity_offset)
    max_offsets = (size(intensity_offset, 1)-1)/2;
    figure;
    grad = 100;
    imagesc(-max_offsets:max_offsets, -max_offsets:max_offsets, intensity_offset);
    colormap([linspace(1, 201/255, grad)', linspace(1, 88/255, grad)', linspace(1, 32/255, grad)']);
    for ii = 1:max_offsets*2+1
        for jj = 1:max_offsets*2+1
            color = [0 0 0];
            text(ii-max_offsets-1, jj-max_offsets-1, sprintf('%.1f', intensity_offset(jj, ii)), ...
                'fontsize', 14, 'color', color, 'HorizontalAlignment', 'center');
        end
    end
end