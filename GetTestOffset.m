function [error_offset, intensity_offset] = GetTestOffset(decoder, Test, TestLabel, max_offsets, test_doe, batch)
    % check result with offsets one DOE
    mustBeA(test_doe, "Inaccr_shift");
    mustBeA(decoder, "Decoder");
    if nargin < 6; batch = 1; end
    
    error_offset = zeros(max_offsets*2+1);
    intensity_offset = zeros(max_offsets*2+1);
    
    test_doe.enable();
    for iter1 = -max_offsets:max_offsets
        for iter2 = -max_offsets:max_offsets
            ndisp(['offsets = (' num2str(iter2) ', ' num2str(iter1) ');']);
            test_doe.set_fixed_shift([iter1, iter2]);
            [~, acc, ~, minc] = GetTest(decoder, Test, TestLabel, batch);
            error_offset(iter1+max_offsets+1,iter2+max_offsets+1) = acc;
            intensity_offset(iter1+max_offsets+1,iter2+max_offsets+1) = minc;
        end
    end
    test_doe.clear_fixed_shift();
end