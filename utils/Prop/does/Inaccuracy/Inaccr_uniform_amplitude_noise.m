classdef Inaccr_uniform_amplitude_noise < Inaccr_noise
    properties (SetAccess=private)
        max_noise;
    end
    
    methods
        function obj = Inaccr_uniform_amplitude_noise(max_noise)
            obj.max_noise = max_noise;
        end
    end

    methods(Access=protected)
        function noise = get_noise(obj, sz)
            noise = 1 - rand(sz)*obj.max_noise;
        end
    end
end

