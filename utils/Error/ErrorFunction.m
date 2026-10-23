classdef (Abstract) ErrorFunction < Back_Propogator
    methods (Abstract)
        error = get_error(input, index);
        back_propagation(weight);
        minimize(speed);
    end
end

