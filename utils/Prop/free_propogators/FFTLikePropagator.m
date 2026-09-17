classdef (Abstract) FFTLikePropagator < FreePropagator
    properties(SetAccess=protected)
        U;
        mesh = [];
    end
    methods(Abstract)
        get_U();
    end

    methods
        function obj = FFTLikePropagator(prev, distance, wavelength)
            obj = obj@FreePropagator(prev);
            obj.distance = distance;
            obj.wavelength = wavelength;

            mesh = prev.output_mesh();
            if ~isempty(mesh)
                obj.init(mesh);
            end
        end

        function init(obj, mesh)
            if ~isempty(obj.mesh)
                if ~isequal(obj.mesh, mesh)
                    error('The Meshes dont match');
                end
                return;
            else
                obj.mesh = mesh;
            end
            obj.get_U();
            obj.prev_node.set_output_mesh(mesh);
        end
        function field = get_field(obj, input)
            field = obj.prev_node.get_field(input);
            field = ifft2(fft2(field).*obj.U);
        end
        function set_error_field(obj, error)
            error = ifft2(fft2(error).*obj.U);
            obj.prev_node.set_error_field(error);
        end
        function mesh = input_mesh(obj)
            mesh = obj.mesh;
        end
        function mesh = output_mesh(obj)
            mesh = obj.input_mesh();
        end
    end
end