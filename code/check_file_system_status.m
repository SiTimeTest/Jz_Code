function [need_to_update, need_to_track] = check_file_system_status(git_status)

diff_result = git('diff');
if isempty(diff_result)
    fprintf('current version is up to date\n\n');
    need_to_update = 0;
else
    fprintf('current version is NOT up to date\n\n');
    need_to_update = 1;
end

untracked_filenames = parse_git_status_untracked(git_status);

if (isempty(untracked_filenames))
    need_to_track = 0;
else
    fprintf('Some untracked files exist, check is needed to track them\n');
    need_to_track = 1;
end

end