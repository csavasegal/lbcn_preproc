function PAC = computePACAll(sbj_name,project_name,block_names,dirs,phase_elecs,amp_elecs,pairing,freq_band,locktype,column,conds,pac_params)
%% INPUTS
%       sbj_name: subject name
%       project_name: name of task
%       block_names: blocks to be analyzed (cell of strings)
%       dirs: directories pointing to files of interest (generated by InitializeDirs)
%       phase_elecs: electrodes from which to extract phase (can be either
%                    vector of elec numbers or cell of elec names)
%       amp_elecs: electrodes from which to extract amp (leave empty if
%                   same as phase_elecs)
%       pairing: (only relevant if phase_elecs diff. from amp_elecs; otherwise leave empty)
%                'all' (compute PAC between phase of all sites in phase_elecs 
%                       and amp from all sites in phase_elecs) or 
%                'one' (compute PAC between corresponding entries in phase_elecs
%                       and amp_elecs; phase_elecs and amp_elecs must be same size)   
%       freq_band: specify spectral data to use (e.g. 'Spec' or 'SpecDense')
%       locktype: 'stim' or 'resp' (which event epoched data is locked to)
%       column: column of data.trialinfo by which to sort trials for plotting
%       conds:  cell containing specific conditions to plot within column
%               (default: all of the conditions within column);
%               can be cell of cells if grouping conditions together
%       pac_params: generated by genPACParams.m

%%
if isempty(amp_elecs)
    amp_elecs = phase_elecs;
end

if isempty(pac_params)
    pac_params = genPACParams(project_name);
end

nelec_p = length(phase_elecs);
nelec_a = length(amp_elecs);

% get both electrode names and electrode numbers
load([dirs.data_root,filesep,'OriginalData',filesep,sbj_name,filesep,'global_',project_name,'_',sbj_name,'_',block_names{1},'.mat'])
if iscell(phase_elecs)
    elecnums_p = ChanNamesToNums(globalVar,phase_elecs);
    elecnames_p = phase_elecs;
else
    elecnums_p = phase_elecs;
    elecnames_p = ChanNumsToNames(globalVar,phase_elecs);
end
if iscell(amp_elecs) % if names, convert to numbers
    elecnums_a = ChanNamesToNums(globalVar,amp_elecs);
    elecnames_a = amp_elecs;
else
    elecnums_a = amp_elecs;
    elecnames_a = ChanNumsToNames(globalVar,amp_elecs);
end

% if pairing all phase_elecs to all amp_elecs, reshape them so one-to-one
if strcmp(pairing,'all')
    elecnums_p = repmat(elecnums_p,[nelec_a,1]);
    elecnums_p = reshape(elecnums_p,[1,nelec_p*nelec_a]);
    elecnums_a = repmat(elecnums_a,[1,nelec_p]);
    
    elecnames_p = repmat(elecnames_p,[nelec_a,1]);
    elecnames_p = reshape(elecnames_p,[1,nelec_p*nelec_a]);
    elecnames_a = repmat(elecnames_a,[1,nelec_p]);
end

% specify type of data to load
tag = [locktype,'lock'];
if pac_params.blc
    tag = [tag,'_bl_corr'];
end

% if have previously run PAC on other pairs of elecrodes, load and append to
% file (rather than overwriting)
dir_out = [dirs.result_root,filesep,project_name,filesep,sbj_name,filesep,'allblocks',filesep];   
fn = [dir_out,project_name,'_PAC_',freq_band,'.mat'];
if exist(fn,'file')
    load(fn,'PAC')
end

if ~exist(dir_out,'dir')
    mkdir(dir_out)
end

% Group trials by condition
data_tmp = concatBlocks(sbj_name,block_names,dirs,elecnums_p(1),freq_band,'Spec',{'phase'},tag);
if isempty(conds)
    tmp = find(~cellfun(@isempty,(data_tmp.trialinfo.(column))));
    conds = unique(data_tmp.trialinfo.(column)(tmp));
end
[grouped_trials_all,grouped_condnames] = groupConds(conds,data_tmp.trialinfo,column,pac_params.noise_method,pac_params.noise_fields_trials,false);

for ei = 1:length(elecnums_p)
    elp = elecnums_p(ei); % electrode for phase
    ela = elecnums_a(ei); % electrode for amp
    % concatenate data across blocks
    data_phase = concatBlocks(sbj_name,block_names,dirs,elp,freq_band,'Spec',{'phase'},tag);
    data_amp = concatBlocks(sbj_name,block_names,dirs,ela,freq_band,'Spec',{'wave'},tag);
    [grouped_trials_phase,~] = groupConds(conds,data_phase.trialinfo,column,pac_params.noise_method,pac_params.noise_fields_trials,false);    
    [grouped_trials_amp,~] = groupConds(conds,data_amp.trialinfo,column,pac_params.noise_method,pac_params.noise_fields_trials,false);
    for ci = 1:length(grouped_trials_all)
        disp(['Computing PAC between ',elecnames_p{ei},' and ',elecnames_a{ei},'; Cond: ',grouped_condnames{ci}])
        grouped_trials_tmp = intersect(grouped_trials_phase{ci},grouped_trials_amp{ci}); % interesection of non-noisy trials of each elec
        tmp_phase = data_phase;
        tmp_amp = data_amp;
        tmp_phase.phase = data_phase.phase(:,grouped_trials_tmp,:);
        tmp_amp.wave = data_amp.wave(:,grouped_trials_tmp,:);
        tmp_PAC = computePAC(tmp_phase,tmp_amp,pac_params);
        PAC.(grouped_condnames{ci}).(['p',elecnames_p{ei},'_a',elecnames_a{ei}])=tmp_PAC.norm;
    end    
end

PAC.phase_freq = tmp_PAC.phase_freq;
PAC.amp_freq = tmp_PAC.amp_freq;

save(fn,'PAC')

end

