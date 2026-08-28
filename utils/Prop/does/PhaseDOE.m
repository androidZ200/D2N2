classdef PhaseDOE < TypeDOE
    properties (Access = protected, Constant)
        ssau = [linspace_l(40,  32, 40), linspace_l( 32,  255, 40), linspace_l(255, 201, 40), linspace_l(201, 40, 40);...
                linspace_l(40, 146, 40), linspace_l(146,  255, 40), linspace_l(255,  88, 40), linspace_l( 88, 40, 40);...
                linspace_l(40, 201, 40), linspace_l(201,  255, 40), linspace_l(255,  32, 40), linspace_l( 32, 40, 40)]'/255;
    end
    properties (SetAccess=private)
        phi;
    end

    methods
        function create(obj, size)
            obj.phi = GPUTest(zeros(size));
        end
        function field = get_transmission_function(obj)
            field = exp(1i*obj.phi);
        end
        function set_data(obj, inp_data)
            if isequal(size(obj.phi), size(inp_data)) || isempty(obj.phi)
                obj.phi = real(inp_data);
            else
                error("the sizes of the arrays do not match");
            end
        end
        function sz = size(obj, N)
            if nargin > 1
                sz = obj.get_size(obj.phi, N);
            else
                sz = obj.get_size(obj.phi);
            end
        end
        function gradient = get_gradient(~, error, tf)
            gradient = real(1i*error.*tf);
        end
        function make_gradient_step(obj, step)
            obj.phi = obj.phi + step;
        end
        
        function im = imagesc(obj, X, Y)
            im = imagesc(Y, X, angle(obj.get_transmission_function()), [-pi pi]);
            colormap(obj.ssau);
        end
    end
end