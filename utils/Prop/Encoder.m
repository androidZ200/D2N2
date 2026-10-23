classdef (Abstract) Encoder < Back_Propogator
    methods (Abstract)
        field = get_field(input);
        lambda = get_wavelength();
        mesh = output_mesh();
        set_output_mesh(mesh);
    end
end

