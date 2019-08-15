function OrganizeTrialInfo7Heaven(sbj_name, project_name, block_names, dirs)

warning('off','all')
for i = 1:length(block_names)
    bn = block_names{i};
    
    %% Load globalVar
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));
    
    % Load behavioral file
    soda_name = dir(fullfile(globalVar.psych_dir, 'sodata*.mat'));
    K = load([globalVar.psych_dir '/' soda_name.name]); 
    
    % start trialinfo
    trialinfo = table;
    
    
    if length(K.conds) < length(K.theData)
        ii = length(K.conds)+1:length(K.theData);
        K.conds(ii) = NaN;
    else
    end
    
    ntrials = K.trial;
    
    for i = 1:ntrials
        if isempty(K.theData(i).keys)
            K.theData(i)=[];
        else
        end 
    end 
    
    for i = 1:ntrials
         if ~isempty(K.theData(i).keys)
            trialinfo.keys{i}=K.theData(i).keys;
        else
            trialinfo.keys{i}={NaN};
        end
        
        if ~isempty(K.theData(i).RT)
            trialinfo.RT(i) = K.theData(i).RT(1);
        else
            trialinfo.RT(i)=NaN;
        end
        trialinfo.StimulusOnsetTime(i,1) = K.theData(i).flip.StimulusOnsetTime;
        trialinfo.conds(i) = K.conds(i);
        trialinfo.stimlist(i) = K.wlist(i)';
    end 
        

    for i=1:ntrials
        if K.conds(i)==1
            trialinfo.condNames{i}='number';
        elseif K.conds(i)==2
            trialinfo.condNames{i}='word';
        elseif K.conds(i)==3
            trialinfo.condNames{i}='number_word';
        elseif K.conds(i)==4
            trialinfo.condNames{i}='number_sounding_word';
        elseif K.conds(i)==5
            trialinfo.condNames{i}='pseudoword';
        else
        end 
    end 
    
    if strcmp(sbj_name, 'S12_42_NC') && strcmp(bn, 'NC_02')
        trialinfo(156:200,:) = [];
    else
    end
end 
    
        save([globalVar.psych_dir '/trialinfo_', bn '.mat'], 'trialinfo')
    end
    
  