function plot_mask(mesh, MASK, Labels)
    M = sum(MASK, 3);
    M = M > 0;
    imagesc(mesh.Y, mesh.X, M);
    colormap(repelem([1; 0.7], 1, 3));
    xlabel('Y'); ylabel('X');
    if nargin > 2
        weight = sum(MASK,[1 2]);
        coord.X = sum(MASK.*mesh.X,[1 2])./weight;
        coord.Y = sum(MASK.*mesh.Y,[1 2])./weight;
        for iter=1:size(MASK,3)
            text(coord.Y(iter), coord.X(iter), Labels{iter}, ...
                'fontsize', 14, 'color', [0 0 0], 'HorizontalAlignment', 'center');
        end
    end
end