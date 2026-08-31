classdef (Abstract) Inaccr_smooth < Inaccuracy
    properties (SetAccess = protected)
        kernel;
        phase_only = false;
    end
    
    methods
        function obj = Inaccr_smooth(phase_only)
            obj.phase_only = phase_only;
        end
        function clear(~)
        end
    end

    methods (Access=protected)
        function new_function = apply_child(obj, transmission_function)
            new_function = conv2(transmission_function, obj.kernel, "same");
            if obj.phase_only
                new_function = exp(1i*angle(new_function));
            end
        end
        function new_gradient = get_gradient_child(obj, gradient)
            new_gradient = conv2(gradient, obj.kernel, "same");
        end
    end
end

