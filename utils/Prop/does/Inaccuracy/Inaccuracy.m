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
    end
    methods (Abstract)
        new_function = apply(transmission_function);
        new_gradient = get_gradient(gradient);
        clear();
    end
end

