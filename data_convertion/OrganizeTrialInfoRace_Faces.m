function OrganizeTrialInfoRace_Faces(sbj_name, project_name, block_names, dirs,center)
%this is for race active
for i = 1:length(block_names)
    bn = block_names{i};
    
    %% Load globalVar
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));
    
    % Load behavioral file
    soda_name = dir(fullfile(globalVar.psych_dir, 'PT*.mat'));
    %% start from here
    K = load([globalVar.psych_dir '/' soda_name.name]); % block 55 %% FIND FILE IN THE FOLDER AUTO
    
    trialinfo = table;
    
    if strcmp(center,'China')
        race = 1;
    end
    %race = repmat(race,108,1);
    if strcmp(sbj_name, 'C18_28')
        gender = 2;
    elseif strcmp(sbj_name, 'C18_27')
        gender = 1;
    elseif strcmp(sbj_name, 'C18_29')
        gender = 1;
    elseif strcmp(sbj_name, 'C18_30')
        gender = 1;
    elseif strcmp(sbj_name, 'C18_31')
        gender = 1;
    elseif strcmp(sbj_name, 'C18_41')
        gender = 1;
    elseif strcmp(sbj_name, 'C18_42')
        gender = 1;
    elseif strcmp(sbj_name,'C18_43')
        gender = 2;
    elseif strcmp(sbj_name,'C18_44')
        gender = 1;
    elseif strcmp(sbj_name,'C18_45')
        gender = 2;
    elseif strcmp(sbj_name,'C18_46')
        gender = 1;
    elseif strcmp(sbj_name,'C18_47')
        gender = 1;
    elseif strcmp(sbj_name,'C18_49')
        gender = 2;
    elseif strcmp(sbj_name, 'C19_50')
        gender = 1;
    elseif strcmp(sbj_name, 'C19_51')
        gender = 1;
    elseif strcmp(sbj_name, 'C18_40')
        gender = 1;
    elseif strcmp(sbj_name, 'S19_145_PC')
        gender = 1;
    elseif strcmp(sbj_name, 'S20_148_SM')
        gender = 1;
    elseif strcmp(sbj_name, 'C18_32')
        gender = 1;
    elseif strcmp(sbj_name, 'C18_33')
        gender = 1;
    elseif strcmp(sbj_name, 'C18_34')
        gender = 1;
    elseif strcmp(sbj_name, 'C18_35')
        gender = 1;
    elseif strcmp(sbj_name, 'C18_38')
        gender = 1;
    elseif strcmp(sbj_name, 'C19_52')
        gender = 2;
    elseif strcmp(sbj_name, 'C19_53')
        gender = 1;
    elseif strcmp(sbj_name, 'C19_55')
        gender = 1;
    elseif strcmp(sbj_name, 'C19_58')
        gender = 2;
    elseif strcmp(sbj_name, 'C19_60')
        gender = 1;
    elseif strcmp(sbj_name, 'C19_62')
        gender = 2;
    elseif strcmp(sbj_name, 'C18_37')
        gender = 1;
    else
        error('Please define the gender info of patient; female = 1, male = 2')
    end
    %gender = repmat(gender,108,1);
    
    %get center info
    %center = repmat(center,108,1);
    gender = repmat(gender,30,1);
    center = repmat(center,30,1);
    race = repmat(race,30,1);
    
    % get the response time of this block
    for i=1:length(K.orderData)
        if strcmp(K.orderData(i,1),'Rating')
            RT(1,i) = K.orderData{3,2}{1,3};
        end
    end
    
    % get the face info of this block
    
    for i=1:length(K.orderData)
        if contains(K.orderData(i,1),'W')
            test_race(i) = 3;
        elseif    contains(K.orderData(i,1),'B')
            test_race(i) = 2;
        elseif contains(K.orderData(i,1),'A')
            test_race(i) = 1;
        else
            test_race(i) = NaN;
        end
    end
    
    % test_race = test_race(2:2:216)';
    % get the gender info of this block
    for i = 1:length(K.orderData)
        if contains(K.orderData(i,1),'M')
            test_gender(i) = 2;
        elseif contains(K.orderData(i,1),'F')
            test_gender(i) = 1;
        else
            test_gender(i) = NaN;
        end
    end
    
    test_gender = test_gender';
    test_race = test_race';
    test_gender(isnan(test_gender(:,1)))=[];
    test_race(isnan(test_race(:,1)))=[];
    RT(any(RT == 0,1))=[];
    
    trialinfo = table;
    trialinfo.center = center;
    trialinfo.race = race;
    trialinfo.gender = gender;
    
    trialinfo.RT = RT';
    trialinfo.test_gender = test_gender;
    trialinfo.test_race = test_race;
    
    for i=1:length(K.orderData)
        if strcmp(K.orderData(i),'ITI')
            ITItime(i) = K.orderData{i,2}.StimulusOnsetTime
        else
            ITItime(i) = NaN
        end
        
        if contains(K.orderData(i,1),'W')
            stimtime(i) = K.orderData{i,2}.StimulusOnsetTime
        elseif    contains(K.orderData(i,1),'B')
            stimtime(i) = K.orderData{i,2}.StimulusOnsetTime
        elseif contains(K.orderData(i,1),'A')
            stimtime(i) = K.orderData{i,2}.StimulusOnsetTime
        else
            stimtime(i) = NaN
        end
    end
    
    ITItime=ITItime';
    ITItime(isnan(ITItime(:,1)))=[];
    stimtime=stimtime';
    stimtime(isnan(stimtime(:,1)))=[];
    StimulusOnsetTime=[ITItime,stimtime];
    
    trialinfo.StimulusOnsetTime = StimulusOnsetTime
    
    %change
