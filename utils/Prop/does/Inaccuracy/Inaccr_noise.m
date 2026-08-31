classdef (Abstract) Inaccr_noise < Inaccuracy
    properties (Access=protected)
        current_noise;
    end
    
    methods (Access=protected)
        function new_function = apply_child(obj, transmission_function)
            if isempty(obj.current_noise)
                obj.current_noise = obj.get_noise(size(transmission_function));
            end
            new_function = transmission_function.*obj.current_noise;
        end
        function new_gradient = get_gradient_child(~, gradient)
            new_gradient = gradient;
        end
    end
    
    methods
        function clear(obj)
            obj.current_noise = [];
        end
    end

    methods (Abstract, Access=protected)
        noise = get_noise(sz);
    end
end

