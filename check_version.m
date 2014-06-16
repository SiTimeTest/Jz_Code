%function check_version(runinfo)
% 
 runinfo.operator = 'JinzeYu';  
 runinfo.comments = 'test automated script, add more stuff';


disp(' ')
disp('************************************************************************************')
disp(' ')
disp(['                      Version check started on: ',datestr(now)])
disp(' ')
disp('************************************************************************************')
disp(' ')


local_backup_path = 'C:\Users\jinzey\Documents\Saunder''s Code Version Control\';

% parse git status message
git_status = git('status');

% Find out which branch the version is currently on
current_branch = get_curr_branch(git_status);

if (strcmp(current_branch,runinfo.operator))
    fprintf('The current branch is the operator''s branch!\n\n');
else
    % switch to the operator's branch
    fprintf('Checking out to branch ''%s'' ... \n',runinfo.operator);
    result_checkout_b = git(['checkout -b ',runinfo.operator]);
    if strcmp(result_checkout_b(1:5),'fatal')
    %     fprintf('Branch already exists\n\n');
        result_checkout = git(['checkout ',runinfo.operator]);

        if (strcmp(result_checkout(1:5),'error'))
            fprintf('Local changes exists, need to back up first\n\n');
            % back up the modified files into a local backup folder, then
            % 'stash', then switch to the operator's branch, then copy the
            % files back, and delete them in the backup path
            local_filenames = parse_git_checkout_w_error(result_checkout);
            filepath = cell(size(local_filenames));
            file_N = length(local_filenames);
            for i = 1:file_N
                local_filename_i = local_filenames{i};
                if find(local_filename_i == '/')
                    slash_idx = find(local_filename_i == '/')
                elseif find(local_filename_i == '\')
                    slash_idx = find(local_filename_i == '\')
                else
                    slash_idx = ''
                end
                if ~isempty(slash_idx)
                    local_filename_i = local_filename_i(slash_idx(end)+1:end);
                end 
                fprintf('backing up file ''%s'' ... ',local_filename_i);
                filepath{i} = which(local_filename_i);
                backuppath{i} = sprintf('%s%s',local_backup_path,local_filename_i);
                copyfile(filepath{i},backuppath{i});
                fprintf('done!\n');
            end
            fprintf('stash the local changes ... ');
            git('stash');
            fprintf('done!\n');
            fprintf('check out to branch ''%s'' ... ', runinfo.operator);
            result_checkout = git(['checkout ',runinfo.operator]);
            fprintf('done!\n');
            fprintf('restore these files from local backup ... \n');

            for i = 1:file_N
                fprintf('restoring file ''%s'' ... ',local_filenames{i});
                movefile(sprintf('%s%s',local_backup_path,local_filenames{i}),filepath{i});
                fprintf('done!\n\n');
            end

            fprintf('restorage is done!\n');

        end

    else
    %     fprintf('On branch %s\n\n',runinfo.operator);
    end
    git_status_branch = git('status');
    current_branch = get_curr_branch(git_status_branch);
    if (strcmp(current_branch,runinfo.operator))
        fprintf('checking out to branch %s is done!\n\n',runinfo.operator);
    else
        fprintf('This case is impossible!!!!!!!!!!!!!\n\n');
    end
end

% check if files are modified and not up to date
% parse git status message
git_status = git('status');
[need_to_update, need_to_track] = check_file_system_status(git_status);

if (need_to_update)

    fprintf('NEED_TO_UPDATE!\nThe current branch needs to update\n\n');

    [modified_filenames,deleted_filenames] = parse_git_status_tracked(git_status);
    
    if (isempty(modified_filenames))
        fprintf('Modified files are all to be committed\n\n');
    else
        fprintf('Some files are modified and needed to be added before commit\n\n');
        modified_N = length(modified_filenames);
        % Add files
        for i = 1:modified_N
            fprintf('adding file ''%s'' ... ',modified_filenames{i});
            result = git(sprintf('add "%s"',modified_filenames{i}));
            fprintf('done!\n\n');
        end
    end

    % Remove deleted files
    if (isempty(deleted_filenames))
        fprintf('Deleted files are all to be committed\n\n');
    else
        fprintf('Some files are deleted and needed to be removed before commit\n\n');
        deleted_N = length(deleted_filenames);
        % Add files
        for i = 1:deleted_N
            fprintf('removing file ''%s'' ... ',deleted_filenames{i});
            result = git(sprintf('rm "%s"',deleted_filenames{i}));
            fprintf('done!\n\n');
        end
    end
    
end

if (need_to_track)
    
    % Up to now, files that are modified, are all added, and need to commit
    % Next step will be check if the 'Untracked files' are necessary to add
    fprintf('NEED_TO_TRACK!\nThe current branch has some untracked files, checking them now ... \n\n')
    untracked_filenames = parse_git_status_untracked(git_status);
    
    if (isempty(untracked_filenames))
        fprintf('No untracked files, ready to commit\n\n');
    else
        fprintf('Untracked files exist\n\n');
        untracked_N = length(untracked_filenames);

        for i = 1:untracked_N
            tmp_untracked_filename = untracked_filenames{i};
            file_format = tmp_untracked_filename((find(tmp_untracked_filename == '.')+1):end);
            % Select the files with right format to add.
            if (isempty(file_format))
                if strcmp(tmp_untracked_filename(end),'/') % this is a folder
                    result = git(sprintf('add "%s*"',tmp_untracked_filename));
                end
            elseif (strcmp(file_format,'m'))
                fprintf('adding file ''%s'' ... ',untracked_filenames{i});
                result = git(sprintf('add "%s"',untracked_filenames{i}));
                fprintf('done!\n\n');
            else
                fprintf('File format ''.%s'' is not needed to be tracked\n\n',file_format);
            end
        end
    end 
end

git_status = git('status');

nothing_to_commit = 'nothing to commit';
to_be_committed = 'Changes to be committed:';

nothing_to_commit_idx = strfind(git_status,nothing_to_commit);
to_be_committed_idx = strfind(git_status,to_be_committed);
if (isempty(nothing_to_commit_idx) && ~isempty(to_be_committed_idx))
    need_to_commit = 1;
else
    need_to_commit = 0;
end

if (need_to_commit)
    commit_msg = sprintf('''%s'' by Operator %s on date: %s',runinfo.comments,runinfo.operator,datestr(now,'yymmddHHMMSS'));
    fprintf('The commit message is "%s"\n\ncommitting now ... ',commit_msg);
    result = git(sprintf('commit -m "%s"\n\n',commit_msg));
    fprintf('done!\n');
    
end





disp(' ')
disp('************************************************************************************')
disp(' ')
disp(['                      Version check ended on: ',datestr(now)])
disp(' ')
disp('************************************************************************************')
disp(' ')

% parse the result message into three parts:
% 1. M - filename
% 2. Untracked files - filename
% 3. others