%     StimulusOnsetTime=stimtime;
%     trialinfo.StimulusOnsetTime = StimulusOnsetTime;
%     
    
    for i= 1:size(trialinfo,1)
        if trialinfo.test_race(i) == 1 && trialinfo.test_gender(i) == 1
            trialinfo.condNames{i} = 'asian';
            trialinfo.condNames2{i} = 'asian_female';
        elseif trialinfo.test_race(i) == 1 && trialinfo.test_gender(i) == 2
            trialinfo.condNames{i} = 'asian';
            trialinfo.condNames2{i} = 'asian_male';
        elseif trialinfo.test_race(i) == 2 && trialinfo.test_gender(i) == 1
            trialinfo.condNames{i} = 'black';
            trialinfo.condNames2{i} = 'black_female';
        elseif trialinfo.test_race(i) == 2 && trialinfo.test_gender(i) == 2
            trialinfo.condNames{i} = 'black';
            trialinfo.condNames2{i} = 'black_male';
        elseif trialinfo.test_race(i) == 3 && trialinfo.test_gender(i) == 1
            trialinfo.condNames{i} = 'white';
            trialinfo.condNames2{i} = 'white_female';
        elseif trialinfo.test_race(i) == 3 && trialinfo.test_gender(i) == 2
            trialinfo.condNames{i} = 'white';
            trialinfo.condNames2{i} = 'white_male';
        end
    end
    
    
    save([globalVar.psych_dir '/trialinfo_', bn '.mat'], 'trialinfo');
end
%%
%     the StimulusOnsetTime
%    for i = 1:length(K.theData)
%        trialinfo.StimulusOnsetTime(i,1) = K.theData(i).flip.StimulusOnsetTime;
%        trialinfo.condition(i) ={ K.theData(i).conds}
%    end
%
%    %to get the details of the condition
%    for i=1:length(K.theData)
%        temp = extractBefore(trialinfo.condition(i), '_')
%        if strcmp(temp,'WF')
%            trialinfo.face_race(i) = {'white'};
%            trialinfo.face_gender(i) = {'female'};
%        elseif strcmp(temp,'WM')
%            trialinfo.face_race(i) = {'white'};
%            trialinfo.face_gender(i) = {'male'};
%        elseif strcmp(temp,'AM')
%            trialinfo.face_race(i) = {'asian'};
%            trialinfo.face_gender(i) = {'male'};
%        elseif strcmp(temp,'AF')
%            trialinfo.face_race(i) = {'asian'};
%            trialinfo.face_gender(i) = {'female'};
%        elseif strcmp(temp,'BM')
%            trialinfo.face_race(i) = {'black'};
%            trialinfo.face_gender(i) = {'male'};
%        elseif strcmp(temp,'BF')
%            trialinfo.face_race(i) = {'asian'};
%            trialinfo.face_gender(i) = {'female'};
%        else
%        end
%    end
%
%
%
%    if trialinfo.condition(i)
%
%
%     for i = 2:2:length(K.theData)
%         if strcmp(K.theData(i).keys,'noanswer')
%             for a=1:108
%                 trialinfo.condition(a) = {K.theData(i).conds};
%                 trialinfo.StimulusOnsetTime(i,1) = K.theData(i).flip.StimulusOnsetTime;
%             end
%         end

%%
%    for i = 2:2:216
%        a(i) = K.theData(i).flip.StimulusOnsetTime - K.theData(i-1).flip.StimulusOnsetTime-K.theData(i).RT
%
%    end
%    a = a(2:2:216)'