%% OrganizeTrialInfo for Scrambled 
function OrganizeTrialInfoScrambled(sbj_name, project_name, block_names, dirs)

warning('off','all')

%
 K = load('/Volumes/neurology_jparvizi$/SHICEP_S14_67_RH/Data/Scrambled/S14_67_RH_22/sodata.S14_67_RH.28.05.2014.10.10.mat')


for i = 1:length(block_names)
    bn = block_names{i};
    
    %% Load globalVar
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));
    
    % Load behavioral file
    soda_name = dir(fullfile(globalVar.psych_dir, 'sodata*.mat'));
    K = load([globalVar.psych_dir '/' soda_name.name]); % block 55 %% FIND FILE IN THE FOLDER AUTO
    
    % start trialinfo
    trialinfo = table;
    ntrials = K.trial;
    
    
    
    for i = 1:ntrials
        if iscell(K.theData(i).keys(1))
            temp_key = num2str(cell2mat(K.theData(i).keys(1)));
        else
            temp_key = K.theData(i).keys;
        end
        switch temp_key
            case 'DownArrow'
                K.theData(i).keys='2';
            case 'End'
                K.theData(i).keys='1';
            case 'noanswer'
                K.theData(i).keys='NaN';
            case '2@'
                K.theData(i).keys='2';
            case '1!'
                K.theData(i).keys='1';
        end
        if ~isnan(str2num(temp_key));
            sbj_resp(i)= str2num(temp_key);
        else
            sbj_resp(i)= NaN;
        end
        if ~isnan(str2num(temp_key));
            sbj_resp(i)= str2num(temp_key);
        else
            sbj_resp(i)= NaN;
        end

        trialinfo.keys{i} = K.theData(i).keys(1);
        trialinfo.RT(i,1) = K.theData(i).RT(1); % Becase some cases had 2 equal values for RT in the same trial
        trialinfo.StimulusOnsetTime(i,1) = K.theData(i).flip.StimulusOnsetTime;
        cond= [K.conds(i)]';
        trialinfo.cond(i) = cond;
        trialinfo.stimlist(i) = K.stimlist(i)'; %included only because it is useful for determing condition
    end
    
    
    %CondNames seems to depend on the version of Scrambled (diff numb.
    %used)
    
    %This is what Amy had:
    %condNames= {'letter','number','scramble-letter','scramble-number','foreign'};
    %     for ci = 1:length(condNames)
    %         conds(cond==ci)=condNames(ci);
    %     end
    %     trialinfo.condNames = conds';
    %
    %     eng = (cond == 1 | cond == 2)';
    %     foreign = ismember(cond,[3 4 5])';
    %     correct(eng & strcmp({K.theData.keys},'1')) = true;
    %     correct(foreign & strcmp({K.theData.keys},'1')) = false;
    %     correct(eng & strcmp({K.theData.keys},'2')) = false;
    %     correct(foreign & strcmp({K.theData.keys},'2')) = true;
    %     trialinfo.isCorrect = [correct]';
    
    for ci= 1:ntrials
        romannumb = startsWith(K.stimlist,'r','IgnoreCase',true);
        mirror = startsWith(K.stimlist,'m','IgnoreCase',true);
        devanagari = startsWith(K.stimlist,'d','IgnoreCase',true);
        number = startsWith(K.stimlist,'num','IgnoreCase',true);
        snum = startsWith(K.stimlist,'snum','IgnoreCase',true);
        slett = startsWith(K.stimlist,'slett','IgnoreCase',true);
        lett = startsWith(K.stimlist,'lett','IgnoreCase',true);
        foreign = startsWith(K.stimlist,'foreign','IgnoreCase',true);
        chinese_num = startsWith(K.stimlist,'cnum','IgnoreCase',true); %version 3
        chinese_word = startsWith(K.stimlist,'cword','IgnoreCase',true); %version 3
        pound = startsWith(K.stimlist,'pound','IgnoreCase',true);
    end
    
    
    %What is commented out below can be changed based on what the
    %experiment is looking for. The devanagari symbols used are actual
    %numbers (can see description of which numbers below). Therefore, they
    %can classified as either numbers or as foreign. The same can be said
    %for the Chinese numbers and letters and for the mirrored letters and
    %numbers. 
    
    %use CondDescrip to do stim later on
    for i=1:ntrials
        if romannumb(i)==1
            trialinfo.condDescript{i}='number';
            trialinfo.condNames{i}='roman-number';
        elseif mirror(i)==1
            %trialinfo.condNames{i}='foreign'
            trialinfo.condDescript{i}='number';
            trialinfo.condNames{i}='foreign-mirror-number';
        elseif devanagari(i)==1
            trialinfo.condDescript{i}='number';
            %trialinfo.condNames{i}='foreign'
            trialinfo.condNames{i}='foreign-devanagari';
        elseif number(i)==1
            trialinfo.condNames{i}='number';
            trialinfo.condDescript{i}='number';
        elseif lett(i)==1
            trialinfo.condNames{i}='letter';
            trialinfo.condDescript{i}='letter';
        elseif snum(i)==1
            trialinfo.condNames{i}='scramble-number';
            trialinfo.condDescript{i} = 'scramble-number';
        elseif slett(i)==1
            trialinfo.condNames{i}='scramble-letter';
            trialinfo.condDescript{i} = 'scramble-letter';
        elseif foreign(i)==1
            trialinfo.condNames{i}='foreign';
            trialinfo.condDescript{i}='foreign';
        elseif chinese_num==1
            %trialinfo.condNames{i}='foreign'; %what if patient was Chinese?
            trialinfo.condDescript{i}='number';
            trialinfo.condNames{i}='foreign-chinese_num';
        elseif chinese_word==1
            trialinfo.condDescript{i}='letter';
            %trialinfo.condNames{i}='foreign';
            trialinfo.condNames{i}='foreign-chinese_word';
         elseif pound==1
            trialinfo.condNames{i}='pound';
            trialinfo.condDescript{i}='pound';
        else
        end
        
        if (strcmp(trialinfo.condNames(i),'number') & strcmp(trialinfo.keys(i),'1'))
            trialinfo.isCorrect(i)='1';
        elseif (strcmp(trialinfo.condNames(i),'letter') & strcmp(trialinfo.keys(i),'1'))
            trialinfo.isCorrect(i)='1';
        elseif (strcmp(trialinfo.condNames(i),'foreign') & strcmp(trialinfo.keys(i),'2'))
            trialinfo.isCorrect(i)='1' ;
        elseif (strcmp(trialinfo.condNames(i),'scramble-number') & strcmp(trialinfo.keys(i),'2'))
            trialinfo.isCorrect(i)='1' ;
        elseif (strcmp(trialinfo.condNames(i),'scramble-letter') & strcmp(trialinfo.keys(i),'2'))
            trialinfo.isCorrect(i)='1' ;
        elseif (strcmp(trialinfo.condNames(i),'pound') & strcmp(trialinfo.keys(i),'2'))
            trialinfo.isCorrect(i)='1' ;
        elseif (strcmp(trialinfo.condNames(i),'foreign-devanagari') & strcmp(trialinfo.keys(i),'2'))
            trialinfo.isCorrect(i)='1' ;
        elseif (strcmp(trialinfo.condNames(i),'foreign-chinese_num') & strcmp(trialinfo.keys(i),'2'))
            trialinfo.isCorrect(i)='1' ;
        elseif (strcmp(trialinfo.condNames(i),'foreign-chinese_word') & strcmp(trialinfo.keys(i),'2'))
            trialinfo.isCorrect(i)='1' ;
        elseif (strcmp(trialinfo.condNames(i),'foreign-mirror-number') & strcmp(trialinfo.keys(i),'2'))
            trialinfo.isCorrect(i)='1' ;
        elseif (strcmp(trialinfo.condNames(i),'roman-number') & strcmp(trialinfo.keys(i),'1'))
            trialinfo.isCorrect(i)='1' ;
        else
            trialinfo.isCorrect(i)='0'  ;
        end
      
    end
    
    
    %% Decoding the stimuli: 
    %Devanagari: follows the pattern below; skips 10 and 20
        %d2= 2 in devanagari
        %d12 = 2
        %d22 = 2
    %Letters: 01 = T, 2 = S, 3 = N, 4 = R, 5 = H, 6 = E, 7 = D, 8 = C , 9 =
    %A, SKIP 10 , 11 = T; and starts again; skips 20 and then continues
    %again
    
    % Mirror; 1 = 1 etc; stim numbers correspond to actual numbers; skip
    % 10, 20
    % Roman is actual numbers
    % Scrambled letters correspond to 'letters'
    % Scrambled numbers correspond to 'numbers'
    %newer version introduces 'foreign' where they do not skip 10
    
    
    for i=1:ntrials
        %cannot rely on condition names because some versions used
        %devanagari and some used just foreign symbols
        temp = extractBefore(trialinfo.stimlist(i), '.bmp');
        length_temp = strlength(temp);
        stim_temp = extractBefore(temp, length_temp-1); %same thing as the startsWith function above
        %numb_temp = extractAfter(temp, 2)
        %A = regexp(temp,['\d'])
        %A = regexp(temp,['\d+\d'])
        num_temp = string(regexp(temp, '\d+', 'match'));
        
        
        if strcmp(trialinfo.condDescript(i), 'foreign') 
            %if strcmp(num_temp,'01')
                trialinfo.stim_lett{i} = 'NaN';
                trialinfo.stim_num{i} = NaN;
                trialinfo.stim{i} = temp;
        elseif  strcmp(trialinfo.condDescript(i), 'pound')
                trialinfo.stim_lett{i} = 'NaN';
                trialinfo.stim_num{i} = NaN;
                trialinfo.stim{i} = 'pound';
        elseif strcmp(trialinfo.condDescript(i), 'letter') || strcmp(trialinfo.condDescript(i), 'scramble-letter')
             if strcmp(num_temp,'01')|| strcmp(num_temp,'11')|| strcmp(num_temp,'21')|| strcmp(num_temp,'31')
                trialinfo.stim_lett{i} = 'T';
                trialinfo.stim_num{i} = NaN;
                trialinfo.stim{i} = 'T';
            elseif strcmp(num_temp,'02')|| strcmp(num_temp,'12')|| strcmp(num_temp,'22') || strcmp(num_temp,'32')
                trialinfo.stim_lett{i} = 'S';
                trialinfo.stim_num{i} = NaN;
                trialinfo.stim{i} = 'S';
            elseif strcmp(num_temp,'03')|| strcmp(num_temp,'13')|| strcmp(num_temp,'23') || strcmp(num_temp,'33')
                trialinfo.stim_lett{i} = 'N' ;
                trialinfo.stim_num{i} = NaN;
                trialinfo.stim{i} = 'N';
            elseif strcmp(num_temp,'04')|| strcmp(num_temp,'14')|| strcmp(num_temp,'24')|| strcmp(num_temp,'34')
                trialinfo.stim_lett{i} = 'R';
                trialinfo.stim_num{i} = NaN;
                trialinfo.stim{i} = 'R';
            elseif strcmp(num_temp,'05')|| strcmp(num_temp,'15')|| strcmp(num_temp,'25') || strcmp(num_temp,'35')
                trialinfo.stim_lett{i} = 'H';
                trialinfo.stim_num{i} = NaN;
                trialinfo.stim{i} = 'H';
            elseif strcmp(num_temp,'06')|| strcmp(num_temp,'16')|| strcmp(num_temp,'26') || strcmp(num_temp,'36')
                trialinfo.stim_lett{i} = 'E';
                trialinfo.stim_num{i} = NaN;
                trialinfo.stim{i} = 'E';
            elseif strcmp(num_temp,'07')|| strcmp(num_temp,'17')|| strcmp(num_temp,'27')|| strcmp(num_temp,'37')
                trialinfo.stim_lett{i} = 'D';
                trialinfo.stim_num{i} = NaN;
                trialinfo.stim{i} = 'D';
            elseif strcmp(num_temp,'08')|| strcmp(num_temp,'18')|| strcmp(num_temp,'28')|| strcmp(num_temp,'38')
                trialinfo.stim_lett{i} = 'C';
                trialinfo.stim_num{i} = NaN;
                trialinfo.stim{i} = 'C';
            elseif strcmp(num_temp,'09')|| strcmp(num_temp,'19')|| strcmp(num_temp,'29')|| strcmp(num_temp,'39')
                trialinfo.stim_lett{i} = 'A';
                trialinfo.stim_num{i} = NaN;
                trialinfo.stim{i} = 'A';
            end
        elseif strcmp(trialinfo.condDescript(i), 'number') || strcmp(trialinfo.condDescript(i), 'scramble-number')
            if strcmp(num_temp,'01')|| strcmp(num_temp,'11')|| strcmp(num_temp,'21')|| strcmp(num_temp,'31')
                trialinfo.stim_num{i} = 1; %&& trialinfo.stim_lett(i) = 'NaN'
                trialinfo.stim_lett{i} = 'NaN';
                trialinfo.stim{i} = '1';
            elseif strcmp(num_temp,'02')|| strcmp(num_temp,'12')|| strcmp(num_temp,'22') || strcmp(num_temp,'32')
                trialinfo.stim_num{i} = 2;
                trialinfo.stim_lett{i} = 'NaN';
                trialinfo.stim{i} = '2';
            elseif strcmp(num_temp,'03')|| strcmp(num_temp,'13')|| strcmp(num_temp,'23') || strcmp(num_temp,'33')
                trialinfo.stim_num{i} = 3   ;
                trialinfo.stim_lett{i} = 'NaN';
                trialinfo.stim{i} = '3';
            elseif strcmp(num_temp,'04')|| strcmp(num_temp,'14')|| strcmp(num_temp,'24')|| strcmp(num_temp,'34')
                trialinfo.stim_num{i} = 4 ;
                trialinfo.stim_lett{i} = 'NaN';
                trialinfo.stim{i} = '4';
            elseif strcmp(num_temp,'05')|| strcmp(num_temp,'15')|| strcmp(num_temp,'25') || strcmp(num_temp,'35')
                trialinfo.stim_num{i} = 5;
                trialinfo.stim_lett{i} = 'NaN';
                trialinfo.stim{i} = '5';
            elseif strcmp(num_temp,'06')|| strcmp(num_temp,'16')|| strcmp(num_temp,'26') || strcmp(num_temp,'36')
                trialinfo.stim_num{i} = 6;
                trialinfo.stim_lett{i} = 'NaN';
                trialinfo.stim{i} = '6';
            elseif strcmp(num_temp,'07')|| strcmp(num_temp,'17')|| strcmp(num_temp,'27')|| strcmp(num_temp,'37')
                trialinfo.stim_num{i} = 7;
                trialinfo.stim_lett{i} = 'NaN';
                trialinfo.stim{i} = '7';
            elseif strcmp(num_temp,'08')|| strcmp(num_temp,'18')|| strcmp(num_temp,'28')|| strcmp(num_temp,'38')
                trialinfo.stim_num{i} = 8;
                trialinfo.stim_lett{i} = 'NaN';
                trialinfo.stim{i} = '8';
            elseif strcmp(num_temp,'09')|| strcmp(num_temp,'19')|| strcmp(num_temp,'29')|| strcmp(num_temp,'39')
                trialinfo.stim_num{i} = 9';
                trialinfo.stim_lett{i} = 'NaN';
                trialinfo.stim{i} = '9';
            end
        end
    end        
    end
    
    
    save([globalVar.psych_dir '/trialinfo_', bn '.mat'], 'trialinfo');
end