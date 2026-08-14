classdef IdenticalDOE < TypeDOE
    properties (Access = protected, Constant)
        ssau = [linspace_l(40,  32, 40), linspace_l( 32,  255, 40), linspace_l(255, 201, 40), linspace_l(201, 40, 40);...
                linspace_l(40, 146, 40), linspace_l(146,  255, 40), linspace_l(255,  88, 40), linspace_l( 88, 40, 40);...
                linspace_l(40, 201, 40), linspace_l(201,  255, 40), linspace_l(255,  32, 40), linspace_l( 32, 40, 40)]'/255;
    end

    methods
        function field = get_transmission_function(~, data)
            field = data;
        end
        function gradient = get_gradient(~, error, ~, ~)
            gradient = conj(error);
        end
        function data = get_data_from(~, inp_data)
            data = inp_data;
        end
        function im = imagesc(obj, X, Y, data)
            subplot(1,2,1); imagesc(X, Y, angle(data), [-pi pi]); colormap(obj.ssau);
            subplot(1,2,2); imagesc(X, Y, abs(data)); colormap(gray);
            im = gca;
        end
    end
end

