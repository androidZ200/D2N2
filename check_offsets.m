% check result with offsets one DOE

if ~exist('max_offsets', 'var'); error('max_offsets is not exist'); end
if ~exist('test_doe', 'var') || ~isa(test_doe, 'Inaccr_shift'); error('test_doe is not exist'); end

off_err_table = zeros(max_offsets*2+1);
off_int_table = zeros(max_offsets*2+1);

test_doe.enable();
for iter1 = -max_offsets:max_offsets
    for iter2 = -max_offsets:max_offsets
        ndisp(['offsets = (' num2str(iter2) ', ' num2str(iter1) ');']);
        test_doe.set_fixed_shift([iter1, iter2]);
        % max_batch = 20;
        check_result;
        off_err_table(iter1+max_offsets+1,iter2+max_offsets+1) = accuracy;
        off_int_table(iter1+max_offsets+1,iter2+max_offsets+1) = min_contrast;
    end
end
test_doe.clear_fixed_shift();

clearvars max_offsets test_doe iter1 iter2;
return;

%% error offsets

max_offsets = (size(off_err_table, 1)-1)/2;
figure;
grad = 100;
imagesc(-max_offsets:max_offsets, -max_offsets:max_offsets, off_err_table);
colormap([linspace(1, 32/255, grad)', linspace(1, 145/255, grad)', linspace(1, 201/255, grad)']);
for ii = 1:max_offsets*2+1
    for jj = 1:max_offsets*2+1
        color = [0 0 0];
        text(ii-max_offsets-1, jj-max_offsets-1, ...
            sprintf('%.1f', off_err_table(jj, ii)), 'fontsize', 14, ...
            'color', color, 'HorizontalAlignment', 'center');
    end
end
clearvars ii jj color max_offsets grad;

%% intensity offsets

max_offsets = (size(off_err_table, 1)-1)/2;
figure;
grad = 100;
imagesc(-max_offsets:max_offsets, -max_offsets:max_offsets, off_int_table);
colormap([linspace(1, 201/255, grad)', linspace(1, 88/255, grad)', linspace(1, 32/255, grad)']);
for ii = 1:max_offsets*2+1
    for jj = 1:max_offsets*2+1
        color = [0 0 0];
        text(ii-max_offsets-1, jj-max_offsets-1, ...
            sprintf('%.1f', off_int_table(jj, ii)), 'fontsize', 14, ...
            'color', color, 'HorizontalAlignment', 'center');
    end
end
clearvars ii jj color max_offsets grad;
