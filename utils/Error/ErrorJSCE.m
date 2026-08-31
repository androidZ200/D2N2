classdef ErrorJSCE < ErrorFunction % joint softmax cross entropy
    properties(SetAccess=private)
        Error
        decoder
    end
    
    methods
        function obj = ErrorJSCE(decoder, target, alpha, beta)
            obj.decoder = decoder;
            dc = ScoreSpliter(decoder);
            dc1 = NormalizationMAX(dc);
            err1 = ErrorSCE(dc1, target, alpha);
            err2 = ErrorPEF(dc);
            obj.Error = ErrorSUM(err1, 1-beta).add_new(err2, beta);
        end

        function error = get_error(obj, input, index)
            error = obj.Error.get_error(input, index);
        end
        function minimize(obj, speed, weight)
            if nargin < 3; weight = 1; end
            obj.Error.minimize(speed, weight);
        end

        function need = need_error_field(obj)
            need = obj.Error.need_error_field();
        end
        function set_error_field(obj, error)
            obj.Error.set_error_field(error);
        end
        function gradient_step(obj, speed)
            obj.Error.gradient_step(speed);
        end
        function clear(obj)
            obj.Error.clear();
        end
    end
end

% Joint loss function design in diffractive optical neural network classifiers for high power efficiency
% / F. Mengguang, J. Shuping, G. Yinwei, et al // Optics Express. - 2025. - Vol. 33, Issue 4. 
% - P. 7307-7320. - DOI: https://doi.org/10.1364/OE.547572