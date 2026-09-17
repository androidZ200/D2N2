classdef (Abstract) MatrixPropagator < Prop
    methods (Abstract)
        get_left();
        get_right();
    end
    methods(Access=protected, Static)
        function out = prop(L, in, R)
            out = pagemtimes(L, pagemtimes(in, R));
        end
    end
end

