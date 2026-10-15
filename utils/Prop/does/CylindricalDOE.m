classdef CylindricalDOE < DOE & MatrixPropagator
    properties (SetAccess=private)
        mask;
        optimizer;
        type;
    end

    methods
        function obj = CylindricalDOE(prev, Mesh, type, dim, optimizer_fabric)
            obj = obj@DOE(prev, Mesh);
            mustBeA(type, "DataType");
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
                obj.optimizer = optimizer_fabric.generate(obj.type);
                obj.mask = 1;
            end
        end

        function obj = set_data(obj, data)
            mustBeA(data, "DataType");
            if ~isequal(size(data), size(obj.type))
                error("CylindricalDOE: The data dimensionality must correspond to the mesh");
            end
            obj.type = data;
        end
        function obj = set_tf(obj, data)
            if ~isequal(size(data), size(obj.type))
                error("CylindricalDOE: The data dimensionality must correspond to the mesh");
            end
            obj.type.set_transmision_function(data);
        end

        function obj = set_mask(obj, mask)
            if isequal(size(mask), size(obj.mesh)) || size(mask) == 1
                obj.mask = GPUTest(mask);
            else
                error("CylindricalDOE: The sizes of the mask arrays do not match");
            end
        end

        function field = get_transmission_function(obj)
            field = obj.type.get_transmission_function();
        end
        
        function reset(obj)
            if ~isempty(obj.optimizer); obj.optimizer.reset(); end
            obj.type.create(size(obj.type));
        end

        function M = get_left(obj)
            if size(obj.type,1) == 1
                M = GPUTest(eye(obj.size(1)));
            else
                M = diag(obj.type.get_transmission_function());
            end
        end
        function M = get_right(obj)
            if size(obj.type,1) == 1
                M = diag(obj.type.get_transmission_function());
            else
                M = GPUTest(eye(obj.size(2)));
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
    
    methods(Access=protected)
        function gradient = get_gradient(obj, error, tf)
            gradient = obj.type.get_gradient(error, tf);
            gradient = mean(gradient, find(size(obj.type)==1));
        end

        function is = is_trainable(obj)
            is = sum(obj.mask, "all") > 0;
        end

        function make_gradient_step(obj, gradient, speed)
            if obj.is_trainable()
                obj.type.make_gradient_step(-speed*obj.optimizer.optimize(gradient).*obj.mask)
            end
        end
    end
end

