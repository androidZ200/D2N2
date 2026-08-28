classdef (Abstract) TypeDOE < handle
    methods (Abstract)
        create(size);
        field = get_transmission_function();
        set_data(inp_data);
        size(N);
        gradient = get_gradient(error, tf);
        make_gradient_step(step);
        imagesc(X, Y);
    end
    methods (Access=protected, Static)
        function sz = get_size(data, N)
            if nargin < 2
                sz = size(data);
            else
                sz = size(data, N);
            end
        end
    end
end

