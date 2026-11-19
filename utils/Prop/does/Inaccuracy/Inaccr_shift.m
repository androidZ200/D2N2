classdef Inaccr_shift < Inaccuracy
    properties
        max_shifts;
        current_shift;
        fixed_shift;
    end
    
    methods
        function obj = Inaccr_shift(max_shift)
            if isscalar(max_shift); max_shift = repelem(max_shift, 1, 2); end
            obj.max_shifts = max_shift;
        end
        
        function clear(obj)
            obj.current_shift = [];
        end

        function set_fixed_shift(obj, shift)
            obj.fixed_shift = shift;
        end
        function clear_fixed_shift(obj)
            obj.fixed_shift = [];
        end
    end

    methods (Access=protected)
        function new_function = apply_child(obj, transmission_function)
            if isempty(obj.current_shift)
                if isempty(obj.fixed_shift)
                    obj.current_shift(1) = randi(obj.max_shifts(1)*2+1)-obj.max_shifts(1)-1;
                    obj.current_shift(2) = randi(obj.max_shifts(2)*2+1)-obj.max_shifts(2)-1;
                else
                    obj.current_shift = obj.fixed_shift;
                end
            end
            new_function = circshift(transmission_function, obj.current_shift);
        end
        function new_gradient = get_gradient_child(obj, gradient)
            new_gradient = circshift(gradient, -obj.current_shift);
        end
    end
end

