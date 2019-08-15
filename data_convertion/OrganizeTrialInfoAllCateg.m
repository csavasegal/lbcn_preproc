function OrganizeTrialInfoAllCateg(sbj_name, project_name, block_names, dirs)

warning('off','all')



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
        if ~isempty(K.theData(i).keys);
            trialinfo.keys{i}=K.theData(i).keys;
        else
            trialinfo.keys{i}={NaN};
        end
        
        %if strcmp(K.theData(i).RT, {0});
            %trialinfo.RT{i}=K.theData(i).RT;
        
        trialinfo.RT(i)=NaN;
        %trialinfo.RT(i) = cell2mat(trialinfo.RT(i))
        
        trialinfo.StimulusOnsetTime(i) = K.theData(i).flip.StimulusOnsetTime;
        trialinfo.stimlist(i) = K.stimlist(i)';
        temp = extractBefore(trialinfo.stimlist(i), '.bmp');
        length_temp = strlength(temp);
        stim_temp = extractBefore(temp, length_temp-1);
        num_temp = string(regexp(temp, '\d+', 'match'));
        
        
        %getting the conditionNames; helps with grouping by using
        %condDescript
        if startsWith(stim_temp, 'symeqn', 'IgnoreCase',true)
            trialinfo.condNames{i} = 'symbolic equation';
            trialinfo.condDescript{i} = 'number_eq';
        elseif startsWith(stim_temp, 'numeqn', 'IgnoreCase',true)
            trialinfo.condNames{i} = 'number equation';
            trialinfo.condDescript{i} = 'number_eq';
        elseif startsWith(stim_temp, 'nonnumword', 'IgnoreCase',true)
            trialinfo.condNames{i} = 'nonnumword';
            trialinfo.condDescript{i} = 'word';
        elseif startsWith(stim_temp, 'texteqn', 'IgnoreCase',true)
            trialinfo.condNames{i} = 'text equation';
            trialinfo.condDescript{i} = 'number_eq';
        elseif startsWith(stim_temp, 'sentence', 'IgnoreCase',true)
            trialinfo.condNames{i} = 'sentence';
            trialinfo.condDescript{i} = 'sentence';
        elseif startsWith(stim_temp, 'slett', 'IgnoreCase',true)
            trialinfo.condNames{i}='scramble-letter';
            trialinfo.condDescript{i} = 'scramble-letter';
        elseif startsWith(stim_temp, 'snum', 'IgnoreCase',true)
            trialinfo.condNames{i}='scramble-number';
            trialinfo.condDescript{i} = 'scramble-number';
        elseif startsWith(stim_temp, 'foreign', 'IgnoreCase',true)
            trialinfo.condNames{i}='foreign';
            trialinfo.condDescript{i}='foreign';
        elseif startsWith(stim_temp, 'lett', 'IgnoreCase',true)
            trialinfo.condNames{i}='letter';
            trialinfo.condDescript{i}='letter';
        elseif startsWith(stim_temp, 'numword', 'IgnoreCase',true)
            trialinfo.condNames{i}='number word';
            trialinfo.condDescript{i}='number_word';
        elseif startsWith(stim_temp, 'num', 'IgnoreCase',true)
            trialinfo.condNames{i}='number';
            trialinfo.condDescript{i}='number';
        else
        end
        
        if strcmp(trialinfo.condDescript(i), 'foreign')
            trialinfo.stim{i} = temp;
            %trialinfo.stim_num{i} = NaN;
            
            %letters & numbers are the same as in scrambled, but the numbering is off
        elseif strcmp(trialinfo.condDescript(i), 'letter') || strcmp(trialinfo.condDescript(i), 'scramble-letter')
            if strcmp(num_temp,'01')|| strcmp(num_temp,'10')|| strcmp(num_temp,'19')|| strcmp(num_temp,'28')
                trialinfo.stim{i} = 'T';
                %trialinfo.stim_num{i} = NaN;
            elseif strcmp(num_temp,'02')|| strcmp(num_temp,'11')|| strcmp(num_temp,'20') || strcmp(num_temp,'29')
                trialinfo.stim{i} = 'S';
                %trialinfo.stim_num{i} = NaN;
            elseif strcmp(num_temp,'03')|| strcmp(num_temp,'12')|| strcmp(num_temp,'21')|| strcmp(num_temp,'30')
                trialinfo.stim{i} = 'N' ;
                %trialinfo.stim_num{i} = NaN;
            elseif strcmp(num_temp,'04')|| strcmp(num_temp,'13')|| strcmp(num_temp,'22')|| strcmp(num_temp,'31')
                trialinfo.stim{i} = 'R';
                %trialinfo.stim_num{i} = NaN;
            elseif strcmp(num_temp,'05')|| strcmp(num_temp,'14')|| strcmp(num_temp,'23') || strcmp(num_temp,'32')
                trialinfo.stim{i} = 'H';
                %trialinfo.stim_num{i} = NaN;
            elseif strcmp(num_temp,'06')|| strcmp(num_temp,'15')|| strcmp(num_temp,'24') || strcmp(num_temp,'33')
                trialinfo.stim{i} = 'E';
                %trialinfo.stim_num{i} = NaN;
            elseif strcmp(num_temp,'07')|| strcmp(num_temp,'16')|| strcmp(num_temp,'25')|| strcmp(num_temp,'34')
                trialinfo.stim{i} = 'D';
                %trialinfo.stim_num{i} = NaN;
            elseif strcmp(num_temp,'08')|| strcmp(num_temp,'17')|| strcmp(num_temp,'26')|| strcmp(num_temp,'35')
                trialinfo.stim{i} = 'C';
                %trialinfo.stim_num{i} = NaN;
            elseif strcmp(num_temp,'09')|| strcmp(num_temp,'18')|| strcmp(num_temp,'27')|| strcmp(num_temp,'36')
                trialinfo.stim{i} = 'A';
                %trialinfo.stim_num{i} = NaN;
            end
        elseif strcmp(trialinfo.condDescript(i), 'number') || strcmp(trialinfo.condDescript(i), 'scramble-number')
            if strcmp(num_temp,'01')|| strcmp(num_temp,'10')|| strcmp(num_temp,'19')|| strcmp(num_temp,'28')
                trialinfo.stim{i} = '1'; %&& trialinfo.stim_lett(i) = 'NaN'
                %trialinfo.stim_lett{i} = 'NaN';
            elseif strcmp(num_temp,'02')|| strcmp(num_temp,'11')|| strcmp(num_temp,'20') || strcmp(num_temp,'29')
                trialinfo.stim{i} = '2';
                %trialinfo.stim_lett{i} = 'NaN';
            elseif strcmp(num_temp,'03')|| strcmp(num_temp,'12')|| strcmp(num_temp,'21')|| strcmp(num_temp,'30')
                trialinfo.stim{i} = '3'   ;
                %trialinfo.stim_lett{i} = 'NaN';
            elseif strcmp(num_temp,'04')|| strcmp(num_temp,'13')|| strcmp(num_temp,'22')|| strcmp(num_temp,'31')
                trialinfo.stim{i} = '4' ;
                %trialinfo.stim_lett{i} = 'NaN';
            elseif strcmp(num_temp,'05')|| strcmp(num_temp,'14')|| strcmp(num_temp,'23') || strcmp(num_temp,'32')
                trialinfo.stim{i} = '5';
                %trialinfo.stim_lett{i} = 'NaN';
            elseif strcmp(num_temp,'06')|| strcmp(num_temp,'15')|| strcmp(num_temp,'24') || strcmp(num_temp,'33')
                trialinfo.stim{i} = '6';
                %trialinfo.stim_lett{i} = 'NaN';
            elseif strcmp(num_temp,'07')|| strcmp(num_temp,'16')|| strcmp(num_temp,'25')|| strcmp(num_temp,'34')
                trialinfo.stim{i} = '7';
                %trialinfo.stim_lett{i} = 'NaN';
            elseif strcmp(num_temp,'08')|| strcmp(num_temp,'17')|| strcmp(num_temp,'26')|| strcmp(num_temp,'35')
                trialinfo.stim{i} = '8';
                %trialinfo.stim_lett{i} = 'NaN';
            elseif strcmp(num_temp,'09')|| strcmp(num_temp,'18')|| strcmp(num_temp,'27')|| strcmp(num_temp,'36')
                trialinfo.stim{i} = '9';
                %trialinfo.stim_lett{i} = 'NaN';
            end
            % equations are not found in Scrambled; equations were created by
            % looking at the original stimuli
        elseif strcmp(trialinfo.condDescript(i), 'number_eq') %applies to both text & number equations
            if strcmp(num_temp,'01')|| strcmp(num_temp,'10')|| strcmp(num_temp,'19')|| strcmp(num_temp,'28')
                trialinfo.stim{i} = '2+2=4';
            elseif strcmp(num_temp,'02')|| strcmp(num_temp,'11')|| strcmp(num_temp,'20') || strcmp(num_temp,'29')
                trialinfo.stim{i} = '3+2=5';
            elseif strcmp(num_temp,'03')|| strcmp(num_temp,'12')|| strcmp(num_temp,'21')|| strcmp(num_temp,'30')
                trialinfo.stim{i} = '2+4=6';
            elseif strcmp(num_temp,'04')|| strcmp(num_temp,'13')|| strcmp(num_temp,'22')|| strcmp(num_temp,'31')
                trialinfo.stim{i} = '5+2=7';
            elseif strcmp(num_temp,'05')|| strcmp(num_temp,'14')|| strcmp(num_temp,'23') || strcmp(num_temp,'32')
                trialinfo.stim{i} = '2+6=8';
            elseif strcmp(num_temp,'06')|| strcmp(num_temp,'15')|| strcmp(num_temp,'24') || strcmp(num_temp,'33')
                trialinfo.stim{i} = '3+5=8';
            elseif  strcmp(num_temp,'07')|| strcmp(num_temp,'16')|| strcmp(num_temp,'25')|| strcmp(num_temp,'34')
                trialinfo.stim{i} = '6+3=9';
            elseif strcmp(num_temp,'08')|| strcmp(num_temp,'17')|| strcmp(num_temp,'26')|| strcmp(num_temp,'35')
                trialinfo.stim{i} = '4+4=8';
            elseif strcmp(num_temp,'09')|| strcmp(num_temp,'18')|| strcmp(num_temp,'27')|| strcmp(num_temp,'36')
                trialinfo.stim{i} = '5+4=9';
            else
            end
        elseif strcmp(trialinfo.condDescript(i), 'sentence')
            if strcmp(num_temp,'01')|| strcmp(num_temp,'10')|| strcmp(num_temp,'19')|| strcmp(num_temp,'28')
                trialinfo.stim{i} = 'I ate fruit today';
            elseif strcmp(num_temp,'02')|| strcmp(num_temp,'11')|| strcmp(num_temp,'20') || strcmp(num_temp,'29')
                trialinfo.stim{i} = 'I took a nap today';
            elseif strcmp(num_temp,'03')|| strcmp(num_temp,'12')|| strcmp(num_temp,'21')|| strcmp(num_temp,'30')
                trialinfo.stim{i} = 'I drove a car today';
            elseif strcmp(num_temp,'04')|| strcmp(num_temp,'13')|| strcmp(num_temp,'22')|| strcmp(num_temp,'31')
                trialinfo.stim{i} = 'I watched TV today';
            elseif strcmp(num_temp,'05')|| strcmp(num_temp,'14')|| strcmp(num_temp,'23') || strcmp(num_temp,'32')
                trialinfo.stim{i} = 'I ate pizza this week';
            elseif strcmp(num_temp,'06')|| strcmp(num_temp,'15')|| strcmp(num_temp,'24') || strcmp(num_temp,'33')
                trialinfo.stim{i} = 'I worked out this week';
            elseif strcmp(num_temp,'07')|| strcmp(num_temp,'16')|| strcmp(num_temp,'25')|| strcmp(num_temp,'34')
                trialinfo.stim{i} = 'I bought a CD this week';
            elseif strcmp(num_temp,'08')|| strcmp(num_temp,'17')|| strcmp(num_temp,'26')|| strcmp(num_temp,'35')
                trialinfo.stim{i} = 'I wore jeans yesterday';
            elseif strcmp(num_temp,'09')|| strcmp(num_temp,'18')|| strcmp(num_temp,'27')|| strcmp(num_temp,'36')
                trialinfo.stim{i} = 'I ate candy yesterday';
            else
            end
            
        elseif strcmp(trialinfo.condDescript(i), 'word')
            if strcmp(num_temp,'01')|| strcmp(num_temp,'10')|| strcmp(num_temp,'19')|| strcmp(num_temp,'28')
                trialinfo.stim{i} = 'tree';
            elseif strcmp(num_temp,'02')|| strcmp(num_temp,'11')|| strcmp(num_temp,'20') || strcmp(num_temp,'29')
                trialinfo.stim{i} = 'dirty';
            elseif strcmp(num_temp,'03')|| strcmp(num_temp,'12')|| strcmp(num_temp,'21')|| strcmp(num_temp,'30')
                trialinfo.stim{i} = 'hive';
            elseif strcmp(num_temp,'04')|| strcmp(num_temp,'13')|| strcmp(num_temp,'22')|| strcmp(num_temp,'31')
                trialinfo.stim{i} = 'naughty';
            elseif strcmp(num_temp,'05')|| strcmp(num_temp,'14')|| strcmp(num_temp,'23') || strcmp(num_temp,'32')
                trialinfo.stim{i} = 'shorty';
            elseif strcmp(num_temp,'06')|| strcmp(num_temp,'15')|| strcmp(num_temp,'24') || strcmp(num_temp,'33')
                trialinfo.stim{i} = 'pine';
            elseif strcmp(num_temp,'07')|| strcmp(num_temp,'16')|| strcmp(num_temp,'25')|| strcmp(num_temp,'34')
                trialinfo.stim{i} = 'thin';
            elseif strcmp(num_temp,'08')|| strcmp(num_temp,'17')|| strcmp(num_temp,'26')|| strcmp(num_temp,'35')
                trialinfo.stim{i} = 'aid';
            elseif strcmp(num_temp,'09')|| strcmp(num_temp,'18')|| strcmp(num_temp,'27')|| strcmp(num_temp,'36')
                trialinfo.stim{i} = 'nifty';
            else
            end
        elseif strcmp(trialinfo.condDescript(i), 'number_word')
            if strcmp(num_temp,'01')|| strcmp(num_temp,'10')|| strcmp(num_temp,'19')|| strcmp(num_temp,'28')
                trialinfo.stim{i} = '3';
            elseif strcmp(num_temp,'02')|| strcmp(num_temp,'11')|| strcmp(num_temp,'20') || strcmp(num_temp,'29')
                trialinfo.stim{i} = '30';
            elseif strcmp(num_temp,'03')|| strcmp(num_temp,'12')|| strcmp(num_temp,'21')|| strcmp(num_temp,'30')
                trialinfo.stim{i} = '5';
            elseif strcmp(num_temp,'04')|| strcmp(num_temp,'13')|| strcmp(num_temp,'22')|| strcmp(num_temp,'31')
                trialinfo.stim{i} = '90';
            elseif strcmp(num_temp,'05')|| strcmp(num_temp,'14')|| strcmp(num_temp,'23') || strcmp(num_temp,'32')
                trialinfo.stim{i} = '40';
            elseif strcmp(num_temp,'06')|| strcmp(num_temp,'15')|| strcmp(num_temp,'24') || strcmp(num_temp,'33')
                trialinfo.stim{i} = '9';
            elseif strcmp(num_temp,'07')|| strcmp(num_temp,'16')|| strcmp(num_temp,'25')|| strcmp(num_temp,'34')
                trialinfo.stim{i} = '10';
            elseif strcmp(num_temp,'08')|| strcmp(num_temp,'17')|| strcmp(num_temp,'26')|| strcmp(num_temp,'35')
                trialinfo.stim{i} = '8';
            elseif strcmp(num_temp,'09')|| strcmp(num_temp,'18')|| strcmp(num_temp,'27')|| strcmp(num_temp,'36')
                trialinfo.stim{i} = '50';
            end
        else
        end
    end
    
    
    % To get the operands for the equations
    
    for i = 1:ntrials
        if strcmp(trialinfo.condDescript(i), 'number_eq')
            [operands,operators] = cellfun(@(x) strsplit(x, {'+','-','=','without','is','and'}, 'CollapseDelimiters',true), trialinfo.stim(i), 'UniformOutput', false);
            for ci = 1:length(operands)

                
                if ~isempty(str2num(operands{ci}{1}))
                    trialinfo.isCalc(i) = 1;
                    %trialinfo.condNames{i} = 'digit';
                    trialinfo.operand1(i) = str2num(operands{ci}{1});
                    trialinfo.operand2(i) = str2num(operands{ci}{2});
                    
                    if strcmp(operators{ci}{1}, '+')
                        trialinfo.operator(i) = 1;
                    else
                    end
                    trialinfo.Result(i) = str2num(operands{ci}{3});
                    %trialinfo.corrResult(i) = trialinfo.operand1(i) + trialinfo.operand2(i)*trialinfo.operator(i);
                    trialinfo.minOperand(i) = min(trialinfo.operand1(i), trialinfo.operand2(i));
                    trialinfo.maxOperand(i) = max(trialinfo.operand1(i), trialinfo.operand2(i));
                    
                    % Cross decade
                    if trialinfo.minOperand(i) < 10 && trialinfo.maxOperand(i) < 10
                        if length(operands{ci}{3}) > 1
                            trialinfo.crossDecade(i) = 1;
                        else
                            trialinfo.crossDecade(i) = 0;
                        end
                    elseif trialinfo.minOperand(i) > 10 && trialinfo.maxOperand(i) > 10
                        trialinfo.crossDecade(i) = 1;
                    else
                        max_tmp = num2str(trialinfo.maxOperand(i));
                        corr_tmp = num2str(trialinfo.corrResult(i));
                        if strcmp(max_tmp(1), corr_tmp(1)) == 1
                            trialinfo.crossDecade(i) = 0;
                        else
                            trialinfo.crossDecade(i) = 1;
                        end
                    end
                end
            end
       
        else
            trialinfo.isCalc(i) = 0;
            trialinfo.Result(i) = NaN;
            %trialinfo.corrResult(i) = NaN;
            trialinfo.minOperand(i) = NaN;
            trialinfo.maxOperand(i) = NaN;
            trialinfo.operand1(i) = NaN;
            trialinfo.operand2(i) = NaN;
            trialinfo.operator(i) = NaN;
 
        end
    end
    
end

save([globalVar.psych_dir '/trialinfo_', bn '.mat'], 'trialinfo');


end

