function [modified_files,deleted_files] = parse_git_status_tracked(message)
 
git_status = message;
% strings for search
modified_str = 'modified:   ';
deleted_str = 'deleted:    ';
for_commit = 'for commit:'; % to add

% find files that are modified and not yet added
add_commit_idx = strfind(git_status,modified_str);
delete_commit_idx = strfind(git_status,deleted_str);
for_commit_idx = strfind(git_status,for_commit);
if (isempty(for_commit_idx))
    modified_files = [];
    deleted_files = [];
else
    tmp_add_idx = find(add_commit_idx > for_commit_idx);
    add_idx = add_commit_idx(tmp_add_idx);
    
    
    tmp_delete_idx = find(delete_commit_idx > for_commit_idx);
    delete_idx = delete_commit_idx(tmp_delete_idx);
    
    % track the filenames
    filename_start_idx = add_idx + length(modified_str);
    delete_filename_start_idx = delete_idx + length(deleted_str);

    % Get the filenames to add them
    modified_files = get_filenames(git_status,filename_start_idx);
    deleted_files = get_filenames(git_status,delete_filename_start_idx);
end
  