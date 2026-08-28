classdef CylindricalDOE < DOE & MatrixPropagator
    properties (SetAccess=private)
        data;
        mask;
        optimizer;
        type;
    end

    methods
        function obj = CylindricalDOE(prev, Mesh, type, dim, optimizer_fabric)
            obj = obj@DOE(prev, Mesh);
            mustBeA(type, "TypeDOE");
            obj.type = type;
            switch dim
                case "X"
                    obj.type.create(size(Mesh.X));
                case "Y"
                    obj.type.create(size(Mesh.Y));
                otherwise
                    error("dimension not exist");
            end
            if nargin < 5
                obj.optimizer = [];
                obj.mask = 0;
            else
                obj.optimizer = optimizer_fabric.generate(obj.data);
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

        function gradient = get_gradient(obj, error, tf)
            gradient = obj.type.get_gradient(error, tf);
            gradient = mean(gradient, find(size(obj.type)==1));
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

        function M = get_left(obj)
            if size(obj.type,1) == 1
                M = eye(obj.size(1));
            else
                M = diag(obj.type.get_transmission_function());
            end
        end
        function M = get_right(obj)
            if size(obj.type,1) == 1
                M = diag(obj.type.get_transmission_function());
            else
                M = eye(obj.size(2));
            end
        end

        function imag = imagesc(obj)
            if size(obj.type,1) == 1
                im = obj.type.imagesc(0, obj.mesh.Y);
            else
                im = obj.type.imagesc(obj.mesh.X, 0);
            end
            if nargout > 0
                imag = im;
            end
        end
    end
end

