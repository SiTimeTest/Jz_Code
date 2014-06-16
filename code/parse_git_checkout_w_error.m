function file_names = parse_git_checkout_w_error(message)

result_checkout = message;
by_checkout = 'by checkout:';
please_commit = 'Please, commit';
by_checkout_idx = strfind(result_checkout,by_checkout);
please_commit_idx = strfind(result_checkout,please_commit);
tab_idx = find(result_checkout==sprintf('\t')); % to locate where are the tabs
tab_for_local_change_idx = find(tab_idx > by_checkout_idx & tab_idx < please_commit_idx);

filename_start_idx = tab_idx(tab_for_local_change_idx)+1;
file_names = get_filenames(result_checkout,filename_start_idx);
 
end
