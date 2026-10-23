function PrintResult(decoder, Size, delay, Test, TestLabel, Labels)
    mustBeA(decoder, 'GetMaskOutput');
    MASK = decoder.Mask;
    
    % colormap in shades of Samara university
    ssau = [linspace_l(1,  32/255, 50), linspace( 32/255, 0, 100); ...
		    linspace_l(1, 145/255, 50), linspace(145/255, 0, 100); ...
		    linspace_l(1, 201/255, 50), linspace(201/255, 0, 100)]';
    % to draw squares
    G_size_x = max(sum(MASK(:,:,1),2),[],1)*(decoder.Mesh.Y(2) - decoder.Mesh.Y(1));
    G_size_y = max(sum(MASK(:,:,1),1),[],2)*(decoder.Mesh.X(2) - decoder.Mesh.X(1));
    xx = [-1 -1 1 1 -1]*G_size_x/2;
    yy = [1 -1 -1 1 1]*G_size_y/2;
    
    coords(:,1) = squeeze(sum(MASK.*decoder.Mesh.Y,[1 2])./sum(MASK,[1 2]));
    coords(:,2) = squeeze(sum(MASK.*decoder.Mesh.X,[1 2])./sum(MASK,[1 2]));
    
    % getting results
    index = randi(size(Test,3),Size,1);
    W = Test(:,:,index);
    decoder.clear();
    F = decoder.intensity(W);
    score = decoder.get_output(W);
    score = score./sum(score);
    set(0,'units','pixels');
    Pix_SS = get(0,'screensize'); Size_SS = [1500 400];
    fig = figure('position', [(Pix_SS([3 4]) - Size_SS)/2, Size_SS]);
    for iter10=1:Size
        % drawing images
	    ax = subplot(1, 3, 1);
	    imagesc(abs(W(:,:,iter10))); colormap(ax, gray);
        set(gca,'xtick',[],'ytick',[]);
        axis square;
	    ax = subplot(1, 3, 2);
	    imagesc(decoder.Mesh.Y, decoder.Mesh.X, F(:,:,iter10)); colormap(ax, ssau);
        set(gca,'xtick',[],'ytick',[]);
        axis square;
        hold on;
    
        % drawing numbers and squares of focus areas
        for nt=1:size(MASK,4)
            if nt == TestLabel(index(iter10))
                plot(xx+coords(nt,1), yy+coords(nt,2), 'color', [201 88 32]/255);
            else
                plot(xx+coords(nt,1), yy+coords(nt,2), 'color', [0 0 0]);
            end
        end
        
        % drawing bar of scores
        subplot(1, 3, 3);
        bar(score(:,iter10)*100,'FaceColor',[32 145 201]/255,'EdgeAlpha',0);
        xticklabels(Labels);
        ylim([0 max(score,[],"all")*110]);
        
	    pause(delay);
        if ~ishandle(fig); return; end
    %         saveas(gca, ['im_' num2str((p-1)*ln+num) '.png']);
    end
    close(fig);
end