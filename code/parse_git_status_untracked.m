function file_names = parse_git_status_untracked(message)

git_status = message;
untracked_files_str = 'Untracked files:'; % to add, or NOT, check if '.m' or not
untracked_to_add = 'include in what will be committed)';
untracked_idx = strfind(git_status,untracked_files_str);
if (isempty(untracked_idx))
    file_names = [];
else
    untracked_to_add_idx = strfind(git_status,untracked_to_add);
    tab_idx = find(git_status==sprintf('\t')); % to locate where are the tabs
    tab_for_untracked_idx = find(tab_idx > untracked_to_add_idx);
    if isempty(tab_for_untracked_idx)
        % this case does not exist
    else
        filename_start_idx = tab_idx(tab_for_untracked_idx)+1;

        % Get the filenames, check the format, then add them
        file_names = get_filenames(git_status,filename_start_idx);
    end
end
 
end