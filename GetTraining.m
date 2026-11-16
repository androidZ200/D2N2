function GetTraining(Error, Train, TrainLabel, parameters, predictor)
% gradient learning method
    mustBeA(Error, "ErrorFunction");
    find_optimal_mb = false;

    if nargin < 4; parameters = []; end
    if ~isfield(parameters, 'epoch'); parameters.epoch = 1; end
    if ~isfield(parameters, 'speed'); parameters.speed = 1; end
    if ~isfield(parameters, 'slowdown'); parameters.slowdown = 1; end
    if ~isfield(parameters, 'batch'); parameters.batch = 1; end
    if ~isfield(parameters, 'max_batch'); parameters.max_batch = 1; find_optimal_mb = true; end
    
    parameters.batch = min(parameters.batch, size(Train,3));
    parameters.max_batch = min(parameters.batch, parameters.max_batch);
    
    tt1 = tic;
    loss = []; accr = [];
    accrline = [];
    end_line = [];
    speed = parameters.speed;
    ndisp();

    if find_optimal_mb
        mb_div = 1:parameters.batch;
        mb_div = mb_div(find(rem(parameters.batch, mb_div) == 0));
        count_avg_mb = 20;
        table_mb = inf(length(mb_div), count_avg_mb);
        iter_mb_div = 1;
        iter_mb_avg = 1;
    end
    
    randind = [];
    for iter8=1:parameters.epoch
        randind = [randind randperm(size(Train,3), size(Train,3))];
    end
    
    for iter7=1:parameters.batch:length(randind)
        tt2 = tic;
        for iter9=0:parameters.max_batch:(parameters.batch-1)
            end_index = min([iter7+iter9+parameters.max_batch-1; iter7+parameters.batch-1; length(randind)]);
            index = randind((iter7+iter9):end_index);
            num = reshape(TrainLabel(index),1,[]);
            
            % direct propagation
            err = Error.get_error(Train(:,:,index), num);
            Error.back_propagation();
            if isempty(loss)
                loss = mean(err);
            else
                loss = loss*0.99 + 0.01*mean(err);
            end
            if nargin > 4 && isa(predictor, "Predictor")
                pred = predictor.get_prediction();
                if isempty(accr)
                    accr = mean(pred == num);
                else
                    accr = accr*0.99 + 0.01*mean(pred == num);
                end
                accrline = ['; accr = ' num2str(accr*100,'%.2f') '%'];
            end
                
            % display info
            progres = (iter7+iter9+parameters.max_batch-1) / length(randind);
            first_line = ['[' num2str(progres*100,'%05.2f') '%]; loss = ' num2str(loss,'%.5e') ...
                accrline '; time = ' num2str(toc(tt1)) ';'];
            rdisp([first_line '\n' waitbartext(50, progres) ...
                '\n' end_line]);
        end
        mb_speed = (end_index-iter7+1)/toc(tt2);
        end_line = ['mb = ' num2str(parameters.max_batch) '; ' num2str(mb_speed, '%.0f') ' images per second'];

        % find optimal max batch
        if find_optimal_mb
            table_mb(iter_mb_div, iter_mb_avg) = mb_speed;
            iter_mb_avg = iter_mb_avg + 1;
            if iter_mb_avg > count_avg_mb
                iter_mb_div = iter_mb_div + 1;
                iter_mb_avg = 1;
            end
            if iter_mb_div > length(mb_div)
                [~, min_ind_mb] = max(sum(table_mb,2));
                parameters.max_batch = mb_div(min_ind_mb);
                find_optimal_mb = false;
            else
                parameters.max_batch = mb_div(iter_mb_div);
            end
        end
    
        % updating weights
        Error.minimize(speed);
        speed = speed*parameters.slowdown;
    
        % data output to the console
        if isfield(parameters, 'cycle') && mod(iter7+parameters.batch-1, parameters.cycle) == 0
            rdisp(first_line);
            ndisp();
        end
    end
end
