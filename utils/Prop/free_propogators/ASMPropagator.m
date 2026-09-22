classdef ASMPropagator < FFTLikePropagator
    methods
        function get_U(obj)
            k = 2*pi/obj.wavelength;
            ky = 0; kx = 0;
            z_max = inf;
            
            if ~isempty(obj.mesh.Y)
                Ny = length(obj.mesh.Y); pixely = (obj.mesh.Y(end) - obj.mesh.Y(1))/(Ny-1);
                ky = GPUTest(linspace_l(-pi/pixely, pi/pixely, Ny));

                maky = max(abs(ky./sqrt(k.^2 - ky.^2)));
                z_max = min(z_max, Ny*pixely/2/maky);
            end
            if ~isempty(obj.mesh.X)
                Nx = length(obj.mesh.X); pixelx = (obj.mesh.X(end) - obj.mesh.X(1))/(Nx-1);
                kx = GPUTest(linspace_l(-pi/pixelx, pi/pixelx, Nx).');
                
                makx = max(abs(kx./sqrt(k.^2 - kx.^2)));
                z_max = min(z_max, Nx*pixelx/2/makx);
            end

            if obj.distance > z_max; warning(['These ASM conditions may yield incorrect results.' ...
                    ' You should set the distance to be less than or equal to ' num2str(z_max) ' m.']); end

            T = fftshift(kx.^2 + ky.^2);
            obj.U = exp(1i*obj.distance.*sqrt(k.^2 - T));
        end
    end
end