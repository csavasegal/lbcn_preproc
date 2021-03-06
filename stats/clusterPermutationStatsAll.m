% function [pval, t_orig, clust_info, seed_state, est_alpha,timing,issig,time_events] = clusterPermutationStatsAll(sbj_name,project_name,block_names,dirs,elecs,freq_band,datatype,locktype,column,conds,stats_params,plot_params)
function [pval, t_orig, clust_info] = clusterPermutationStatsAll(sbj_name,project_name,block_names,dirs,elecs,freq_band,datatype,locktype,column,conds,stats_params,plot_params)
%% INPUTS
%       sbj_name: subject name
%       project_name: name of task
%       block_names: blocks to be analyed (cell of strings)
%       dirs: directories pointing to files of interest (generated by InitializeDirs)
%       elecs: can select subset of electrodes to epoch (default: all)
%              (if specifying elecs, can either be vectors of elec #s or cells of elec names)
%       freq_band: 'HFB' or 'Theta' ...
%       datatype: 'Band',or 'Spec'
%       locktype: 'stim' or 'resp' (which event epoched data is locked to)
%       column: column of data.trialinfo by which to sort trials for plotting
%       conds:  cell containing specific conditions to plot within column (default: all of the conditions within column)
%               can group multiple conds together by having a cell of cells
%               (e.g. conds = {{'math'},{'autobio','self-internal'}})
%       stats_params:    controls plot features (see genPlotParams.m script)



if isempty(stats_params)
    stats_params = genStatsParams(project_name);
end

if isempty(plot_params)
    
    if strcmp(datatype,'Band')
        plot_params = genPlotParams(project_name,'timecourse');      
    elseif strcmp(datatype, 'Spec')
        plot_params = genPlotParams(project_name,'ERSP');
    end
end

load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,block_names{1}),'globalVar');
if iscell(elecs)
    elecs = ChanNamesToNums(globalVar,elecs);
end

if isempty(elecs)
    elecs = setdiff(1:globalVar.nchan,globalVar.refChan);
end

dir_out = [dirs.result_root,filesep,project_name,filesep,sbj_name,filesep,'Stats',filesep,datatype,'Data',filesep,freq_band,filesep,locktype,'lock'];


%% loop through electrodes and plot

tag = [locktype,'lock'];
if stats_params.blc
    tag = [tag,'_bl_corr'];
end
concatfield = {'wave'}; % concatenate amplitude across blocks

plottag = 'fig';

% determine folder name for plots by compared conditions
for ei = 1
    el = elecs(ei);
    data_all = concatBlocks(sbj_name,block_names,dirs,el,freq_band,datatype,concatfield,tag);    
    groupall = false;       
    if isempty(conds)
        tmp = find(~cellfun(@isempty,(data_all.trialinfo.(column))));
        conds = unique(data_all.trialinfo.(column)(tmp));
    end
    cond_names = groupCondNames(conds,groupall);
end

folder_name = cond_names{1};
for gi = 2:length(cond_names)
    folder_name = [folder_name,'_',cond_names{gi}];
end
dir_out = [dir_out,filesep,folder_name];
if ~exist(dir_out)
    mkdir(dir_out)
end

pval = cell(length(elecs),1);
t_orig = cell(length(elecs),1);
clust_info = cell(length(elecs),1);

% do cluster based permutation
for ei = 1:length(elecs)
    el = elecs(ei);
    data_all = concatBlocks(sbj_name,block_names,dirs,el,freq_band,datatype,concatfield,tag);
    if strcmp(stats_params.noise_method,'timepts')
        data_all = removeBadTimepts(data_all,stats_params.noise_fields_timepts);
    end

    [grouped_trials,~] = groupConds(conds,data_all.trialinfo,column,plot_params.noise_method,plot_params.noise_fields_trials,false);
    %% cluster based permutation test & plot
    disp(['ClusterPerm on: ',sbj_name,'_',num2str(el)]);
    
    if length(grouped_trials{1})>2
%         [pval{ei}, t_orig{ei}, clust_info{ei}, seed_state, est_alpha,timing(ei),issig(ei),time_events]=clusterPermutationStats(data_all,column,conds,stats_params,plot_params);
         [pval{ei}, t_orig{ei}, clust_info{ei}, ~, ~,~,~]=clusterPermutationStats(data_all,column,conds,stats_params,plot_params);
%         if issig(ei)
            fn_out = sprintf('%s/%s_%s_%s_%s_%slock_%s%s.png',dir_out,sbj_name,data_all.label,project_name,freq_band,locktype,folder_name,plottag);
            savePNG(gcf, 200, fn_out)
            close
%         end
    end
    

end
%    data_out = sprintf('%s/%s_%s_%s_%s_%slock_%s.mat',dir_out,sbj_name,data_all.label,project_name,freq_band,locktype,folder_name);
%    save(data_out,'elecs','pval','t_orig','clust_info','time_events');
end




