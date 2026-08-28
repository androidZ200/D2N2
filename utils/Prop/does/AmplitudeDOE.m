classdef AmplitudeDOE < TypeDOE
    properties (SetAccess=private)
        theta;
    end

    methods
        function create(obj, size)
            obj.theta = GPUTest(zeros(size));
        end
        function field = get_transmission_function(obj)
            field = obj.sigmoid(obj.theta);
        end
        function set_data(obj, inp_data)
            if isequal(size(obj.theta), size(inp_data)) || isempty(obj.theta)
                obj.theta = -log(1./min(max(real(inp_data), 1e-8), 1 - 1e-8) - 1);
            else
                error("the sizes of the arrays do not match");
            end
        end
        function sz = size(obj, N)
            if nargin > 1
                sz = obj.get_size(obj.theta, N);
            else
                sz = obj.get_size(obj.theta);
            end
        end
        function gradient = get_gradient(obj, error)
            tf = obj.get_transmission_function();
            gradient = real(error.*tf.*(1 - tf));
        end
        function make_gradient_step(obj, step)
            obj.theta = obj.theta + step;
        end
        function im = imagesc(obj, X, Y)
            im = imagesc(X, Y, obj.get_transmission_function(), [0 1]);
            colormap(gray);
        end
    end

    methods (Access = private, Static)
        function y = sigmoid(x)
            y = 1./(1 + exp(-x));
        end
    end
end