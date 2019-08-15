function OrganizeTrialInfoLogo(sbj_name, project_name, block_names, dirs)

%% Note: can see the description of all the stimuli at the bottom of this script
warning('off','all')
%need to compare passive vs active

%Logo:
%Company_logo: 64: shell; 65: nike; 66: mitsubishi; 67: apple; 68:
%mazda; 69: mercedes; 70: toyota; 71: chevrolet; 72: chrysler

%FalseFonts; seems to look similar to scrambled numbers/scrambled
%letters
%28:
%29:
%30:
%31:
%32:
%33: same as snum04 --> 4
%34: same as snum02--> 2
%35: same as slett02 --> S
%36: same as snum01 --> 1


%Foreign ; seems to have some overlap with the devanagari in
%scrambled/ and the foreign from version 2 of scrambled
%10; same with d04
%11; same with d07
%12; same with foreign01
%13; same with foreign02
%14; same with foreign03
%15;
%16; same with
%17
%18; same with foreign07

%Letters:
%19: A
%20: B
%21: F
%22: G
%23: S
%24: M
%25: R
%26: Y
%27: Z

%Meaningful_logo
%55: no turn around
%56: recycling
%57: winding road
%58: pedestrian
%59: double note music logo
%60: no symbol
%61: single note music logo
%62: option key
%63: cd vector icon

%Num_sym
%46: dollar sign
%47: division sign
%48: greater/equal than
%49: less/equal than
%50: Greater than
%51: approximately equal to
%52: pound
%53: plus
%54: equal

%numbers:1:9 expected

%word_sym
%37: exclamation point
%38: question mark
%39: apostrophe
%40: Apersand
%41: semicolon
%42: tilde
%43: @
%44: colon
%45: paragraph sign

for ci = 1:length(block_names)
    bn = block_names{ci};
    
    %% Load globalVar
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));
    
    % Load behavioral file
    soda_name = dir(fullfile(globalVar.psych_dir, 'sodata*.mat'));
    K = load([globalVar.psych_dir '/' soda_name.name]); % block 55 %% FIND FILE IN THE FOLDER AUTO
    
    % start trialinfo
    trialinfo = table;
    ntrials = K.trial;
    
