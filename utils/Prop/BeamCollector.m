classdef BeamCollector < Prop
    properties (SetAccess=private)
        prev_nodes;
        weights;
        mesh;
    end
    
    methods
        function obj = BeamCollector(prev, weight)
            obj.add_new(prev, weight);
        end

        function obj = add_new(obj, prev, weight)
            mustBeA(prev, "Encoder");
            obj.prev_nodes{end+1} = prev;
            if nargin > 2 && ~isempty(weight)
                mustBeScalarOrEmpty(weight);
                obj.weights(end+1) = weight;
            else
                obj.weights(end+1) = 1;
            end
            
            mesh = prev.output_mesh();
            if ~isempty(mesh)
                obj.set_output_mesh(mesh);
            elseif ~isempty(obj.mesh)
                prev.set_output_mesh(obj.mesh);
            end
        end
        
        function need = need_error_field(obj)
            need = false;
            for prev = obj.prev_nodes
                need = need || prev{1}.need_error_field();
            end
        end
        function set_error_field(obj, error)
            for iter = 1:length(obj.prev_nodes)
                obj.prev_nodes{iter}.set_error_field(error * obj.weights(iter));
            end
        end
        function gradient_step(obj, speed)
            for prev = obj.prev_nodes
                prev{1}.gradient_step(speed);
            end
        end
        function field = get_field(obj, input)
            field = obj.prev_nodes{1}.get_field(input) * obj.weights(1);
            for iter = 2:length(obj.prev_nodes)
                field = field + obj.prev_nodes{iter}.get_field(input) * obj.weights(iter);
            end
        end
        function mesh = output_mesh(obj)
            mesh = obj.mesh;
        end
        function mesh = input_mesh(obj)
            mesh = obj.mesh;
        end
        function set_output_mesh(obj, mesh)
            mustBeA(mesh, "Mesh");
            if isempty(obj.mesh)
                obj.mesh = mesh;
                for prev = obj.prev_nodes
                    prev{1}.set_output_mesh(mesh);
                end
            elseif ~isequal(obj.mesh, mesh)
                error("The Meshes dont match");
            end
        end
        function clear(obj)
            for prev = obj.prev_nodes
                prev{1}.clear();
            end
        end
    end
end

