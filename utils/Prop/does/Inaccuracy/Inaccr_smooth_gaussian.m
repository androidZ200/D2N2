classdef Inaccr_smooth_gaussian < Inaccr_smooth
    methods
        function obj = Inaccr_smooth_gaussian(size, deviation, phase_only)
            obj = obj@Inaccr_smooth(phase_only);
            obj.kernel = GPUTest(fspecial('gaussian', size, deviation));
        end
    end
end