%     for ii = 1:ntrials
%         if sum(K.theData(ii).RT) == 0
%             trialinfo.RT(ii)=NaN; %passive vs active condition
%             trialinfo.isActive(ii)=0;
%         else
%             trialinfo.RT(ii) = K.theData(ii).RT;
%             trialinfo.isActive(ii)=1;
%         end
%     end
    
    
    for i = 1:ntrials
        if ~isempty(K.theData(i).keys)
            trialinfo.keys{i}=K.theData(i).keys;
        else
            trialinfo.keys{i}={NaN};
        end
        
        if K.theData(i).RT == 0
            trialinfo.RT(i)=NaN; %passive vs active condition
            trialinfo.isActive(i)=0;
        else
            trialinfo.RT(i) = K.theData(i).RT(1);
            trialinfo.isActive(1:ntrials)=1; %should make the whole column 1
        end
        
        trialinfo.StimulusOnsetTime(i) = K.theData(i).flip.StimulusOnsetTime;
        trialinfo.stimlist(i) = K.stimlist(i)';
        temp = extractBefore(trialinfo.stimlist(i), '.png');
        if contains(temp, ' copy')
            temp = extractBefore(trialinfo.stimlist(i), ' copy');
        else
        end 
        length_temp = strlength(temp);
        stim_temp = extractBefore(temp, length_temp-1);
        num_temp = string(regexp(temp, '\d+', 'match'));
        num = str2num(num_temp);
        
        %getting the conditionNames; helps with grouping by using
        %condDescript
        
        if 0<num&& num<=9
            trialinfo.condNames{i} = 'numbers';
        elseif 10<=num&& num <=18
            trialinfo.condNames{i} = 'foreign';
        elseif 19<=num&& num<=27
            trialinfo.condNames{i} = 'letters';
        elseif 28<=num&& num<=36
            trialinfo.condNames{i} = 'falsefonts';
        elseif 37<=num&& num<=45
            trialinfo.condNames{i} = 'word_sym';
        elseif 46<=num&& num<=54
            trialinfo.condNames{i} = 'num_sym';
        elseif 55<=num&& num<=63
            trialinfo.condNames{i} = 'meaningful_logo';
        elseif 64<=num&& num<=72
            trialinfo.condNames{i} = 'company_logo';
        else
        end
        
        if strcmp(trialinfo.condNames(i), 'foreign')
            trialinfo.stim(i) = temp;
        elseif strcmp(trialinfo.condNames(i), 'falsefonts')
            trialinfo.stim(i) = temp;
        elseif strcmp(trialinfo.condNames(i), 'numbers')
           % trialinfo.stim(i) = num2cell(num);
           trialinfo.stim(i) = {num};
        elseif strcmp(trialinfo.condNames(i), 'letters')
            if strcmp(num_temp,'19')
                trialinfo.stim{i} = 'A';
            elseif strcmp(num_temp,'20')
                trialinfo.stim{i} = 'B';
            elseif strcmp(num_temp,'21')
                trialinfo.stim{i} = 'F';
            elseif strcmp(num_temp,'22')
                trialinfo.stim{i} = 'G';
            elseif strcmp(num_temp,'23')
                trialinfo.stim{i} = 'S';
            elseif strcmp(num_temp,'24')
                trialinfo.stim{i} = 'M';
            elseif strcmp(num_temp,'25')
                trialinfo.stim{i} = 'R';
            elseif strcmp(num_temp,'26')
                trialinfo.stim{i} = 'Y';
            elseif strcmp(num_temp,'27')
                trialinfo.stim{i} = 'Z';
            else
            end
        elseif strcmp(trialinfo.condNames(i), 'word_sym')
            if strcmp(num_temp,'37')
                trialinfo.stim{i} = 'exclamation point';
            elseif strcmp(num_temp,'38')
                trialinfo.stim{i} = 'question mark';
            elseif strcmp(num_temp,'39')
                trialinfo.stim{i} = 'apostrophe';
            elseif strcmp(num_temp,'40')
                trialinfo.stim{i} = 'Apersand';
            elseif strcmp(num_temp,'41')
                trialinfo.stim{i} = 'semicolon';
            elseif strcmp(num_temp,'42')
                trialinfo.stim{i} = 'tilde';
            elseif strcmp(num_temp,'43')
                trialinfo.stim{i} = '@';
            elseif strcmp(num_temp,'44')
                trialinfo.stim{i} = 'colon';
            elseif strcmp(num_temp,'45')
                trialinfo.stim{i} = 'paragraph sign';
            else
            end
        elseif strcmp(trialinfo.condNames(i), 'company_logo')
            if strcmp(num_temp,'64')
                trialinfo.stim{i} = 'shell';
            elseif strcmp(num_temp,'65')
                trialinfo.stim{i} = 'nike';
            elseif strcmp(num_temp,'66')
                trialinfo.stim{i} = 'mitsubishi';
            elseif strcmp(num_temp,'67')
                trialinfo.stim{i} = 'apple';
            elseif strcmp(num_temp,'68')
                trialinfo.stim{i} = 'mazda';
            elseif strcmp(num_temp,'69')
                trialinfo.stim{i} = 'mercedes';
            elseif strcmp(num_temp,'70')
                trialinfo.stim{i} = 'toyota';
            elseif strcmp(num_temp,'71')
                trialinfo.stim{i} = 'chevrolet';
            elseif strcmp(num_temp,'72')
                trialinfo.stim{i} = 'chrysler';
            else
            end
            
        elseif strcmp(trialinfo.condNames(i), 'meaningful_logo')
            if strcmp(num_temp,'55')
                trialinfo.stim{i} = 'no turn around';
            elseif strcmp(num_temp,'56')
                trialinfo.stim{i} = 'recycling';
            elseif strcmp(num_temp,'57')
                trialinfo.stim{i} = 'winding road';
            elseif strcmp(num_temp,'58')
                trialinfo.stim{i} = 'pedestrian';
            elseif strcmp(num_temp,'59')
                trialinfo.stim{i} = 'double note music logo';
            elseif strcmp(num_temp,'60')
                trialinfo.stim{i} = 'no symbol';
            elseif strcmp(num_temp,'61')
                trialinfo.stim{i} = 'single note music logo';
            elseif strcmp(num_temp,'62')
                trialinfo.stim{i} = 'option key';
            elseif strcmp(num_temp,'63')
                trialinfo.stim{i} = 'cd vector icon';
            else
            end
        elseif strcmp(trialinfo.condNames(i), 'num_sym')
            if strcmp(num_temp,'46')
                trialinfo.stim{i} = 'dollar sign';
            elseif strcmp(num_temp,'47')
                trialinfo.stim{i} = 'division sign';
            elseif strcmp(num_temp,'48')
                trialinfo.stim{i} = 'greater/equal than';
            elseif strcmp(num_temp,'49')
                trialinfo.stim{i} = 'less/equal than';
            elseif strcmp(num_temp,'50')
                trialinfo.stim{i} = 'Greater than';
            elseif strcmp(num_temp,'51')
                trialinfo.stim{i} = 'approximately equal to';
            elseif strcmp(num_temp,'52')
                trialinfo.stim{i} = 'pound';
            elseif strcmp(num_temp,'53')
                trialinfo.stim{i} = 'plus';
            elseif strcmp(num_temp,'54')
                trialinfo.stim{i} = 'equal';
            else
            end
        else
        end
        
        
    end
    save([globalVar.psych_dir '/trialinfo_', bn '.mat'], 'trialinfo');
end
end






