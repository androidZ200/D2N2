classdef FullDOE < DOE
    properties (SetAccess=private)
        mask;
        optimizer;
        type;
    end

    methods
        function obj = FullDOE(prev, Mesh, type, optimizer_fabric)
            obj = obj@DOE(prev, Mesh);
            mustBeA(type, "TypeDOE");
            obj.type = type;
            obj.type.create(size(Mesh));
            if nargin < 4
                obj.optimizer = [];
                obj.mask = 0;
            else
                obj.optimizer = optimizer_fabric.generate(Mesh);
                obj.mask = 1;
            end
        end

        function obj = set_data(obj, data)
            obj.type.set_data(data);
        end

        function obj = set_mask(obj, mask)
            if isequal(size(mask), size(obj.mesh)) || size(mask) == 1
                obj.mask = GPUTest(mask);
            else
                error("the sizes of the arrays do not match");
            end
        end

        function gradient = get_gradient(obj, error, ~)
            gradient = obj.type.get_gradient(error);
        end

        function is = is_trainable(obj)
            is = sum(obj.mask, "all") > 0;
        end

        function field = get_transmission_function(obj)
            field = obj.type.get_transmission_function();
        end

        function make_gradient_step(obj, gradient, speed)
            if obj.is_trainable()
                obj.type.make_gradient_step(-speed*obj.optimizer.optimize(gradient).*obj.mask)
            end
        end

        function imag = imagesc(obj)
            im = obj.type.imagesc(obj.mesh.X, obj.mesh.Y);
            if nargout > 0
                imag = im;
            end
        end
    end
end