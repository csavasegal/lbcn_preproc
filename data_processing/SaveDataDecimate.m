function SaveDataDecimate(sbj_name, project_name, block_name, fs_iEEG, fs_Pdio, dirs, refChan, epiChan, empty_chan)

%% load the data to define and eliminate bad channels

% Loop across blocks
for i = 1:length(block_name)
    bn = block_name{i};
    data_dir = [dirs.original_data '/' sbj_name '/' bn]; % directory for saving data
    
    target_fs = 1000; % 
    
    if fs_iEEG <= target_fs
        ecog_ds = 1;
    else
        ecog_ds = fs_iEEG/target_fs; % decimate factor
    end
    pdio_ds = 1; %downsample for photodiode signals

    % List all the files in that folder
    all_iEEG = dir(fullfile(data_dir, 'iEEG*.mat'));
    for i = 1:length(all_iEEG)
        channame_tmp = strsplit(all_iEEG(i).name, {'_', '.'});
        channame_iEEG{i} = channame_tmp{end-1};
    end
    
    cn_temp=strrep(cellstr(num2str(sort(str2double(channame_iEEG')),'%02d')),' ','')';
    channame_iEEG=cn_temp;
    
    all_Pdio = dir(fullfile(data_dir, 'Pdio*.mat'));
    for i = 1:length(all_Pdio)
        channame_tmp = strsplit(all_Pdio(i).name, {'_', '.'});
        channame_Pdio{i} = channame_tmp{end-1};
    end
    
    % Loop across iEEG channels
    for ei = 1:length(all_iEEG)
        d = load([data_dir '/' all_iEEG(ei).name]); 
        if isfield(d, 'fs') % prevent to keep downsampling if reruning 
            fs_iEEG = d.fs;
        else
        end
        [P,Q] = rat(target_fs/fs_iEEG);
        wave = resample(double(d.wave),P,Q);
        fs = P/Q*fs_iEEG;
        fs_iEEG_final = fs;
        channame = channame_iEEG{ei};
        save([data_dir '/' all_iEEG(ei).name],'wave','fs','channame')
        disp(['Saving chan iEEG ', bn , ' ' ,channame])
    end
    
    % Loop across Pdio channels
    for ei = 1:length(all_Pdio)
        load([data_dir '/' all_Pdio(ei).name])
        if isfield(d, 'fs') % prevent to keep downsampling if reruning 
            fs = d.fs;
        else
            fs = fs_Pdio;
        end
        fs_Pdio_final = fs;
        channame = channame_Pdio{ei};
        save([data_dir '/' all_Pdio(ei).name],'anlg','fs','channame')
        disp(['Saving chan Pdio ', bn , ' ' ,channame])
    end
    
    %% Update global variable
    
    % Plot the pdio channels (pdio_oldinds)
    % Prompt asking to visually identify the photodiode channel
    % add the photodiode channel label the globalVar
    
    fn = sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn);
    load(fn,'globalVar');
    
    globalVar.iEEG_rate = fs_iEEG_final;
    globalVar.Pdio_rate = fs_Pdio_final;
    globalVar.channame = channame_iEEG;
    globalVar.chanLength = length(wave);
    globalVar.nchan = length(globalVar.channame);
    globalVar.refChan = refChan;
    globalVar.epiChan = epiChan; 
    globalVar.emptyChan = empty_chan; 

    save(fn,'globalVar');
    disp('globalVar updated')

end
