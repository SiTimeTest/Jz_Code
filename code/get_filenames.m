function file_names = get_filenames(message, start_idx)
git_status = message;
filename_start_idx = start_idx;
filename_end_idx = zeros(size(filename_start_idx));

% Get the filenames, check the format, then add them
local_filenames = cell(size(filename_start_idx));
local_N = length(filename_start_idx);

for i = 1:local_N
    % parse the filename strings
    if i == local_N
        tmp_str = git_status(filename_start_idx(i):end);
    else
        tmp_str = git_status(filename_start_idx(i):filename_start_idx(i+1));
    end

    tmp_filename_end_idx = find(tmp_str == sprintf('\n'));
    filename_end_idx(i) = tmp_filename_end_idx(1) - 1;
    local_filenames{i} = tmp_str(1:filename_end_idx(i));

end

file_names = local_filenames;
 
end