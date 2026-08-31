classdef Inaccr_smooth_rectangle < Inaccr_smooth
    methods
        function obj = Inaccr_smooth_rectangle(size, phase_only)
            obj = obj@Inaccr_smooth(phase_only);
            obj.kernel = GPUTest(ones(size));
            obj.kernel = kernel/sum(kernel,"all");
        end
    end
end

