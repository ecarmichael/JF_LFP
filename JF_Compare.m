function JF_Compare()

%% JF_Compare: compares across sessions ('baseline', 
% 'post_injection', ...) for a single subject.  This makes use of the "Quick_psd"
% function for each session and then plots each session against
% each other.

% clears all variables and closes all windows.  Comment to keep 
% clear all
close all

%% preamble with paths and codebase
global PARAMS  % sets up the 'PARMS' structure that is a global variable which can be called in any nested function by putting "global PARAMS" at the begining of the function

PARAMS.code_base_dir = '/Users/jericcarmichael/Documents/GitHub/vandermeerlab/code-matlab/shared'; % path to van der meer lab codebase
PARAMS.project_code = '/Users/jericcarmichael/Documents/GitHub/JF_LFP';

% add the codebases
addpath(genpath(PARAMS.code_base_dir));
addpath(genpath(PARAMS.project_code));


%% where is the data?.  Put the path to each data session that will be compared here. Can be as many sessions as you like. Just make them match the PARAMS.session_ids.  
PARAMS.data_dir{1} = '/Users/jericcarmichael/Documents/day1/baseline/2013-08-30_14-42-03'; % first session
PARAMS.data_dir{2} = '/Users/jericcarmichael/Documents/day1/1-hour-post-injection/2013-08-30_15-41-29'; % second session
PARAMS.data_dir{3} = '/Users/jericcarmichael/Documents/day1/post-injection/2013-08-30_15-06-40'; % third
% name the sessions
PARAMS.session_ids = {'baseline','one_hour_post_injection', 'post_injection'}; % name the sessions.  Can't start with a number. replace spaces with '_"
PARAMS.id = {[]}; % used for saving the session in the saved images and data files.  
cfg_in.Chan_to_use = {'CSC6.ncs'};%{'CSC1.ncs', 'CSC2.ncs', 'CSC3.ncs'};
% cfg_in.xfreq = 'on';  % uncomment this to have the quick PSD compute the cross-frequency correlation.  Computationally demanding so it slows it down by about 1 min per channel.  

%% cycle through the sessions specified in the PARAMS.
for iSess = 1:length(PARAMS.data_dir)
    cd(PARAMS.data_dir{iSess})
    fprintf(['\nProcessing...' PARAMS.session_ids{iSess} '\n'])
    
    % take the list of sessions and extract the PSD and Coherence for the specified channels.  Channels should be held consistent across sessions
    if length(cfg_in.Chan_to_use)>1 % includes the coherence 
        [PSD.(PARAMS.session_ids{iSess}), COH.(PARAMS.session_ids{iSess})]  = Quick_psd(cfg_in);
    else % only computes the power.  
       	[PSD.(PARAMS.session_ids{iSess})]  = Quick_psd(cfg_in);
    end
    close all
end


%% compare across sessions
% power
chan = fieldnames(PSD.(PARAMS.session_ids{iSess}));
c_ord = linspecer(length(PARAMS.session_ids));
sub_idx = numSubplots(length(chan));
for iC = 1:length(chan)
    if length(chan) >1
            subplot(sub_idx(1),sub_idx(2),iC) % defaults to
    hold on

        for iSess = 1:length(PARAMS.session_ids)
            
            plot(PSD.(PARAMS.session_ids{iSess}).(chan{iC}).f, 10*log10(PSD.(PARAMS.session_ids{iSess}).(chan{iC}).pxx), 'color', c_ord(iSess,:), 'linewidth', 2)
            xlim([0 120])
            legend(strrep(PARAMS.session_ids, '_', ' '))
            xlabel('Frequency (Hz)')
            ylabel('Power (db)')
            title([chan{iC}])
        end
    else
        for iSess = 1:length(PARAMS.data_dir)
            hold on
            plot(PSD.(PARAMS.session_ids{iSess}).(chan{1}).f, 10*log10(PSD.(PARAMS.session_ids{iSess}).(chan{1}).pxx), 'color', c_ord(iSess,:), 'linewidth', 2)
            xlim([0 120])
            legend(strrep(PARAMS.session_ids, '_', ' '))
            xlabel('Frequency (Hz)')
            ylabel('Power (db)')
            title([chan{1}])
        end
    end
end
SetFigure([], gcf)
% if length(chan) >1
%     Square_subplots
% end

%% save a png and the matlab figure
% saveas(gcf, [PARAMS.id '_Comparison.png'])
% saveas(gcf, [PARAMS.id '_Comparison.fig'])

%%% coherence (to be implemented later for multi-site recording)





