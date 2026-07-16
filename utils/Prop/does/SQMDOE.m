classdef SQMDOE < DOE
    properties (SetAccess=private)
        data;
        mask;
        optimizer;
        out_mesh;
    end
    properties (Access=private)
        TX;
        TY;
        ix;
        iy;
    end
    
    methods
        function obj = SQMDOE(prev, Mesh, out_mesh, wavelength, distance, optimizer_fabric)
            obj = obj@DOE(prev, Mesh, PhaseDOE());
            obj.out_mesh = out_mesh;
            obj.data = GPUTest(zeros([1, 1, size(out_mesh)]));
            k = 2*pi/wavelength;
            obj.TX = -k/2/distance*(Mesh.X - permute(out_mesh.X, [3 4 1 2])).^2;
            obj.TY = -k/2/distance*(Mesh.Y - permute(out_mesh.Y, [3 4 1 2])).^2;
            if nargin < 4
                obj.optimizer = [];
                obj.mask = 0;
            else
                obj.optimizer = optimizer_fabric.generate(obj.data);
                obj.mask = 1;
            end
        end
        
        function obj = set_data(obj, data)
            if ~isequal(size(data), size(obj.data))
                error("the sizes of the arrays do not match");
            end
            obj.data = data;
        end

        function obj = set_mask(obj, mask)
            if isequal(size(mask), size(obj.mesh)) || size(mask) == 1
                obj.mask = GPUTest(mask);
            else
                error("the sizes of the arrays do not match");
            end
        end

        function gradient = get_gradient(obj, error)
            gradient = error.*obj.mask;
            gradient = sum(gradient.*(obj.iy == permute(1:size(obj.out_mesh.Y,2), [1 4 3 2])), 2);
            gradient = permute(gradient, [1 2 5 4 3]);
            gradient = sum(gradient.*(obj.ix == permute(1:size(obj.out_mesh.X,1), [1 3 2 4])), 1);
            gradient = obj.type.get_gradient(gradient, obj.data);
            gradient = squeeze(gradient);
        end

        function is = is_trainable(obj)
            is = sum(obj.mask, "all") > 0;
        end

        function field = get_transmission_function(obj)
            field = obj.type.get_transmission_function(obj.get_surface());
        end

        function field = get_surface(obj)
            [field, obj.ix] = max(obj.data + obj.TX, [], 3);
            [field, obj.iy] = max(field + obj.TY,    [], 4);
        end

        function make_gradient_step(obj, gradient, speed)
            if obj.is_trainable()
                gradient = permute(gradient, [3 4 1 2]);
                obj.data = obj.data - speed * obj.optimizer.optimize(gradient);
            end
        end

        function imag = imagesc(obj)
            im = obj.type.imagesc(obj.mesh.X, obj.mesh.Y, angle(obj.get_transmission_function()));
            colorbar;
            axis square;
            if nargout > 0
                imag = im;
            end
        end
    end
end