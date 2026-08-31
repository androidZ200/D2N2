classdef (Abstract) Inaccuracy < handle
    properties (SetAccess=protected)
        is_enabled = true;
    end

    methods
        function enable(obj)
            obj.is_enabled = true;
        end
        function disable(obj)
            obj.is_enabled = false;
        end
        function new_function = apply(obj, transmission_function)
            if obj.is_enabled
                new_function = obj.apply_child(transmission_function);
            else
                new_function = transmission_function;
            end
        end
        function new_gradient = get_gradient(obj, gradient)
            if obj.is_enabled
                new_gradient = obj.get_gradient_child(gradient);
            else
                new_gradient = gradient;
            end
        end
    end
    methods (Abstract, Access=protected)
        new_function = apply_child(transmission_function);
        new_gradient = get_gradient_child(gradient);
    end
    methods (Abstract)
        clear();
    end
end

