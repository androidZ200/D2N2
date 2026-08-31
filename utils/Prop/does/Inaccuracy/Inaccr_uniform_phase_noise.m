classdef Inaccr_uniform_phase_noise < Inaccr_noise
    properties (SetAccess=private)
        max_noise;
    end
    
    methods
        function obj = Inaccr_uniform_phase_noise(max_noise)
            obj.max_noise = max_noise;
        end
    end

    methods(Access=protected)
        function noise = get_noise(obj, sz)
            noise = exp(1i*rand(sz)*obj.max_noise);
        end
    end
end

