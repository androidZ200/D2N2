function GetTraining(Error, Train, TrainLabel, parameters)
% gradient learning method
    mustBeA(Error, "ErrorFunction");
    
    if nargin < 4; parameters = []; end
    if ~isfield(parameters, 'epoch'); parameters.epoch = 1; end
    if ~isfield(parameters, 'speed'); parameters.speed = 1; end
    if ~isfield(parameters, 'slowdown'); parameters.slowdown = 1; end
    if ~isfield(parameters, 'batch'); parameters.batch = 1; end
    if ~isfield(parameters, 'max_batch'); parameters.max_batch = parameters.batch; end
    
    parameters.batch = min(parameters.batch, size(Train,3));
    parameters.max_batch = min(parameters.batch, parameters.max_batch);
    
    tt1 = tic;
    loss = []; accr = [];
    accrline = [];
    speed = parameters.speed;
    ndisp();
    
    randind = [];
    for iter8=1:parameters.epoch
        randind = [randind randperm(size(Train,3), size(Train,3))];
    end
    
    for iter7=1:parameters.batch:length(randind)   
        for iter9=0:parameters.max_batch:(parameters.batch-1)
            index = randind(iter7+iter9+(0:min(parameters.max_batch-1, length(randind)-iter7-iter9)));
            num = reshape(TrainLabel(index),1,[]);
            
            % direct propagation
            err = Error.get_error(Train(:,:,index), num);
            Error.back_propagation();
            if isempty(loss)
                loss = mean(err);
            else
                loss = loss*0.99 + 0.01*mean(err);
            end
            if isfield(parameters, 'predictor') && isa(parameters.predictor, "Predictor")
                pred = parameters.predictor.get_prediction();
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
            rdisp([first_line '\n' waitbartext(50, progres)]);
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
