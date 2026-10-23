classdef InputModulator < Encoder
    properties (SetAccess=private)
        Mesh Mesh;
        Func;
        wavelength;
    end

    methods
        function obj = InputModulator(Mesh, wavelength, Func)
            obj.Mesh = Mesh;
            obj.wavelength = wavelength;
            if nargin > 2
                obj.Func = Func;
            else
                obj.Func = @(W)W;
            end
        end
        function set_Func(obj, Func)
            obj.Func = Func;
        end

        function field = get_field(obj, input)
            field = obj.Func(input);
        end
        function lambda = get_wavelength(obj)
            lambda = obj.wavelength;
        end
        function need = need_error_field(~)
            need = false;
        end
        function set_error_field(~, ~)
        end
        function gradient_step(~, ~)
        end
        function mesh = output_mesh(obj)
            mesh = obj.Mesh;
        end
        function set_output_mesh(obj, mesh)
            mustBeA(mesh, "Mesh");
            if ~isequal(obj.Mesh, mesh)
                error('The Meshes dont match');
            end
        end
        function clear(~)
        end
    end
end