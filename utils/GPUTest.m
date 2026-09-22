function Array = GPUTest(Array)
    global is_single;
    if isempty(is_single); is_single = true; end

    if is_single
        Array = single(Array);
    else
        Array = double(Array);
    end

    global is_gpu;
    if isempty(is_gpu); is_gpu = false; end
    
    if is_gpu
        Array = gpuArray(Array);
    else
        Array = gather(Array);
    end
end

