function branch_name = get_curr_branch(git_status)

% Find out which branch the version is currently on
on_branch_str = 'On branch ';
on_branch_idx = strfind(git_status,on_branch_str);
branch_start_idx = on_branch_idx + length(on_branch_str);
branch_end_idx_tmp = find(git_status((on_branch_idx + length(on_branch_str)):end) == sprintf('\n'));
branch_end_idx = branch_start_idx + branch_end_idx_tmp(1) - 2;
branch_name = git_status(branch_start_idx:branch_end_idx);
 
end
