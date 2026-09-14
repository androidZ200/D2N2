classdef ComplexType < DataType
    properties (Access = protected, Constant)
        ssau = [linspace_l(40,  32, 40), linspace_l( 32,  255, 40), linspace_l(255, 201, 40), linspace_l(201, 40, 40);...
                linspace_l(40, 146, 40), linspace_l(146,  255, 40), linspace_l(255,  88, 40), linspace_l( 88, 40, 40);...
                linspace_l(40, 201, 40), linspace_l(201,  255, 40), linspace_l(255,  32, 40), linspace_l( 32, 40, 40)]'/255;
    end
    properties (SetAccess=private)
        data;
    end

    methods
        function create(obj, size)
            obj.data = GPUTest(ones(size));
        end
        function field = get_transmission_function(obj)
            field = obj.data;
        end
        function set_data(obj, inp_data)
            if isequal(size(obj.data), size(inp_data)) || isempty(obj.data)
                obj.data = inp_data;
            else
                error("the sizes of the arrays do not match");
            end
        end
        function sz = size(obj, N)
            if nargin > 1
                sz = obj.get_size(obj.data, N);
            else
                sz = obj.get_size(obj.data);
            end
        end
        function gradient = get_gradient(~, error, ~)
            gradient = conj(error);
        end
        function make_gradient_step(obj, step)
            obj.data = obj.data + step;
        end
        function im = imagesc(obj, X, Y)
            im(1) = subplot(1,2,1); imagesc(X, Y, angle(obj.data), [-pi pi]); colormap(im(1), obj.ssau);
            im(2) = subplot(1,2,2); imagesc(X, Y, abs(obj.data)); colormap(im(2), gray);
        end
    end
end

