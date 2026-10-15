classdef AmplitudeType < DataType
    properties
        theta;
    end

    methods
        function theta = get.theta(obj)
            theta = obj.theta;
        end
        function set.theta(obj, val)
            mustBeReal(val);
            obj.theta = val;
        end

        function create(obj, size)
            obj.theta = GPUTest(zeros(size));
        end
        function field = get_transmission_function(obj)
            field = obj.sigmoid(obj.theta);
        end
        function set_transmision_function(obj, inp_data)
            if max(abs(angle(inp_data)),[],"all") > eps*10
                warning("AmplitudeType: The set value must be purely amplitude-based. The phase will be discarded");
            end
            inp_data = abs(inp_data);
            if max(inp_data,[],"all") > 1
                warning("AmplitudeType: The set value must be no greater than 1. Values greater than 1 will be reduced to 1");
                inp_data = min(inp_data, 1 - 1e-10);
            end
            obj.theta = -log(1./max(inp_data, 1e-10) - 1);
        end
        function sz = size(obj, N)
            if nargin > 1
                sz = obj.get_size(obj.theta, N);
            else
                sz = obj.get_size(obj.theta);
            end
        end
        function gradient = get_gradient(~, error, tf)
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