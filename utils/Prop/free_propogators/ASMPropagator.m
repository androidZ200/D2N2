classdef ASMPropagator < FFTLikePropagator
    methods
        function get_U(obj)
            ky = 0; kx = 0;
            if ~isempty(obj.mesh.Y)
                Ny = length(obj.mesh.Y); pixely = (obj.mesh.Y(end) - obj.mesh.Y(1))/(Ny-1);
                ky = linspace_l(-pi/pixely, pi/pixely, Ny);
            end
            if ~isempty(obj.mesh.X)
                Nx = length(obj.mesh.X); pixelx = (obj.mesh.X(end) - obj.mesh.X(1))/(Nx-1);
                kx = linspace_l(-pi/pixelx, pi/pixelx, Nx).';
            end

            T = fftshift(kx.^2 + ky.^2);
            obj.U = exp(1i*obj.distance.*single(sqrt((2*pi/obj.wavelength).^2 - T)));
        end
    end
end