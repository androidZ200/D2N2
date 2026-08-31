classdef Inaccr_shift < Inaccuracy
    properties
        max_shifts;
        current_shift;
        fixed_shift;
    end
    
    methods
        function obj = Inaccr_shift(max_shift)
            obj.max_shifts = max_shift;
        end
        
        function new_function = apply_child(obj, transmission_function)
            if isempty(obj.current_shift)
                if isempty(obj.fixed_shift)
                    obj.current_shift = randi(obj.max_shifts*2+1,[1 2])-obj.max_shifts-1;
                else
                    obj.current_shift = obj.fixed_shift;
                end
            end
            new_function = circshift(transmission_function, obj.current_shift);
        end
        function new_gradient = get_gradient_child(obj, gradient)
            new_gradient = circshift(gradient, -obj.current_shift);
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
end

