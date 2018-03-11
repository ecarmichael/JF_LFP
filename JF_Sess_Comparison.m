%% Quick power & coherence sandbox
% this sandbox script compares any conditions for a single subject
% specified in the cfg strcuture.  This makes use of the "JF_LFP_check"
% function for each session and then plots the experimental phases against
% each other.



%% preamble with paths and codebase
global PARAMS  % sets up the 'PARMS' structure that is a global variable which can be called in any nested function by putting "global PARAMS" at the begining of the function

PARAMS.code_base_dir = '/Users/jericcarmichael/Documents/GitHub/vandermeerlab/code-matlab/shared'; % path to van der meer lab codebase
PARAMS.project_code = '/Users/jericcarmichael/Documents/GitHub/JF_LFP';
PARAMS.data_dir = '/Users/jericcarmichael/Documents/day1'; % path to the "day" folder for the rat.  In this sample I used MS12 on cue-gabazine day 1
% mkdir([PARAMS.data_dir, '/LFP_figures'])
PARAMS.fig_dir = [PARAMS.data_dir, '/LFP_figures']; %place to put figures for now.

PARAMS.Chan_to_use = {'CSC1.ncs', 'CSC2.ncs', 'CSC3.ncs'};

% add the codebases
addpath(genpath(PARAMS.code_base_dir));
addpath(genpath(PARAMS.project_code));

cd(PARAMS.data_dir)
%% setup the configuration parameters

cfg_in.Chan_to_use = {'CSC1.ncs', 'CSC2.ncs', 'CSC3.ncs','CSC5.ncs'}; % example


%%  Run across sessions within a recording day

% get the session names
dir_files = dir(); % get all the sessions for the current subject
dir_files(1:2) = [];
sess_list = [];
for iDir = 1:length(dir_files)
    if ~dir_files(iDir).isdir == 1 %strcmp(dir_files(iDir), '.DS_Store') % mac walkaround for the system DS_Store file.
        continue
    end
    if  sum(strfind(dir_files(iDir).name, '-')) ~=0
        dir_files(iDir).name = strrep(dir_files(iDir).name, '-', '_');
    end
    sess_list{iDir} = dir_files(iDir).name;  % extract only the folders for the seesions
end
sess_list = sess_list(~cellfun('isempty',sess_list));
fprintf(['\n' num2str(length(sess_list)) ' sessions found within data directory\n'])
disp(sess_list)
%% take the list of sessions and extract the PSD and Coherence for the specified channels.  Channels should be held consistent across sessions
for iSess = 1:length(sess_list)
    
    if  sum(strfind(sess_list{iSess}, '_')) ~=0
        temp_sess = strrep(sess_list{iSess}, '_', '-');
    else
        temp_sess = sess_list{iSess};
    end
    
    if isunix     % unix directory calls are different from windows.  this checks for that and swaps the '/' for a '\'.
        cd([PARAMS.data_dir '/' temp_sess]);
    else
        cd([PARAMS.data_dir '\' temp_sess]);
    end
    
    dir_list = dir();
    dir_list(1:2) = [];
    if length(dir_list) >2; error('too many folders'); end % the session folder should only contain a data folder from NLX and a .txt
    
    for iDir = 1:length(dir_list)
        if ~dir_list(iDir).isdir == 1 %strcmp(dir_files(iDir), '.DS_Store') % mac walkaround for the system DS_Store file.
            sess_id = strrep(dir_list(iDir).name(1:end-4), '-', '_'); % create an identifier based on the text file name in the session folder.
        else
            cd(dir_list(iDir).name)
        end
    end
    cfg_in.id = sess_id;
    
    if strfind(sess_list{iSess}, '1')
        temp_sess = strrep(sess_list{iSess}, '1', 'one');
    else
        temp_sess = sess_list{iSess};
    end
    
    [PSD.(temp_sess), COH.(temp_sess)]  = Quick_psd(cfg_in);
    close all
    cd(PARAMS.data_dir ) % come back up the data folder
end

dir_names = strsplit(cfg_in.id, '_');
cfg_in.id = [dir_names{1} ' ' dir_names{2} ' ' dir_names{3}]; 

%% compare across sessions
% power
chan = fieldnames(PSD.(sess_list{1}));
c_ord = linspecer(length(sess_list));
for iC = 1%:length(chan)
    % subplot(2,l,iC)
    hold on
    for iSess = 1:length(sess_list)
        if strcmp(sess_list{iSess}, 'post_injection')
            plot(PSD.(sess_list{iSess}).(chan{iC}).f, 10*log10(PSD.(sess_list{iSess}).(chan{iC}).pxx), 'color', [0 0 0], 'linewidth', 2)
        else
            plot(PSD.(sess_list{iSess}).(chan{iC}).f, 10*log10(PSD.(sess_list{iSess}).(chan{iC}).pxx), 'color', c_ord(iSess,:), 'linewidth', 2)
        end
    end
    xlim([0 120])
    legend(strrep(sess_list, '_', ' '))
    xlabel('Frequency (Hz)')
    ylabel('Power (db)')
    title(cfg_in.id)
end
SetFigure([], gcf)
%% same thing for coherence
for iC = 1:length(chan)
    subplot(2,length(chan),iC)
    hold on
    for iSess = 1:length(sess_list)
        plot(COH.(sess_list{iSess}).(chan{iC}).f, COH.(sess_list{iSess}).(chan{iC}), 'color', c_ord(iSess,:))
    end
    xlim([0 120])
    legend(sess_list)
    xlabel('Frequency (Hz)')
    xlabel('Power (db)')
    title(chan{iC})
end





