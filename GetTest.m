function [error_table, accuracy, intensity_table, min_contrast, Scores] = GetTest(decoder, Test, TestLabel, batch)
    mustBeA(decoder, "Decoder");
    
    count_class = length(unique(TestLabel));
    Scores = GPUTest(zeros(decoder.count_outputs(), size(Test,3)));
    decoder.clear();
    if nargin < 4; batch = 1; end
    batch = min(size(Test,3), batch);
    
    
    ttcr = tic();
    ndisp(['check result\n' waitbartext(60, -1) ' 0%']);
    for iter3=1:size(Test,3)/batch
        % running through the system
        Scores(:,(iter3-1)*batch+1:iter3*batch) = ...
            decoder.get_output(Test(:,:,(iter3-1)*batch+1:iter3*batch));
        decoder.clear();
        
        rdisp(['check result\n' waitbartext(50, iter3/size(Test,3)*batch) ...
                ' ' num2str(iter3*batch/size(Test,3)*100,'%.2f') '%']);
    end
    rdisp(['check result takes time: ' num2str(toc(ttcr)) 's']);


    % error table
    [~, argmax] = max(Scores);
    error_table = GPUTest(zeros(decoder.count_outputs(), count_class, size(Test,3)));
    error_table(argmax + decoder.count_outputs()*(reshape(TestLabel,1,[])-1) + ...
        decoder.count_outputs()*count_class*(0:(size(Test,3)-1))) = 1;
    error_table = sum(error_table,3);
    % intensity table
    onehot = reshape(TestLabel,1,[]) == (1:count_class)';
    intensity_table = (Scores./sum(Scores)) * onehot';


    % accuracy info
    accuracy = sum(diag(error_table))/sum(sum(error_table))*100;
    intensity_table = intensity_table./sum(intensity_table)*100;
    ndisp(['accuracy = ' num2str(accuracy) '%;']);
    % min contrast info
    T = sort(intensity_table);
    min_contrast = min((T(end,:) - T(end-1,:))./(T(end,:) + T(end-1,:))*100);
    ndisp(['min contrast = ' num2str(min_contrast) '%;']);
end