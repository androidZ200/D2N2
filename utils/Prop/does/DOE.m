classdef (Abstract) DOE < Prop
    properties (SetAccess=protected)
        mesh Mesh;
        prev_node;
        Errors;
    end
    properties (Access=protected)
        Input_field;
        Gradient;
        TF; % transmission function
    end
    
    methods (Abstract)
        get_transmission_function();
        is_trainable();
        get_gradient(error, trans_func);
        make_gradient_step(gradient, speed);
    end

    methods
        function obj = DOE(prev, Mesh)
            obj.mesh = Mesh;
            mustBeA(prev, "Encoder");
            obj.prev_node = prev;
            obj.prev_node.set_output_mesh(obj.mesh);
        end

        function W = get_field(obj, input)
            field = obj.prev_node.get_field(input);
            if obj.is_trainable(); obj.Input_field = field; end
            if isempty(obj.TF); obj.TF = obj.apply_error(obj.get_transmission_function()); end
            W = field.*obj.TF;
        end

        function need = need_error_field(obj)
            need = obj.is_trainable() || obj.prev_node.need_error_field();
        end

        function set_error_field(obj, Error_field)
            if obj.is_trainable()
                grad = obj.get_gradient(Error_field.*obj.Input_field, obj.TF);
                sumdim = setdiff(find(size(grad) > 1), [1 2]);
                if ~isempty(sumdim); grad = sum(grad,sumdim); end
                if isempty(obj.Gradient)
                    obj.Gradient = grad;
                else
                    obj.Gradient = obj.Gradient + grad;
                end
            end
            if obj.prev_node.need_error_field()
                obj.prev_node.set_error_field(Error_field.*obj.TF);
            end
        end

        function mesh = input_mesh(obj)
            mesh = obj.mesh;
        end

        function mesh = output_mesh(obj)
            mesh = obj.input_mesh();
        end

        function set_output_mesh(obj, mesh)
            mustBeA(mesh, "Mesh");
            if ~isequal(obj.mesh, mesh)
                error('The Meshes dont match');
            end
        end

        function set_inaccuracy(obj, inaccuracy)
            mustBeA(inaccuracy, "Inaccuracy");
            obj.Errors{end+1} = inaccuracy;
        end

        function clear_inaccuracy(obj, index)
            if nargin < 2
                obj.Errors = [];
            elseif index > 0 && index <= length(obj.Errors)
                if index < length(obj.Errors)
                    obj.Errors(index:end-1) = obj.Errors(index+1:end);
                end
                obj.Errors(end) = [];
            end
        end

        function clear(obj)
            obj.Input_field = [];
            obj.Gradient = [];
            obj.TF = [];
            for iter=1:length(obj.Errors); obj.Errors{iter}.clear(); end
            obj.prev_node.clear();
        end
        
        function sz = size(obj, N)
            if nargin > 1
                sz = size(obj.mesh, N);
            else
                sz = size(obj.mesh);
            end
        end

        function gradient_step(obj, speed)
            obj.make_gradient_step(obj.apply_error_grad(obj.Gradient), speed);
            obj.prev_node.gradient_step(speed);
        end
    end

    methods (Access=private)
        function TF = apply_error(obj, TF)
            for iter=1:length(obj.Errors)
                TF = obj.Errors{iter}.apply(TF);
            end
        end

        function grad = apply_error_grad(obj, grad)
            for iter=length(obj.Errors):-1:1
                grad = obj.Errors{iter}.get_gradient(grad);
            end
        end
    end
end